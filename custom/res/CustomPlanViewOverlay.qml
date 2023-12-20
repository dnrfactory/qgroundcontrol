/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Layouts  1.2
import QtQuick.Window   2.2

import QGroundControl                   1.0
import QGroundControl.FlightMap         1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactSystem        1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0
import QGroundControl.Controllers       1.0
import QGroundControl.ShapeFileHelper   1.0

Item {
    id: _root

    property var planView
    property bool wayPointChecked: false

    height:                 _bottomPanelHeight + _bottomPanelMargin * 2
    anchors.left:           parent.left
    anchors.right:          parent.right
    anchors.bottom:         parent.bottom
    anchors.topMargin:      _bottomPanelMargin
    
    property var  _planMasterController:                planView._planMasterController
    property var    _missionController:                 _planMasterController.missionController
    property var    _visualItems:                       _missionController.visualItems


    readonly property real  _bottomPanelWidth:          ScreenTools.defaultFontPixelWidth * 35                  // Width        : 280
    readonly property real  _bottomPanelHeight:         ScreenTools.defaultFontPixelWidth * 30                  // Height       : 240

    readonly property real  _bottomPanelMargin:         ScreenTools.defaultFontPixelWidth * 2                   // Margin       : 16

    readonly property real  _bottomPanelButtonWidth:    _bottomPanelWidth - (_bottomPanelLeftPadding * 2)            // Width   : 248
    readonly property real  _bottomPanelButtonHeight:   (_bottomPanelHeight - (_bottomPanelTopPadding * 2) - (_bottomPanelButtonSpacing * 4))/5   // Height       : 35

    readonly property real  _bottomPanelLeftPadding:    ScreenTools.defaultFontPixelWidth * 2                   // LeftPadding  : 16
    readonly property real  _bottomPanelTopPadding:     ScreenTools.defaultFontPixelWidth * 2                   // TopPadding   : 16
    readonly property real  _bottomPanelButtonSpacing:  ScreenTools.defaultFontPixelWidth                       // LeftPadding  : 8

    readonly property real  _bottomPanelRadious:        ScreenTools.defaultFontPixelWidth * 1.25                // Radious      : 10


    property bool   _controllerValid:                   _planMasterController !== undefined && _planMasterController !== null
    property var    _controllerSyncInProgress:          _controllerValid ? _planMasterController.syncInProgress : false
    property bool   _controllerOffline:                 _controllerValid ? _planMasterController.offline : true
    property real   _controllerProgressPct:             _controllerValid ? _planMasterController.missionController.progressPct : 0
    property bool   _selectupload :                     false
    property bool   _selectdownload :                   false

    on_ControllerSyncInProgressChanged: {
        if (!_controllerSyncInProgress){
            _selectupload = false
            _selectdownload = false
        }
    }
    
    property int                _currentPlan:       0
    readonly property int       _initPlan:          0
    readonly property int       _waypointSail:      1
    readonly property int       _corridorSail:      2
    readonly property int       _gridSail:          3

    property int       _scanIndex:              -1
    property var       _mapPolys:                null

    property int    _visualItemsCount:          _missionController.visualItems.count
    property var    _savedVertices:             [ ]

    property bool   _circleMode:                false
    property real   _circleRadius

    property int    _currentPlanViewviIndex:    _missionController.currentPlanViewVIIndex
    

    property var createPlanRemoveAllPromptDialogMapCenter
    property var createPlanRemoveAllPromptDialogPlanCreator

    property int clickPlanIndex : 0
    

    function getScanIndex(){
        for (var i=0; i<_visualItemsCount; i++) {
            var vmi = _visualItems.get(i)
            if (vmi.abbreviation === "C" || vmi.abbreviation === "S")
                return i
        }
        return -1
    }

    function isScan(){
        for (var i=0; i<_visualItemsCount; i++) {
            var vmi = _visualItems.get(i)
            if (vmi.abbreviation === "C" || vmi.abbreviation === "S")
                return true
        }
        return false
    }

    function _saveCurrentVertices() {
        _savedVertices = [ ]
        for (var i=0; i<_mapPolys.count; i++) {
            _savedVertices.push(_mapPolys.vertexCoordinate(i))
        }
    }

    function _restorePreviousVertices() {
        _mapPolys.beginReset()
        _mapPolys.clear()
        for (var i=0; i<_savedVertices.length; i++) {
            _mapPolys.appendVertex(_savedVertices[i])
        }
        _mapPolys.endReset()
    }

    function defaultPolygonVertices() {
        // Initial polygon is inset to take 2/3rds space

        var mapControl = editorMap

        var rect = Qt.rect(mapControl.centerViewport.x, mapControl.centerViewport.y, mapControl.centerViewport.width, mapControl.centerViewport.height)
        rect.x += (rect.width * 0.25) / 2
        rect.y += (rect.height * 0.25) / 2
        rect.width *= 0.75
        rect.height *= 0.75

        var centerCoord =       mapControl.toCoordinate(Qt.point(rect.x + (rect.width / 2), rect.y + (rect.height / 2)),   false /* clipToViewPort */)
        var topLeftCoord =      mapControl.toCoordinate(Qt.point(rect.x, rect.y),                                          false /* clipToViewPort */)
        var topRightCoord =     mapControl.toCoordinate(Qt.point(rect.x + rect.width, rect.y),                             false /* clipToViewPort */)
        var bottomLeftCoord =   mapControl.toCoordinate(Qt.point(rect.x, rect.y + rect.height),                            false /* clipToViewPort */)
        var bottomRightCoord =  mapControl.toCoordinate(Qt.point(rect.x + rect.width, rect.y + rect.height),               false /* clipToViewPort */)

        // Initial polygon has max width and height of 3000 meters
        var halfWidthMeters =   Math.min(topLeftCoord.distanceTo(topRightCoord), 3000) / 2
        var halfHeightMeters =  Math.min(topLeftCoord.distanceTo(bottomLeftCoord), 3000) / 2
        topLeftCoord =      centerCoord.atDistanceAndAzimuth(halfWidthMeters, -90).atDistanceAndAzimuth(halfHeightMeters, 0)
        topRightCoord =     centerCoord.atDistanceAndAzimuth(halfWidthMeters, 90).atDistanceAndAzimuth(halfHeightMeters, 0)
        bottomLeftCoord =   centerCoord.atDistanceAndAzimuth(halfWidthMeters, -90).atDistanceAndAzimuth(halfHeightMeters, 180)
        bottomRightCoord =  centerCoord.atDistanceAndAzimuth(halfWidthMeters, 90).atDistanceAndAzimuth(halfHeightMeters, 180)

        return [ topLeftCoord, topRightCoord, bottomRightCoord, bottomLeftCoord  ]
    }

    function _resetCircle() {
        var initialVertices = defaultPolygonVertices()
        var width = initialVertices[0].distanceTo(initialVertices[1])
        var height = initialVertices[1].distanceTo(initialVertices[2])
        var radius = Math.min(width, height) / 2
        var center = initialVertices[0].atDistanceAndAzimuth(width / 2, 90).atDistanceAndAzimuth(height / 2, 180)
        _createCircularPolygon(center, radius)
    }

    function _createCircularPolygon(center, radius) {
        var unboundCenter = center.atDistanceAndAzimuth(0, 0)
        var segments = 16
        var angleIncrement = 360 / segments
        var angle = 0
        _mapPolys.beginReset()
        _mapPolys.clear()
        _circleRadius = radius
        for (var i=0; i<segments; i++) {
            var vertex = unboundCenter.atDistanceAndAzimuth(radius, angle)
            _mapPolys.appendVertex(vertex)
            angle += angleIncrement
        }
        _mapPolys.endReset()
        _circleMode = true
    }

    QGCFileDialog {
        id:             kmlLoadDialog
        folder:         QGroundControl.settingsManager.appSettings.missionSavePath
        title:          qsTr("Select KML File")
        selectExisting: true
        nameFilters:    ShapeFileHelper.fileDialogKMLFilters

        onAcceptedForLoad: {
            if(isScan()){
                var index = getScanIndex()
                _visualItems.get(index).corridorPolyline.loadKMLFile(file)
            }
        }
    }

    KMLOrSHPFileDialog {
        id:             kmlOrSHPLoadDialog
        title:          qsTr("Select Polygon File")
        selectExisting: true

        onAcceptedForLoad: {

            if(isScan()){
                var index = getScanIndex()
                _visualItems.get(index).surveyAreaPolygon.loadKMLOrSHPFile(file)
                _visualItems.get(index).resetState = false
            }
            close()
        }
    }

    on_CurrentPlanChanged: {
        console.log("on_CurrentPlanChanged")

        wayPointChecked = false
        tracingButton.checked = false

        if(_corridorSail <= _currentPlan){
            _scanIndex = getScanIndex()
            _currentPlan == _corridorSail  ? _mapPolys =  _visualItems.get(_scanIndex).corridorPolyline :
                                             _mapPolys =  _visualItems.get(_scanIndex).surveyAreaPolygon
        }

        console.log("on_CurrentPlanChanged end")
    }

    on_VisualItemsCountChanged: {
        console.log("on_VisualItemsCountChanged")
            
        if(isScan() && _corridorSail <= _currentPlan) {
            _scanIndex = getScanIndex()
            _currentPlan == _corridorSail  ? _mapPolys =  _visualItems.get(_scanIndex).corridorPolyline
                                           : _mapPolys =  _visualItems.get(_scanIndex).surveyAreaPolygon
        }
    }

    on_CurrentPlanViewviIndexChanged: {
        if(isScan()){
            var index = getScanIndex()
            if(_currentPlanViewviIndex !== index && tracingButton.checked){
                tracingButton.checked = false
                _mapPolys.traceMode = false
            }
        }
    }

    Component {
        id: syncLoadFromFileOverwrite
        QGCSimpleMessageDialog {
            id:        syncLoadFromVehicleCheck
            title:      ""
            text:       qsTr("You have unsaved/unsent changes. Loading from a file will lose these changes. Are you sure you want to load from a file?")
            buttons:    StandardButton.Yes | StandardButton.No

            onAccepted: {
                planButtons.itemAt(_initPlan).onClicked()
                _planMasterController.loadFromSelectedFile()
            }
        }
    }

    Component {
        id: clearVehicleMissionDialog
        QGCSimpleMessageDialog {
	    title:      ""
            text:       qsTr("Are you sure you want to remove all mission items and clear the mission from the vehicle?")
            buttons:    StandardButton.Yes | StandardButton.No

            onAccepted: {
                _planMasterController.removeAllFromVehicle()
                _missionController.setCurrentPlanViewSeqNum(0, true)
                wayPointChecked = false                
            }
        }
    }

    Row {
        anchors.centerIn: _root
        spacing: _bottomPanelLeftPadding

        Rectangle {
            id:                     customPlanPanel
            height:                 _bottomPanelHeight
            width:                  _bottomPanelWidth
            color:                  "transparent"
            
            DeadMouseArea {
                anchors.fill:   parent
            }

            Rectangle {
                anchors.fill:           parent
                color:                  qgcPal.window
                opacity:                0.8
                radius:                 _bottomPanelRadious
            }

            Item {
                id:                     customPlanButtonList
                anchors.fill:           parent
                anchors.margins:        _bottomPanelMargin

                property var createPlan

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing:            _bottomPanelButtonSpacing

                    ListModel {
                        id: planPanelNames
                       ListElement{name: qsTr("Init Plan")}
                        ListElement{name: qsTr("WayPoint Sail")}
                        ListElement{name: qsTr("Corridor Sail")}
                        ListElement{name: qsTr("Grid Sail")}
                    }

                    Repeater {
                        id : planButtons
                        model: _planMasterController.planCreators

                        QGCButton {
                            id: button
                            text:                   planPanelNames.get(index).name
                            pointSize:              ScreenTools.mediumFontPointSize
                            Layout.preferredWidth:  _bottomPanelButtonWidth
                            Layout.preferredHeight: _bottomPanelButtonHeight
                            backRadius:             _bottomPanelButtonHeight

                            onClicked: {
                                _selectupload = false
                                _selectdownload = false

                                if(model.index === _initPlan){
                                    planButtons.itemAt(_waypointSail).checked = false
                                    planButtons.itemAt(_corridorSail).checked = false
                                    planButtons.itemAt(_gridSail).checked = false
                                }

                                if (_planMasterController.containsItems) {
                                    createPlanRemoveAllPromptDialogMapCenter = _mapCenter()
                                    createPlanRemoveAllPromptDialogPlanCreator = object
                                    clickPlanIndex = model.index

                                    createPlanRemoveAllPromptDialogPlanCreator.createPlan(createPlanRemoveAllPromptDialogMapCenter)
                                    _currentPlan = clickPlanIndex

                                } else {
                                    object.createPlan(_mapCenter())
                                    _currentPlan = model.index
                                }
                                console.log("model.index: " + model.index)
                            }

                            function _mapCenter() {
                                var centerPoint = Qt.point(editorMap.centerViewport.left + (editorMap.centerViewport.width / 2), editorMap.centerViewport.top + (editorMap.centerViewport.height / 2))
                                return editorMap.toCoordinate(centerPoint, false /* clipToViewPort */)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id:                     customToolsPanel
            height:                 _bottomPanelHeight
            width:                  _bottomPanelWidth
            color:                  "transparent"

            DeadMouseArea {
                anchors.fill:   parent
            }

            Rectangle{
                anchors.fill:           parent
                color:                  qgcPal.window
                opacity:                0.8
                radius:                 _bottomPanelRadious
            }

            Item {
                id:                     customToolsButtonList
                anchors.fill:           parent
                anchors.margins:        _bottomPanelMargin

                property var createPlan

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: _bottomPanelButtonSpacing

                    QGCButton {
                        id: addWaypointRallyPointAction
                        text:                   "WayPoint"
                        pointSize:              ScreenTools.mediumFontPointSize
                        Layout.preferredWidth:  _bottomPanelButtonWidth
                        Layout.preferredHeight: _bottomPanelButtonHeight
                        backRadius:             _bottomPanelButtonHeight
                        enabled :                _currentPlan == _waypointSail || _currentPlan == _corridorSail || _currentPlan == _gridSail
                        checked :               wayPointChecked

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(wayPointChecked === true){
                                    wayPointChecked = false

                                }else{
                                    if (isScan() && _mapPolys.traceMode) {
                                        if ( _mapPolys.count < _currentPlan ) {
                                            _restorePreviousVertices()
                                        }
                                        _mapPolys.traceMode = false
                                        tracingButton.checked = false
                                    }
                                    wayPointChecked = true
                                }
                            }
                        }
                    }

                    QGCButton {
                        id : tracingButton
                        text:                   "Tracing"
                        pointSize:              ScreenTools.mediumFontPointSize
                        Layout.preferredWidth:  _bottomPanelButtonWidth
                        Layout.preferredHeight: _bottomPanelButtonHeight
                        backRadius:             _bottomPanelButtonHeight
                        checked :               false
                        enabled :               _scanIndex === _missionController.currentPlanViewVIIndex
                        property bool processing: false

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(tracingButton.checked === true){
                                    _saveCurrentVertices()
                                    _currentPlan === _gridSail ? _circleMode = false : ""
                                    _mapPolys.traceMode = false
                                    tracingButton.checked = false
                                }else{
                                    wayPointChecked = false

                                    _saveCurrentVertices()
                                    _currentPlan === _gridSail ? _circleMode = false : ""
                                    _mapPolys.traceMode = true
                                    tracingButton.checked = true
                                }
                            }
                        }


                    }

                    QGCButton {
                        text:                   "Circle"
                        pointSize:              ScreenTools.mediumFontPointSize
                        Layout.preferredWidth:  _bottomPanelButtonWidth
                        Layout.preferredHeight: _bottomPanelButtonHeight
                        backRadius:             _bottomPanelButtonHeight
                        enabled :               _scanIndex === _missionController.currentPlanViewVIIndex && _gridSail === _currentPlan

                        onClicked: {
                            wayPointChecked = false
                            tracingButton.checked = false
                            _mapPolys.traceMode = false
                            _resetCircle()
                        }
                    }

                    QGCButton {
                        text:                   _currentPlan === 3 ?  qsTr("KML/SHP 임무 불러오기") : qsTr("KML 임무 불러오기")
                        pointSize:              ScreenTools.mediumFontPointSize
                        Layout.preferredWidth:  _bottomPanelButtonWidth
                        Layout.preferredHeight: _bottomPanelButtonHeight
                        backRadius:             _bottomPanelButtonHeight

                        enabled:                _scanIndex === _missionController.currentPlanViewVIIndex

                        onClicked: {
                            if(_currentPlan === 2){
                                kmlLoadDialog.openForLoad()
                            }else if(_currentPlan === 3){
                                kmlOrSHPLoadDialog.openForLoad()
                            }
                        }
                    }

                    QGCButton {
                        text:                   "Clear Tracing"
                        pointSize:              ScreenTools.mediumFontPointSize
                        Layout.preferredWidth:  _bottomPanelButtonWidth
                        Layout.preferredHeight: _bottomPanelButtonHeight
                        backRadius:             _bottomPanelButtonHeight
                        enabled :               _scanIndex === _missionController.currentPlanViewVIIndex

                        onClicked: {
                            _mapPolys.clear();
                        }
                    }
                }
            }
        }

        Rectangle {
            id:                     customUpdatePanel
            height:                 _bottomPanelHeight
            width:                  _bottomPanelWidth
            color:                  "transparent"
            
            DeadMouseArea {
                anchors.fill:   parent
            }

            Rectangle {
                anchors.fill:           parent
                color:                  qgcPal.window
                opacity:                0.8
                radius:                 _bottomPanelRadious
            }

            Item {
                id:                     customUpdateButtonList
                anchors.fill:           parent
                anchors.margins:        _bottomPanelMargin


                ColumnLayout{
                    id: columnholder
                    anchors.horizontalCenter:   parent.horizontalCenter
                    spacing:                    _bottomPanelButtonSpacing

                    Rectangle {
                        width:  _bottomPanelButtonWidth
                        height: _bottomPanelButtonHeight
                        radius: height
                        color: "transparent"

                        QGCButton {
                            id : initButton
                            text:                   qsTr("FC MC 임무 초기화")
                            pointSize:              ScreenTools.mediumFontPointSize
                            Layout.preferredWidth:  _bottomPanelButtonWidth
                            Layout.preferredHeight: _bottomPanelButtonHeight
                            backRadius:             _bottomPanelButtonHeight
                            width :                 _bottomPanelButtonWidth
                            height :                 _bottomPanelButtonHeight
                            Layout.fillWidth:       false
                            enabled:            !_planMasterController.offline && !_planMasterController.syncInProgress

                            onClicked: {
                                mainWindow.showComponentDialog(clearVehicleMissionDialog, text, mainWindow.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                            }
                        }

                        property string _overwriteText: qsTr("Mission overwrite")
                    }

                    Rectangle {
                        width:  _bottomPanelButtonWidth
                        height: _bottomPanelButtonHeight
                        radius: height
                        color: "transparent"

                        QGCButton {
                            id: uploadButton
                            text:                   qsTr("GCS -> FC MC 업로드")
                            pointSize:              ScreenTools.mediumFontPointSize
                            Layout.preferredWidth:  _bottomPanelButtonWidth
                            Layout.preferredHeight: _bottomPanelButtonHeight
                            backRadius:             _bottomPanelButtonHeight
                            width :                 _bottomPanelButtonWidth
                            height :                 _bottomPanelButtonHeight
                            enabled:                !_controllerOffline && !_controllerSyncInProgress && _planMasterController.containsItems
                            visible:                !(_controllerSyncInProgress && _selectupload)
                            onClicked: {
                                _selectupload = true
                                _planMasterController.upload()
                            }
                        }

                        Rectangle{
                            width:              uploadButton.width
                            height:             uploadButton.height
                            radius:             height
                            anchors.centerIn:   uploadButton
                            border.width:       2
                            border.color:       qgcPal.button
                            color:              "transparent"
                            visible:            _controllerSyncInProgress && _selectupload
                        }

                        Rectangle{

                            width:              _controllerProgressPct * uploadButton.width
                            height:             uploadButton.height
                            radius:             height
                            anchors.left:       uploadButton.left
                            anchors.bottom:     uploadButton.bottom
                            color:              qgcPal.button
                            visible:            _controllerSyncInProgress && _selectupload
                        }

                        QGCLabel{
                            text:               qsTr("GCS -> FC MC 업로드")
                            anchors.centerIn:   uploadButton
                            font.pointSize:     ScreenTools.mediumFontPointSize
                            antialiasing:       true
                            font.bold:          true
                            font.family:        ScreenTools.normalFontFamily
                            color :             "white"
                            visible:            _controllerSyncInProgress && _selectupload

                            PropertyAnimation on opacity {
                                easing.type:    Easing.Linear
                                from:           0.5
                                to:             1
                                loops:          Animation.Infinite
                                running:        _controllerSyncInProgress && _selectupload
                                alwaysRunToEnd: true
                                duration:       1000
                            }
                        }
                    }

                    Rectangle {
                        width:  _bottomPanelButtonWidth
                        height: _bottomPanelButtonHeight
                        radius: height
                        color: "transparent"

                        QGCButton {
                            id: dowunloadButton
                            text:               qsTr("FC MC -> GCS 다운로드")
                            pointSize:              ScreenTools.mediumFontPointSize
                            Layout.preferredWidth:  _bottomPanelButtonWidth
                            Layout.preferredHeight: _bottomPanelButtonHeight
                            backRadius:             _bottomPanelButtonHeight
                            width :                 _bottomPanelButtonWidth
                            height :                 _bottomPanelButtonHeight
                            enabled:                !_controllerOffline && !_controllerSyncInProgress
                            visible:                !(_controllerSyncInProgress && _selectdownload)
                            onClicked: {
                                _selectdownload = true
                                _planMasterController.loadFromVehicle()
                            }
                        }

                        Rectangle{
                            width:              dowunloadButton.width
                            height:             dowunloadButton.height
                            radius:             height
                            anchors.centerIn:   dowunloadButton
                            border.width:       2
                            border.color:       qgcPal.button
                            color:              "transparent"
                            visible:           _controllerSyncInProgress && _selectdownload
                        }

                        Rectangle{
                            width:              _controllerProgressPct * dowunloadButton.width
                            height:             dowunloadButton.height
                            radius:             height
                            anchors.left:       dowunloadButton.left
                            anchors.bottom:     dowunloadButton.bottom
                            color:              qgcPal.button
                            visible:          _controllerSyncInProgress && _selectdownload
                        }

                        QGCLabel{
                            text:               qsTr("FC MC -> GCS 다운로드")
                            anchors.centerIn:   dowunloadButton
                            font.pointSize:     ScreenTools.mediumFontPointSize
                            antialiasing:       true
                            font.bold:          true
                            font.family:        ScreenTools.normalFontFamily
                            color :             "white"
                            visible:            _controllerSyncInProgress && _selectdownload

                            PropertyAnimation on opacity {
                                easing.type:    Easing.Linear
                                from:           0.5
                                to:             1
                                loops:          Animation.Infinite
                                running:        _controllerSyncInProgress && _selectdownload
                                alwaysRunToEnd: true
                                duration:       1000
                            }
                        }
                }

                    QGCButton {
                        text:               qsTr("임무 불러오기")
                        pointSize:              ScreenTools.mediumFontPointSize
                        Layout.preferredWidth:  _bottomPanelButtonWidth
                        Layout.preferredHeight: _bottomPanelButtonHeight
                        backRadius:             _bottomPanelButtonHeight

                        enabled:            !_planMasterController.syncInProgress
                        onClicked: {
                            console.log("임무 불러오기")
                            if (_planMasterController.dirty) {
                                console.log("임무 불러오기")
                                console.log(_planMasterController.dirty)
                                mainWindow.showComponentDialog(syncLoadFromFileOverwrite, columnholder._overwriteText, mainWindow.showDialogDefaultWidth, StandardButton.Yes | StandardButton.Cancel)
                            } else {

                                _planMasterController.loadFromSelectedFile()
                            }
                        }
                    }

                    QGCButton {
                        text:               qsTr("다른 이름으로 임무 저장")
                        pointSize:              ScreenTools.mediumFontPointSize
                        Layout.preferredWidth:  _bottomPanelButtonWidth
                        Layout.preferredHeight: _bottomPanelButtonHeight
                        backRadius:             _bottomPanelButtonHeight

                        enabled:            !_planMasterController.syncInProgress && _planMasterController.containsItems
                        onClicked: {
                            _planMasterController.saveToSelectedFile()
                        }
                    }
                }
            }
        }

        Rectangle {
            id:                     customPlanInformPanel
            height:                 _bottomPanelHeight
            width:                  _bottomPanelWidth
            color:                  "transparent"

            DeadMouseArea {
                anchors.fill:   parent
            }

            Rectangle{
                anchors.fill:           parent
                color:                  qgcPal.window
                opacity:                0.8
                radius:                 _bottomPanelRadious
            }

            // MainToolBar에 있는 PlanToolBarIndicators의 일부를 가져오지 못해서 일부 코드만 가져옴
            // 운항 거리, 최대 거리, 예상 소요시간만 가져왔음
            // 운항 속도의 경우는 기존 PlanToolBarIndicators에 없어서 missionDistance와 동일하게 함수 작성
            Item {
                id:                     customPlanInformList
                anchors.fill:           parent
                anchors.margins:        _bottomPanelMargin

                property bool   _controllerValid:           _planMasterController !== undefined && _planMasterController !== null
                property var    missionItems:               _controllerValid ? _planMasterController.missionController.visualItems : undefined
                property bool   _missionValid:              missionItems !== undefined

                //운항 거리
                property real   missionDistance:            _controllerValid ? _planMasterController.missionController.missionDistance : NaN
                property real   _missionDistance:           _missionValid ? missionDistance : NaN
                property string _missionDistanceText:       isNaN(_missionDistance) ?       "-.-" : QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(_missionDistance).toFixed(0) + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString

                //최대 거리
                property real   missionMaxTelemetry:        _controllerValid ? _planMasterController.missionController.missionMaxTelemetry : NaN
                property real   _missionMaxTelemetry:       _missionValid ? missionMaxTelemetry : NaN
                property string _missionMaxTelemetryText:   isNaN(_missionMaxTelemetry) ?   "-.-" : QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(_missionMaxTelemetry).toFixed(0) + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString

                //예상 소요시간
                property real   missionTime:                _controllerValid ? _planMasterController.missionController.missionTime : 0
                property real   _missionTime:               _missionValid ? missionTime : 0

                GridLayout{
                    columns:                    2
                    rowSpacing:                 _bottomPanelButtonSpacing
                    columnSpacing:              _bottomPanelLeftPadding
                    anchors.centerIn:           parent

                    QGCLabel { text: qsTr("운항 거리 ");
                        font.pointSize:     ScreenTools.mediumFontPointSize
                        Layout.alignment:   Qt.AlignRight
                    }
                    QGCLabel {
                        text:               customPlanInformList._missionDistanceText
                        font.pointSize:     ScreenTools.mediumFontPointSize
                        Layout.alignment:   Qt.AlignLeft
                    }


                    QGCLabel { text: qsTr("운항 속도 ");
                        font.pointSize:     ScreenTools.mediumFontPointSize
                        Layout.alignment:   Qt.AlignRight
                    }

                    QGCLabel{
                        property Fact fact: QGroundControl.settingsManager.appSettings.offlineEditingCruiseSpeed
                        text: fact.valueString + " " + fact.units
                        font.pointSize:     ScreenTools.mediumFontPointSize
                        Layout.alignment:   Qt.AlignLeft
                    }

                    QGCLabel { text: qsTr("최대 거리 ");
                        font.pointSize:     ScreenTools.mediumFontPointSize;
                        Layout.alignment:   Qt.AlignRight
                    }
                    QGCLabel {
                        text:               customPlanInformList._missionMaxTelemetryText
                        font.pointSize:     ScreenTools.mediumFontPointSize
                        Layout.alignment:   Qt.AlignLeft
                    }


                    QGCLabel { text: qsTr("예상 소요시간 ");
                        font.pointSize:     ScreenTools.mediumFontPointSize;
                        Layout.alignment:   Qt.AlignRight
                    }
                    QGCLabel {
                        text:               customPlanInformList.getMissionTime()
                        font.pointSize:     ScreenTools.mediumFontPointSize
                        Layout.alignment:   Qt.AlignLeft
                    }
                }

                function getMissionTime() {
                    if (!_missionTime) {
                        return "00:00:00"
                    }
                    var t = new Date(2023, 0, 0, 0, 0, Number(_missionTime))
                    var days = Qt.formatDateTime(t, 'dd')
                    var complete

                    if (days == 31) {
                        days = '0'
                        complete = Qt.formatTime(t, 'hh:mm:ss')
                    } else {
                        complete = days + " days " + Qt.formatTime(t, 'hh:mm:ss')
                    }
                    return complete
                }
            }
        }
    }
}

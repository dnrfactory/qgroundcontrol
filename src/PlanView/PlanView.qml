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

import QtQuick.Extras                   1.4
import QGroundControl.Vehicle           1.0

Item {
    id: _root

    property bool planControlColapsed: false

    readonly property int   _decimalPlaces:             8
    readonly property real  _margin:                    ScreenTools.defaultFontPixelHeight * 0.5
    readonly property real  _toolsMargin:               ScreenTools.defaultFontPixelWidth * 0.75
    readonly property real  _radius:                    ScreenTools.defaultFontPixelWidth  * 0.5
    readonly property real  _rightPanelWidth:           Math.min(parent.width / 3, ScreenTools.defaultFontPixelWidth * 30)
    readonly property var   _defaultVehicleCoordinate:  QtPositioning.coordinate(37.803784, -122.462276)
    readonly property bool  _waypointsOnlyMode:         QGroundControl.corePlugin.options.missionWaypointsOnly

    property var    _planMasterController:              planMasterController
    property var    _missionController:                 _planMasterController.missionController
    property var    _geoFenceController:                _planMasterController.geoFenceController
    property var    _rallyPointController:              _planMasterController.rallyPointController
    property var    _visualItems:                       _missionController.visualItems
    property bool   _lightWidgetBorders:                editorMap.isSatelliteMap
    property bool   _addROIOnClick:                     false
    property bool   _singleComplexItem:                 _missionController.complexMissionItemNames.length === 1
    property int    _editingLayer:                      layerTabBar.currentIndex ? _layers[layerTabBar.currentIndex] : _layerMission
    property var    _appSettings:                       QGroundControl.settingsManager.appSettings
    property var    _planViewSettings:                  QGroundControl.settingsManager.planViewSettings
    property bool   _promptForPlanUsageShowing:         false

    readonly property var       _layers:                [_layerMission, _layerGeoFence, _layerRallyPoints]

    readonly property int       _layerMission:              1
    readonly property int       _layerGeoFence:             2
    readonly property int       _layerRallyPoints:          3
    readonly property string    _armedVehicleUploadPrompt:  qsTr("Vehicle is currently armed. Do you want to upload the mission to the vehicle?")

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

    function mapCenter() {
        var coordinate = editorMap.center
        coordinate.latitude  = coordinate.latitude.toFixed(_decimalPlaces)
        coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
        coordinate.altitude  = coordinate.altitude.toFixed(_decimalPlaces)
        return coordinate
    }

    function updateAirspace(reset) {
        if(_airspaceEnabled) {
            var coordinateNW = editorMap.toCoordinate(Qt.point(0,0), false /* clipToViewPort */)
            var coordinateSE = editorMap.toCoordinate(Qt.point(width,height), false /* clipToViewPort */)
            if(coordinateNW.isValid && coordinateSE.isValid) {
                QGroundControl.airspaceManager.setROI(coordinateNW, coordinateSE, true /*planView*/, reset)
            }
        }
    }

    property bool _firstMissionLoadComplete:    false
    property bool _firstFenceLoadComplete:      false
    property bool _firstRallyLoadComplete:      false
    property bool _firstLoadComplete:           false

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

        addWaypointRallyPointAction.checked = false
        tracingButton.checked = false

        if(_corridorSail <= _currentPlan){
            _scanIndex = getScanIndex()
            _currentPlan == _corridorSail  ? _mapPolys =  _visualItems.get(_scanIndex).corridorPolyline :
                                             _mapPolys =  _visualItems.get(_scanIndex).surveyAreaPolygon
        }
    }

    on_VisualItemsCountChanged: {
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

    MapFitFunctions {
        id:                         mapFitFunctions  // The name for this id cannot be changed without breaking references outside of this code. Beware!
        map:                        editorMap
        usePlannedHomePosition:     true
        planMasterController:       _planMasterController
    }

    onVisibleChanged: {
        if(visible) {
            editorMap.zoomLevel = QGroundControl.flightMapZoom
            editorMap.center    = QGroundControl.flightMapPosition
        }
    }

    Connections {
        target: _appSettings ? _appSettings.defaultMissionItemAltitude : null
        function onRawValueChanged() {
            if (_visualItems.count > 1) {
                mainWindow.showMessageDialog(qsTr("Apply new altitude"),
                                             qsTr("You have changed the default altitude for mission items. Would you like to apply that altitude to all the items in the current mission?"),
                                             StandardButton.Yes | StandardButton.No,
                                             function() { _missionController.applyDefaultMissionAltitude() })
            }
        }
    }

    Component {
        id: promptForPlanUsageOnVehicleChangePopupComponent
        QGCPopupDialog {
            title:      _planMasterController.managerVehicle.isOfflineEditingVehicle ? qsTr("Plan View - Vehicle Disconnected") : qsTr("Plan View - Vehicle Changed")
            buttons:    StandardButton.NoButton

            ColumnLayout {
                QGCLabel {
                    Layout.maximumWidth:    parent.width
                    wrapMode:               QGCLabel.WordWrap
                    text:                   _planMasterController.managerVehicle.isOfflineEditingVehicle ?
                                                qsTr("The vehicle associated with the plan in the Plan View is no longer available. What would you like to do with that plan?") :
                                                qsTr("The plan being worked on in the Plan View is not from the current vehicle. What would you like to do with that plan?")
                }

                QGCButton {
                    Layout.fillWidth:   true
                    text:               _planMasterController.dirty ?
                                            (_planMasterController.managerVehicle.isOfflineEditingVehicle ?
                                                 qsTr("Discard Unsaved Changes") :
                                                 qsTr("Discard Unsaved Changes, Load New Plan From Vehicle")) :
                                            qsTr("Load New Plan From Vehicle")
                    onClicked: {
                        _planMasterController.showPlanFromManagerVehicle()
                        _promptForPlanUsageShowing = false
                        close();
                    }
                }

                QGCButton {
                    Layout.fillWidth:   true
                    text:               _planMasterController.managerVehicle.isOfflineEditingVehicle ?
                                            qsTr("Keep Current Plan") :
                                            qsTr("Keep Current Plan, Don't Update From Vehicle")
                    onClicked: {
                        if (!_planMasterController.managerVehicle.isOfflineEditingVehicle) {
                            _planMasterController.dirty = true
                        }
                        _promptForPlanUsageShowing = false
                        close()
                    }
                }
            }
        }
    }

    PlanMasterController {
        id:         planMasterController
        flyView:    false

        Component.onCompleted: {
            _planMasterController.start()
            _missionController.setCurrentPlanViewSeqNum(0, true)
            globals.planMasterControllerPlanView = _planMasterController
        }

        onPromptForPlanUsageOnVehicleChange: {
            if (!_promptForPlanUsageShowing) {
                _promptForPlanUsageShowing = true
                promptForPlanUsageOnVehicleChangePopupComponent.createObject(mainWindow).open()
            }
        }

        function waitingOnIncompleteDataMessage(save) {
            var saveOrUpload = save ? qsTr("Save") : qsTr("Upload")
            mainWindow.showMessageDialog(qsTr("Unable to %1").arg(saveOrUpload), qsTr("Plan has incomplete items. Complete all items and %1 again.").arg(saveOrUpload))
        }

        function waitingOnTerrainDataMessage(save) {
            var saveOrUpload = save ? qsTr("Save") : qsTr("Upload")
            mainWindow.showMessageDialog(qsTr("Unable to %1").arg(saveOrUpload), qsTr("Plan is waiting on terrain data from server for correct altitude values."))
        }

        function checkReadyForSaveUpload(save) {
            if (readyForSaveState() == VisualMissionItem.NotReadyForSaveData) {
                waitingOnIncompleteDataMessage(save)
                return false
            } else if (readyForSaveState() == VisualMissionItem.NotReadyForSaveTerrain) {
                waitingOnTerrainDataMessage(save)
                return false
            }
            return true
        }

        function upload() {
            if (!checkReadyForSaveUpload(false /* save */)) {
                return
            }
            switch (_missionController.sendToVehiclePreCheck()) {
                case MissionController.SendToVehiclePreCheckStateOk:
                    sendToVehicle()
                    break
                case MissionController.SendToVehiclePreCheckStateActiveMission:
                    mainWindow.showMessageDialog(qsTr("Send To Vehicle"), qsTr("Current mission must be paused prior to uploading a new Plan"))
                    break
                case MissionController.SendToVehiclePreCheckStateFirwmareVehicleMismatch:
                    mainWindow.showMessageDialog(qsTr("Plan Upload"),
                                                 qsTr("This Plan was created for a different firmware or vehicle type than the firmware/vehicle type of vehicle you are uploading to. " +
                                                      "This can lead to errors or incorrect behavior. " +
                                                      "It is recommended to recreate the Plan for the correct firmware/vehicle type.\n\n" +
                                                      "Click 'Ok' to upload the Plan anyway."),
                                                 StandardButton.Ok | StandardButton.Cancel,
                                                 function() { _planMasterController.sendToVehicle() })
                    break
            }
        }

        function loadFromSelectedFile() {
            fileDialog.title =          qsTr("Select Plan File")
            fileDialog.planFiles =      true
            fileDialog.selectExisting = true
            fileDialog.nameFilters =    _planMasterController.loadNameFilters
            fileDialog.openForLoad()
        }

        function saveToSelectedFile() {
            if (!checkReadyForSaveUpload(true /* save */)) {
                return
            }
            fileDialog.title =          qsTr("Save Plan")
            fileDialog.planFiles =      true
            fileDialog.selectExisting = false
            fileDialog.nameFilters =    _planMasterController.saveNameFilters
            fileDialog.openForSave()
        }

        function fitViewportToItems() {
            mapFitFunctions.fitMapViewportToMissionItems()
        }

        function saveKmlToSelectedFile() {
            if (!checkReadyForSaveUpload(true /* save */)) {
                return
            }
            fileDialog.title =          qsTr("Save KML")
            fileDialog.planFiles =      false
            fileDialog.selectExisting = false
            fileDialog.nameFilters =    ShapeFileHelper.fileDialogKMLFilters
            fileDialog.openForSave()
        }
    }

    Connections {
        target: _missionController

        function onNewItemsFromVehicle() {
            if (_visualItems && _visualItems.count !== 1) {
                mapFitFunctions.fitMapViewportToMissionItems()
            }
            _missionController.setCurrentPlanViewSeqNum(0, true)
        }
    }

    function insertSimpleItemAfterCurrent(coordinate) {
        var nextIndex = _missionController.currentPlanViewVIIndex + 1
        _missionController.insertSimpleMissionItem(coordinate, nextIndex, true /* makeCurrentItem */)
    }

    function insertROIAfterCurrent(coordinate) {
        var nextIndex = _missionController.currentPlanViewVIIndex + 1
        _missionController.insertROIMissionItem(coordinate, nextIndex, true /* makeCurrentItem */)
    }

    function insertCancelROIAfterCurrent() {
        var nextIndex = _missionController.currentPlanViewVIIndex + 1
        _missionController.insertCancelROIMissionItem(nextIndex, true /* makeCurrentItem */)
    }

    function insertComplexItemAfterCurrent(complexItemName) {
        var nextIndex = _missionController.currentPlanViewVIIndex + 1
        _missionController.insertComplexMissionItem(complexItemName, mapCenter(), nextIndex, true /* makeCurrentItem */)
    }

    function insertTakeItemAfterCurrent() {
        var nextIndex = _missionController.currentPlanViewVIIndex + 1
        _missionController.insertTakeoffItem(mapCenter(), nextIndex, true /* makeCurrentItem */)
    }

    function insertLandItemAfterCurrent() {
        var nextIndex = _missionController.currentPlanViewVIIndex + 1
        _missionController.insertLandItem(mapCenter(), nextIndex, true /* makeCurrentItem */)
    }


    function selectNextNotReady() {
        var foundCurrent = false
        for (var i=0; i<_missionController.visualItems.count; i++) {
            var vmi = _missionController.visualItems.get(i)
            if (vmi.readyForSaveState === VisualMissionItem.NotReadyForSaveData) {
                _missionController.setCurrentPlanViewSeqNum(vmi.sequenceNumber, true)
                break
            }
        }
    }

    QGCFileDialog {
        id:             fileDialog
        folder:         _appSettings ? _appSettings.missionSavePath : ""

        property bool planFiles: true    ///< true: working with plan files, false: working with kml file

        onAcceptedForSave: {
            if (planFiles) {
                _planMasterController.saveToFile(file)
            } else {
                _planMasterController.saveToKml(file)
            }
            close()
        }

        onAcceptedForLoad: {
            _planMasterController.loadFromFile(file)
            _planMasterController.fitViewportToItems()
            _missionController.setCurrentPlanViewSeqNum(0, true)
            close()
        }
    }

    Item {
        id:             panel
        anchors.fill:   parent

        Rectangle{

        }

        FlightMap {
            id:                         editorMap
            anchors.fill:               parent
            mapName:                    "MissionEditor"
            allowGCSLocationCenter:     true
            allowVehicleLocationCenter: true
            planView:                   true

            zoomLevel:                  QGroundControl.flightMapZoom
            center:                     QGroundControl.flightMapPosition

            // This is the center rectangle of the map which is not obscured by tools
            property rect centerViewport:   Qt.rect(editorMap.x, editorMap.y, editorMap.width, editorMap.height )
            property real _nonInteractiveOpacity:  0.5

            // Initial map position duplicates Fly view position
            Component.onCompleted: editorMap.center = QGroundControl.flightMapPosition

            QGCMapPalette { id: mapPal; lightColors: editorMap.isSatelliteMap }

            onZoomLevelChanged: {
                QGroundControl.flightMapZoom = zoomLevel
            }
            onCenterChanged: {
                QGroundControl.flightMapPosition = center
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Take focus to close any previous editing
                    editorMap.focus = true
                    var coordinate = editorMap.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
                    coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
                    coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
                    coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)

                    switch (_editingLayer) {
                    case _layerMission:
                        if (addWaypointRallyPointAction.checked) {
                            insertSimpleItemAfterCurrent(coordinate)
                        } else if (_addROIOnClick) {
                            insertROIAfterCurrent(coordinate)
                            _addROIOnClick = false
                        }

                        break
                    case _layerRallyPoints:
                        if (_rallyPointController.supported && addWaypointRallyPointAction.checked) {
                            _rallyPointController.addPoint(coordinate)
                        }
                        break
                    }
                }
            }

            // Add the mission item visuals to the map
            Repeater {
                model: _missionController.visualItems
                delegate: MissionItemMapVisual {
                    map:         editorMap
                    onClicked:   _missionController.setCurrentPlanViewSeqNum(sequenceNumber, false)
                    opacity:     _editingLayer == _layerMission ? 1 : editorMap._nonInteractiveOpacity
                    interactive: _editingLayer == _layerMission
                    vehicle:     _planMasterController.controllerVehicle
                }
            }

            // Add lines between waypoints
            MissionLineView {
                showSpecialVisual:  _missionController.isROIBeginCurrentItem
                model:              _missionController.simpleFlightPathSegments
                opacity:            _editingLayer == _layerMission ? 1 : editorMap._nonInteractiveOpacity
            }

            // Direction arrows in waypoint lines
            MapItemView {
                model: _editingLayer == _layerMission ? _missionController.directionArrows : undefined

                delegate: MapLineArrow {
                    fromCoord:      object ? object.coordinate1 : undefined
                    toCoord:        object ? object.coordinate2 : undefined
                    arrowPosition:  3
                    z:              QGroundControl.zOrderWaypointLines + 1
                }
            }

            // Incomplete segment lines
            MapItemView {
                model: _missionController.incompleteComplexItemLines

                delegate: MapPolyline {
                    path:       [ object.coordinate1, object.coordinate2 ]
                    line.width: 1
                    line.color: "red"
                    z:          QGroundControl.zOrderWaypointLines
                    opacity:    _editingLayer == _layerMission ? 1 : editorMap._nonInteractiveOpacity
                }
            }

            // UI for splitting the current segment
            MapQuickItem {
                id:             splitSegmentItem
                anchorPoint.x:  sourceItem.width / 2
                anchorPoint.y:  sourceItem.height / 2
                z:              QGroundControl.zOrderWaypointLines + 1
                visible:        _editingLayer == _layerMission

                sourceItem: SplitIndicator {
                    onClicked:  _missionController.insertSimpleMissionItem(splitSegmentItem.coordinate,
                                                                           _missionController.currentPlanViewVIIndex,
                                                                           true /* makeCurrentItem */)
                }

                function _updateSplitCoord() {
                    if (_missionController.splitSegment) {
                        var distance = _missionController.splitSegment.coordinate1.distanceTo(_missionController.splitSegment.coordinate2)
                        var azimuth = _missionController.splitSegment.coordinate1.azimuthTo(_missionController.splitSegment.coordinate2)
                        splitSegmentItem.coordinate = _missionController.splitSegment.coordinate1.atDistanceAndAzimuth(distance / 2, azimuth)
                    } else {
                        coordinate = QtPositioning.coordinate()
                    }
                }

                Connections {
                    target:                 _missionController
                    function onSplitSegmentChanged()  { splitSegmentItem._updateSplitCoord() }
                }

                Connections {
                    target:                 _missionController.splitSegment
                    function onCoordinate1Changed()   { splitSegmentItem._updateSplitCoord() }
                    function onCoordinate2Changed()   { splitSegmentItem._updateSplitCoord() }
                }
            }

            // Add the vehicles to the map
            MapItemView {
                model: QGroundControl.multiVehicleManager.vehicles
                delegate: VehicleMapItem {
                    vehicle:        object
                    coordinate:     object.coordinate
                    map:            editorMap
                    size:           ScreenTools.defaultFontPixelHeight * 3
                    z:              QGroundControl.zOrderMapItems - 1
                }
            }

            GeoFenceMapVisuals {
                map:                    editorMap
                myGeoFenceController:   _geoFenceController
                interactive:            _editingLayer == _layerGeoFence
                homePosition:           _missionController.plannedHomePosition
                planView:               true
                opacity:                _editingLayer != _layerGeoFence ? editorMap._nonInteractiveOpacity : 1
            }

            RallyPointMapVisuals {
                map:                    editorMap
                myRallyPointController: _rallyPointController
                interactive:            _editingLayer == _layerRallyPoints
                planView:               true
                opacity:                _editingLayer != _layerRallyPoints ? editorMap._nonInteractiveOpacity : 1
            }
        }


        //-----------------------------------------------------------
        // Right pane for mission editing controls
        Rectangle {
            id:                 rightPanel
            height:             parent.height
            width:              _rightPanelWidth
            color:              qgcPal.window
            opacity:            layerTabBar.visible ? 0.2 : 0
            anchors.bottom:     parent.bottom
            anchors.right:      parent.right
            anchors.rightMargin: _toolsMargin
        }
        //-------------------------------------------------------
        // Right Panel Controls
        Item {
            anchors.fill:           rightPanel
            anchors.topMargin:      _toolsMargin
            visible : true

            DeadMouseArea {
                anchors.fill:   parent
            }
            Column {
                id:                 rightControls
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                anchors.left:       parent.left
                anchors.right:      parent.right
                anchors.top:        parent.top
                //-------------------------------------------------------
                // Mission Controls (Expanded)
                QGCTabBar {
                    id:         layerTabBar
                    width:      parent.width
                    visible:    QGroundControl.corePlugin.options.enablePlanViewSelector
                    Component.onCompleted: currentIndex = 0
                    QGCTabButton {
                        text:       qsTr("���� �ӹ�")
                    }
                }
            }
            //-------------------------------------------------------
            // Mission Item Editor
            Item {
                id:                     missionItemEditor
                anchors.left:           parent.left
                anchors.right:          parent.right
                anchors.top:            rightControls.bottom
                anchors.topMargin:      ScreenTools.defaultFontPixelHeight * 0.25
                anchors.bottom:         parent.bottom
                anchors.bottomMargin:   ScreenTools.defaultFontPixelHeight * 0.25
                visible:                _editingLayer == _layerMission && !planControlColapsed
                QGCListView {
                    id:                 missionItemEditorListView
                    anchors.fill:       parent
                    spacing:            ScreenTools.defaultFontPixelHeight / 4
                    orientation:        ListView.Vertical
                    model:              _missionController.visualItems
                    cacheBuffer:        Math.max(height * 2, 0)
                    clip:               true
                    currentIndex:       _missionController.currentPlanViewSeqNum
                    highlightMoveDuration: 250
                    visible:            _editingLayer == _layerMission && !planControlColapsed
                    //-- List Elements
                    delegate: MissionItemEditor {
                        map:            editorMap
                        masterController:  _planMasterController
                        missionItem:    object
                        width:          missionItemEditorListView.width
                        readOnly:       false
                        onClicked:      _missionController.setCurrentPlanViewSeqNum(object.sequenceNumber, false)
                        onRemove: {
                            var removeVIIndex = index
                            _missionController.removeVisualItem(removeVIIndex)
                            if (removeVIIndex >= _missionController.visualItems.count) {
                                removeVIIndex--
                            }
                        }
                        onSelectNextNotReadyItem:   selectNextNotReady()
                    }
                }
            }
            // GeoFence Editor
            GeoFenceEditor {
                anchors.top:            rightControls.bottom
                anchors.topMargin:      ScreenTools.defaultFontPixelHeight * 0.25
                anchors.bottom:         parent.bottom
                anchors.left:           parent.left
                anchors.right:          parent.right
                myGeoFenceController:   _geoFenceController
                flightMap:              editorMap
                visible:                _editingLayer == _layerGeoFence
            }

            // Rally Point Editor
            RallyPointEditorHeader {
                id:                     rallyPointHeader
                anchors.top:            rightControls.bottom
                anchors.topMargin:      ScreenTools.defaultFontPixelHeight * 0.25
                anchors.left:           parent.left
                anchors.right:          parent.right
                visible:                _editingLayer == _layerRallyPoints
                controller:             _rallyPointController
            }
            RallyPointItemEditor {
                id:                     rallyPointEditor
                anchors.top:            rallyPointHeader.bottom
                anchors.topMargin:      ScreenTools.defaultFontPixelHeight * 0.25
                anchors.left:           parent.left
                anchors.right:          parent.right
                visible:                _editingLayer == _layerRallyPoints && _rallyPointController.points.count
                rallyPoint:             _rallyPointController.currentRallyPoint
                controller:             _rallyPointController
            }
        }

        QGCLabel {
            // Elevation provider notice on top of terrain plot
            readonly property string _licenseString: QGroundControl.elevationProviderNotice

            id:                         licenseLabel
            visible:                    terrainStatus.visible && _licenseString !== ""
            anchors.bottom:             terrainStatus.top
            anchors.horizontalCenter:   terrainStatus.horizontalCenter
            anchors.bottomMargin:       ScreenTools.defaultFontPixelWidth * 0.5
            font.pointSize:             ScreenTools.smallFontPointSize
            text:                       qsTr("Powered by %1").arg(_licenseString)
        }

        TerrainStatus {
            id:                 terrainStatus
            anchors.margins:    _toolsMargin
            anchors.leftMargin: 0
            anchors.left:       mapScale.left
            anchors.right:      rightPanel.left
            anchors.bottom:     parent.bottom
            height:             ScreenTools.defaultFontPixelHeight * 7
            missionController:  _missionController
            visible:            false

            onSetCurrentSeqNum: _missionController.setCurrentPlanViewSeqNum(seqNum, true)

            property bool _internalVisible: _planViewSettings.showMissionItemStatus.rawValue

            function toggleVisible() {
                _internalVisible = !_internalVisible
                _planViewSettings.showMissionItemStatus.rawValue = _internalVisible
            }
        }

        MapScale {
            id:                     mapScale
            anchors.margins:        _toolsMargin
            anchors.top:            parent.top
            anchors.left:           parent.left
            mapControl:             editorMap
            buttonsOnLeft:          true
        }

        Row {
            id:                     bottomPanel
            height:                 _bottomPanelHeight + _bottomPanelMargin * 2

            anchors.left:           parent.left
            anchors.right:          parent.right
            anchors.bottom:         parent.bottom
            anchors.topMargin:      _bottomPanelMargin
        }

        Row{
            anchors.centerIn: bottomPanel
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
                           ListElement{name: qsTr("?? ???")}
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
                                        console.log("if(model.index === _initPlan)")
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
                            checked :               false

                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    if(addWaypointRallyPointAction.checked === true){
                                        addWaypointRallyPointAction.checked = false

                                    }else{
                                        if (isScan() && _mapPolys.traceMode) {
                                            if ( _mapPolys.count < _currentPlan ) {
                                                _restorePreviousVertices()
                                            }
                                            _mapPolys.traceMode = false
                                            tracingButton.checked = false
                                        }
                                        addWaypointRallyPointAction.checked = true
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
                                        addWaypointRallyPointAction.checked = false

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
                                addWaypointRallyPointAction.checked = false
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

                            property string _overwriteText: (_editingLayer == _layerMission) ? qsTr("Mission overwrite") : ((_editingLayer == _layerGeoFence) ? qsTr("GeoFence overwrite") : qsTr("Rally Points overwrite"))
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

    function showLoadFromFileOverwritePrompt(title) {
        mainWindow.showMessageDialog(title,
                                     qsTr("You have unsaved/unsent changes. Loading from a file will lose these changes. Are you sure you want to load from a file?"),
                                     StandardButton.Yes | StandardButton.Cancel,
                                     function() { _planMasterController.loadFromSelectedFile() } )
    }

    property var createPlanRemoveAllPromptDialogMapCenter
    property var createPlanRemoveAllPromptDialogPlanCreator
    
    property int clickPlanIndex : 0

    Component {
        id: clearVehicleMissionDialog
        QGCSimpleMessageDialog {
	    title:      ""
            text:       qsTr("Are you sure you want to remove all mission items and clear the mission from the vehicle?")
            buttons:    StandardButton.Yes | StandardButton.No

            onAccepted: {
                _planMasterController.removeAllFromVehicle()
                _missionController.setCurrentPlanViewSeqNum(0, true)
                addWaypointRallyPointAction.checked = false                
            }
        }
    }

    function clearButtonClicked() {
        mainWindow.showMessageDialog(qsTr("Clear"),
                                     qsTr("Are you sure you want to remove all mission items and clear the mission from the vehicle?"),
                                     StandardButton.Yes | StandardButton.Cancel,
                                     function() { _planMasterController.removeAllFromVehicle(); _missionController.setCurrentPlanViewSeqNum(0, true) })
    }

    //- ToolStrip DropPanel Components

    Component {
        id: centerMapDropPanel

        CenterMapDropPanel {
            map:            editorMap
            fitFunctions:   mapFitFunctions
        }
    }

    Component {
        id: patternDropPanel

        ColumnLayout {
            spacing:    ScreenTools.defaultFontPixelWidth * 0.5

            QGCLabel { text: qsTr("Create complex pattern:") }

            Repeater {
                model: _missionController.complexMissionItemNames

                QGCButton {
                    text:               modelData
                    Layout.fillWidth:   true

                    onClicked: {
                        insertComplexItemAfterCurrent(modelData)
                        dropPanel.hide()
                    }
                }
            }
        } // Column
    }

    function downloadClicked(title) {
        if (_planMasterController.dirty) {
            mainWindow.showMessageDialog(title,
                                         qsTr("You have unsaved/unsent changes. Loading from the Vehicle will lose these changes. Are you sure you want to load from the Vehicle?"),
                                         StandardButton.Yes | StandardButton.Cancel,
                                         function() { _planMasterController.loadFromVehicle() })
        } else {
            _planMasterController.loadFromVehicle()
        }
    }

}

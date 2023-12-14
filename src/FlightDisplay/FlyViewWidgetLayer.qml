/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

// This is the ui overlay layer for the widgets/tools for Fly View
Item {
    id: _root

    property var    parentToolInsets
    property var    totalToolInsets:        _totalToolInsets
    property var    mapControl

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _planMasterController:  globals.planMasterControllerFlyView
    property var    _missionController:     _planMasterController.missionController
    property var    _geoFenceController:    _planMasterController.geoFenceController
    property var    _rallyPointController:  _planMasterController.rallyPointController
    property var    _guidedController:      globals.guidedControllerFlyView
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property alias  _gripperMenu:           gripperOptions

    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + "black" + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }


    //---------------------------

    property string _sailMode:              _activeVehicle ? _activeVehicle.flightMode : ""
    property bool   _communicationLost:     _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _statusTextColor:       "white"
    property real   _statusTextFontSize:    ScreenTools.mediumFontPointSize

    function checkMode(){
        switch(_sailMode){
        case "Manual":
            manualButton.checked = true
            break;
        case "Auto":
            autoButton.checked = true;
            break;
        case "Loiter":
            loiterButton.checked = true;
            break;
        default:
            manualButton.checked = false;
            autoButton.checked = false;
            loiterButton.checked = false;

            break;
        }
    }

    on_SailModeChanged: {
        checkMode();
    }

    on_ActiveVehicleChanged: {
        _activeVehicle ? switchCirle.state = "leftOff" : switchCirle.state = "disActiveVehicle"
    }

    property bool   _vehicleArmed:          _activeVehicle ? _activeVehicle.armed  : false
    on_VehicleArmedChanged: {
        _vehicleArmed ? switchCirle.state = "rightOn" : switchCirle.state = "leftOff"
    }

    function showPanel() {
        panelLoader.setSource()
    }

    //---------------------------

    QGCToolInsets {
        id:                     _totalToolInsets
        leftEdgeBottomInset:    parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset:   parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset:   parentToolInsets.rightEdgeBottomInset
        topEdgeLeftInset:       parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset:     parentToolInsets.topEdgeCenterInset
        topEdgeRightInset:      parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset:    parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  mapScale.topEdgeCenterInset
        bottomEdgeRightInset:   0
    }

    FlyViewMissionCompleteDialog {
        missionController:      _missionController
        geoFenceController:     _geoFenceController
        rallyPointController:   _rallyPointController
    }

    Row {
        id:                 multiVehiclePanelSelector
        anchors.margins:    _toolsMargin
        anchors.top:        parent.top
        anchors.right:      parent.right
        width:              _rightPanelWidth
        spacing:            ScreenTools.defaultFontPixelWidth
        visible:            QGroundControl.multiVehicleManager.vehicles.count > 1 && QGroundControl.corePlugin.options.flyView.showMultiVehicleList

        property bool showSingleVehiclePanel:  !visible || singleVehicleRadio.checked

        QGCMapPalette { id: mapPal; lightColors: true }

        QGCRadioButton {
            id:             singleVehicleRadio
            text:           qsTr("Single")
            checked:        true
            textColor:      mapPal.text
        }

        QGCRadioButton {
            text:           qsTr("Multi-Vehicle")
            textColor:      mapPal.text
        }
    }

    MultiVehicleList {
        anchors.margins:    _toolsMargin
        anchors.top:        multiVehiclePanelSelector.bottom
        anchors.right:      parent.right
        width:              _rightPanelWidth
        height:             parent.height - y - _toolsMargin
        visible:            !multiVehiclePanelSelector.showSingleVehiclePanel
    }


    GuidedActionConfirm {
        anchors.margins:            _toolsMargin
        anchors.top:                parent.top
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        guidedValueSlider:          _guidedValueSlider
    }

    Rectangle {
        id:                     bottomPanel
        width:                  parent.width
        height:                 _bottomPanelHeight + _bottomPanelMargin * 2
        anchors.bottom:         parent.bottom
        color: "transparent"
        DeadMouseArea {
            anchors.fill:   parent
        }
    }

    Row {
        anchors.centerIn:       bottomPanel
        spacing:               _bottomPanelLeftPadding

        TelemetryValuesBar {
            id:                 telemetryPanel
        }

        Rectangle {
            id:                 customWeatherPanel
            height:             _bottomPanelHeight
            width:              _bottomPanelWidth
            color:              "transparent"
            
            Rectangle{
                anchors.fill:       parent
                color:              qgcPal.window
                opacity:            0.8
                radius:             _bottomPanelRadious
            }
        }

        Rectangle {
            id:                     customArmPanel
            height:                 _bottomPanelHeight
            width:                  (_bottomPanelWidth/2 - 4)
            color:                  "transparent"

            Rectangle{
                anchors.fill:       parent
                color:              qgcPal.window
                opacity:            0.8
                radius:             _bottomPanelRadious
            }

            Column {
                anchors.fill:       parent
                spacing:            _bottomPanelTopPadding/2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins:    _bottomPanelMargin

                QGCLabel{
                    id :                        customStatusLabel
                    text:                       customMainStatusText()
//                    font.pointSize:             ScreenTools.defaultFontPointSize
                    font.pointSize:             _statusTextFontSize
                    font.bold :                 true
                    color:                      _statusTextColor
                    anchors.horizontalCenter:   parent.horizontalCenter


                    property string _commLostText:      qsTr("Communication Lost")
                    property string _readyToSailText:   qsTr("Ready To Sail")
                    property string _notReadyToSailText: qsTr("Not Ready")
                    property string _disconnectedText:  qsTr("Disconnected")
                    property string _armedText:         qsTr("Armed")
                    property string _sailingText:       qsTr("Sailing")
                    property string _waitingText:       qsTr("Waiting")

                    function customMainStatusText() {
                        if (_activeVehicle) {
                            if (_communicationLost) {
                                _statusTextColor = "red"
                                _statusTextFontSize = ScreenTools.defaultFontPointSize
                                return customStatusLabel._commLostText
                            }
                            if (_activeVehicle.armed) {
                                _statusTextColor = "green"
                                _statusTextFontSize = ScreenTools.mediumFontPointSize
                                if (_activeVehicle.flying) {
                                    return customStatusLabel._sailingText
                                } else if (_activeVehicle.landing) {
                                    return customStatusLabel._waitingText
                                } else {
                                    return customStatusLabel._armedText
                                }
                            } else {
                                _statusTextFontSize = ScreenTools.mediumFontPointSize
                                if (_activeVehicle.readyToFlyAvailable) {
                                    if (_activeVehicle.readyToFly) {
                                        _statusTextColor = "green"
                                        return customStatusLabel._readyToSailText
                                    } else {
                                        _statusTextColor = "yellow"
                                        return customStatusLabel._notReadyToSailText
                                    }
                                } else {
                                    // Best we can do is determine readiness based on AutoPilot component setup and health indicators from SYS_STATUS
                                    if (_activeVehicle.allSensorsHealthy && _activeVehicle.autopilot.setupComplete) {
                                        _statusTextColor = "green"
                                        return customStatusLabel._readyToSailText
                                    } else {
                                        _statusTextColor = "yellow"
                                        return customStatusLabel._notReadyToSailText
                                    }
                                }
                            }
                        } else {
                            _statusTextColor = "gray"
                            _statusTextFontSize = ScreenTools.mediumFontPointSize
                            return customStatusLabel._disconnectedText
                        }
                    }
                }

                Rectangle{
                    id: armswitch
                    color: "transparent"
                    width: parent.width * 0.9
                    height: width / 2
                    anchors.horizontalCenter:   parent.horizontalCenter
                    enabled: _activeVehicle

                    Rectangle{
                        id:roundRectangle
                        width: parent.width * 0.8
                        height:parent.height * 0.5
                        radius: height
                        color: "white"
                        anchors.centerIn: parent

                        QGCLabel{
                            text:           qsTr("ON")
                            font.pointSize: ScreenTools.mediumFontPointSize
                            font.bold :     true
                            color : switchCirle.state == "disActiveVehicle" ? "gray" : "black"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 7
                        }

                        QGCLabel{
                            text:           qsTr("OFF")
                            font.pointSize: ScreenTools.mediumFontPointSize
                            font.bold :     true
                            color : switchCirle.state == "disActiveVehicle" ? "gray" : "black"
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 7
                        }
                    }

                    Rectangle{
                        id: switchCirle
                        width: parent.height
                        height:width
                        radius: height
                        anchors.verticalCenter: parent.verticalCenter
                        state : "leftOff"

                        states:[

                            State {
                                name: "disActiveVehicle"
                                PropertyChanges {
                                    target: switchCirle;
                                    color: "gray";
                                }
                                AnchorChanges{
                                    target: switchCirle;
                                    anchors.left: parent.left
                                }
                            },
                            State {
                                name: "leftOff"
                                PropertyChanges {
                                    target: switchCirle;
                                    color: "red";
                                }
                                AnchorChanges{
                                    target: switchCirle;
                                    anchors.left: parent.left
                                }
                            },
                            State {
                                name: "rightOn"
                                PropertyChanges {
                                    target: switchCirle;
                                    color: "#00DC30";
                                }
                                AnchorChanges{
                                    target: switchCirle;
                                    anchors.right: parent.right
                                }
                            }
                        ]
                    }

                    MouseArea{
                        anchors.fill: parent

                        readonly property int actionArm:                        4
                        readonly property int actionDisarm:                     5
                        readonly property int actionStartMission:               12
                        readonly property int actionResumeMission:              14

                        hoverEnabled : true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                             switchCirle.state == "leftOff" ? _guidedController.executeAction(actionArm) : _guidedController.executeAction(actionDisarm)
                        }
                    }
                }

                QGCLabel{
                    text:           qsTr("수신 감도")
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold :     true
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel{
                    id:             rssiValue
                    text:           _activeVehicle ? (_activeVehicle.rcRSSI + " " + "%") : 0
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold :     true
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel{
                    text:           qsTr("배터리 잔량")
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold :     true
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel{
                    property var    _batteryGroup:                  globals.activeVehicle && globals.activeVehicle.batteries.count ? globals.activeVehicle.batteries.get(0) : undefined
                    property var    _batteryValue:                  _batteryGroup ? _batteryGroup.percentRemaining.value : 0
                    property var    _batPercentRemaining:           isNaN(_batteryValue) ? 0 : _batteryValue

                    id:             batteryValue
                    text:           _batPercentRemaining !== 0 ? _batPercentRemaining + " " + _batteryGroup.percentRemaining.units : 0

                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold :     true
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }
        }            

        FlyViewInstrumentPanel {
            id:                         instrumentPanel
            anchors.margins:            _bottomPanelMargin
            width:                      _bottomPanelHeight / 2
            visible:                    QGroundControl.corePlugin.options.flyView.showInstrumentPanel && multiVehiclePanelSelector.showSingleVehiclePanel
            availableHeight:            parent.height - y - _toolsMargin

            property real rightEdgeTopInset: visible ? parent.width - x : 0
            property real topEdgeRightInset: visible ? y + height : 0
        }

        Column {
            spacing: _bottomPanelMargin

            Rectangle {
                id:                     customModePanel
                height:                 67
                width:                  _bottomPanelWidth * 2 + 12
                color:                  "transparent"

                Rectangle{
                    anchors.fill:       parent
                    color:              qgcPal.window
                    opacity:            0.8
                    radius:             _bottomPanelRadious
                }

                Row {
                    anchors.fill:       parent
                    spacing:            _bottomPanelLeftPadding
                    anchors.margins:    _bottomPanelMargin

                    QGCLabel {
                        id : modeLabel
                        text: "운항모드"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize:     ScreenTools.mediumFontPointSize
                    }

                    Rectangle {
                        id : buttonWarp
                        width : parent.width - modeLabel.width - _bottomPanelMargin
                        height: parent.height
                        anchors.leftMargin: _bottomPanelMargin
                        color: "transparent"

                        Row {
                            anchors.fill:       parent
                            spacing: _bottomPanelLeftPadding

                            ButtonGroup {
                                id : modeButtonGroup
                            }

                            QGCButton {
                                id:                 manualButton
                                width :             (buttonWarp.width - _bottomPanelLeftPadding * 2)/3
                                height :            buttonWarp.height
                                backRadius :        height

                                text:               "Manual"
                                pointSize :         ScreenTools.mediumFontPointSize

                                ButtonGroup.group:  modeButtonGroup
                                enabled :           _activeVehicle

                                onClicked: {
                                    _activeVehicle.flightMode = manualButton.text
                                }
                            }

                            QGCButton {
                                id:                 autoButton
                                width :             (buttonWarp.width - _bottomPanelLeftPadding * 2)/3
                                height :            buttonWarp.height
                                backRadius :        height

                                text:               "Auto"
                                pointSize :         ScreenTools.mediumFontPointSize

                                ButtonGroup.group:  modeButtonGroup
                                enabled :           _activeVehicle

                                onClicked: {
                                    _activeVehicle.flightMode = autoButton.text
                                }
                            }

                            QGCButton {
                                id:                 loiterButton
                                width :             (buttonWarp.width - _bottomPanelLeftPadding * 2)/3
                                height :            buttonWarp.height
                                backRadius :        height

                                text:               "Loiter"
                                pointSize :         ScreenTools.mediumFontPointSize

                                ButtonGroup.group:  modeButtonGroup
                                enabled :           _activeVehicle

                                onClicked: {
                                    _activeVehicle.flightMode = loiterButton.text
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id:                     customStatusInformPanel
                height:                 157

                width:                  _bottomPanelWidth * 2 + 12
                color:                  "transparent"

                Rectangle {
                    anchors.fill:       parent
                    color:              qgcPal.window
                    opacity:            0.8
                    radius:             _bottomPanelRadious
                }


                Column {
                    anchors.fill: parent
                    anchors.margins: _bottomPanelMargin
                    spacing: 10

                    Row {
                        spacing: _bottomPanelLeftPadding

                        QGCLabel {
                            text: "센서정보"
                            font.pointSize:     ScreenTools.mediumFontPointSize
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.topMargin: _bottomPanelMargin
                        }

                        Grid {
                            columns:                    3
                            rowSpacing:                 0
                            columnSpacing:              _bottomPanelLeftPadding

                            //_activeVehicle.sysStatusSensorInfo.sensorNames :
                            //[ AHRS, Pre-Arm Check, Gyro, Accelerometer, Magnetometer,
                            //  Absolute pressure, Battery, Angular rate control, Attitude stabilization, Yaw position,
                            //  X/Y position control, Motor outputs / control, GeoFence, Logging ]
                            ListModel {
                               id: sensorNames
                               ListElement{name: "AHRS";                    index: 0; }
                               ListElement{name: "Pre-Arm Check";           index: 1; }
                               ListElement{name: "Gyro";                    index: 2; }
                               ListElement{name: "Accelerometer";           index: 3; }
                               ListElement{name: "Magnetometer";            index: 4; }
                               ListElement{name: "Angular rate control";    index: 7; }
                            }

                            Repeater {
                                model :sensorNames

                                QGCLabel {
                                    text:           name
                                    font.pointSize: ScreenTools.mediumFontPointSize
                                    color:          !_activeVehicle || (_activeVehicle.sysStatusSensorInfo.sensorStatus[index] === "Disabled" ||
                                                                        (_activeVehicle.sysStatusSensorInfo.sensorStatus[index] === "비활성화" ))?
                                                    "gray" :  (_activeVehicle.sysStatusSensorInfo.sensorStatus[index] === "Normal" ||
                                                               _activeVehicle.sysStatusSensorInfo.sensorStatus[index] === "보통") ? "#00DC30" : "red"
                                }
                            }
                        }
                    }

                    Rectangle {
                        id:                     customMessagesPanel
                        height:                 68
                        width:                  customStatusInformPanel.width - (_bottomPanelLeftPadding * 2)
                        color:                  "white"

                        Item {
                            id:                     customMessages
                            anchors.fill:           parent

                            Connections {
                                target: _activeVehicle
                                onNewFormattedMessage :{
                                    messageText.append(formatMessage(formattedMessage))

                                    //-- Hack to scroll to last message
                                    //-- Hack to scroll down
                                    messageFlick.flick(0,-500)
                                }
                            }

                            QGCLabel {
                                anchors.centerIn:   parent
                                text:               qsTr("No Messages")
                                visible:            messageText.length === 0
                                color:              "black"
                            }

                            QGCFlickable {
                                id:                 messageFlick
                                anchors.margins:    ScreenTools.defaultFontPixelHeight/2
                                anchors.fill:       parent
                                contentHeight:      messageText.height
                                contentWidth:       messageText.width
                                pixelAligned:       true
                                indicatorColor :    "black"

                                MouseArea {
                                    anchors.fill: parent
                                }

                                TextEdit {
                                    id:             messageText
                                    readOnly:       true
                                    textFormat:     TextEdit.RichText
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id:                     customServoOutPutPanel
            height:                 _bottomPanelHeight

            width:                  _bottomPanelWidth
            color:                  "transparent"

            visible: QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable

            Rectangle{
                anchors.fill:       parent
                color:              qgcPal.window
                opacity:            0.8
                radius:             _bottomPanelRadious
            }

            Connections {
                target: QGroundControl.multiVehicleManager

                onParameterReadyVehicleAvailableChanged: {
//                    console.log("Connections // onParameterReadyVehicleAvailableChanged")
                    if (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable) {
                        panelLoader.setSource("qrc:/qml/QGroundControl/Controls/ServoOutPutDialog.qml")
                    }else{
                        panelLoader.setSource("")
                    }
                }
            }

            Loader {
                id:             panelLoader
                anchors.fill:   parent
                anchors.margins: _bottomPanelMargin

                function setSource(source) {
                    panelLoader.source = source
                }
            }

        }
    }

    //-- Virtual Joystick
    Loader {
        id:                         virtualJoystickMultiTouch
        z:                          QGroundControl.zOrderTopMost + 1
        width:                      parent.width  - (_pipOverlay.width / 2)
        height:                     Math.min(parent.height * 0.25, ScreenTools.defaultFontPixelWidth * 16)
        visible:                    _virtualJoystickEnabled && !QGroundControl.videoManager.fullScreen && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)
        anchors.bottom:             parent.bottom
        anchors.bottomMargin:       parentToolInsets.leftEdgeBottomInset + ScreenTools.defaultFontPixelHeight * 2
        anchors.horizontalCenter:   parent.horizontalCenter
        source:                     "qrc:/qml/VirtualJoystick.qml"
        active:                     _virtualJoystickEnabled && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)

        property bool autoCenterThrottle: QGroundControl.settingsManager.appSettings.virtualJoystickAutoCenterThrottle.rawValue

        property bool _virtualJoystickEnabled: QGroundControl.settingsManager.appSettings.virtualJoystick.rawValue

        property real bottomEdgeLeftInset: parent.height-y
        property real bottomEdgeRightInset: parent.height-y

        // Width is difficult to access directly hence this hack which may not work in all circumstances
        property real leftEdgeBottomInset: visible ? bottomEdgeLeftInset + width/18 - ScreenTools.defaultFontPixelHeight*2 : 0
        property real rightEdgeBottomInset: visible ? bottomEdgeRightInset + width/18 - ScreenTools.defaultFontPixelHeight*2 : 0
    }

    GripperMenu {
        id: gripperOptions
    }

    VehicleWarnings {
        anchors.centerIn:   parent
        z:                  QGroundControl.zOrderTopMost
    }

    MapScale {
        id:                 mapScale
        anchors.margins:    _toolsMargin
        anchors.left:       parent.left
        anchors.top:        parent.top
        mapControl:         _mapControl
        buttonsOnLeft:      true
        visible:            !ScreenTools.isTinyScreen && QGroundControl.corePlugin.options.flyView.showMapScale && mapControl.pipState.state === mapControl.pipState.fullState

        property real topEdgeCenterInset: visible ? y + height : 0
    }

    Component {
        id: preFlightChecklistPopup
        FlyViewPreFlightChecklistPopup {
        }
    }
}

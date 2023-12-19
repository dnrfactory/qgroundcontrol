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
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

Item {
    id: _root
    
    readonly property real  _bottomPanelWidth:          ScreenTools.defaultFontPixelWidth * 35                  // Width        : 280
    readonly property real  _bottomPanelHeight:         ScreenTools.defaultFontPixelWidth * 30                  // Height       : 240

    readonly property real  _bottomPanelButtonWidth:    _bottomPanelWidth - (_bottomPanelMargin * 2)            // Width        : 248
    readonly property real  _bottomPanelButtonHeight:   (_bottomPanelHeight - (_bottomPanelTopPadding * 5))/4   // Height       : 35

    readonly property real  _bottomPanelMargin:         ScreenTools.defaultFontPixelWidth * 2                  // Margin       : 16

    readonly property real  _bottomPanelLeftPadding:    ScreenTools.defaultFontPixelWidth * 2                 // LeftPadding  : 16
    readonly property real  _bottomPanelTopPadding:     ScreenTools.defaultFontPixelWidth * 2.5                 // TopPadding   : 20

    readonly property real  _bottomPanelRadious:        ScreenTools.defaultFontPixelWidth * 1.25

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property string _sailMode:              _activeVehicle ? _activeVehicle.flightMode : ""
    property bool   _communicationLost:     _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _statusTextColor:       "white"
    property real   _statusTextFontSize:    ScreenTools.mediumFontPointSize

    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + "black" + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

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

    Item {
        id:                     bottomPanel
        width:                  parent.width
        height:                 _bottomPanelHeight + _bottomPanelMargin * 2
        anchors.bottom:         parent.bottom
        DeadMouseArea {
            anchors.fill:       parent
        }
    }

    Row {
        anchors.centerIn:       bottomPanel
        spacing:               _bottomPanelLeftPadding

        TelemetryValuesBar {
            id:                 telemetryPanel
        }

        CustomWeatherPanel {
            id:                 customWeatherPanel
            height:             _bottomPanelHeight
            width:              _bottomPanelWidth
            radius:             _bottomPanelRadious
        }

        CustomArmPanel {
            id:                 customArmPanel
            height:             _bottomPanelHeight
            width:              (_bottomPanelWidth/2 - 4)
            radius:             _bottomPanelRadious

            _bottomPanelTopPadding: _root._bottomPanelTopPadding
            _bottomPanelMargin: _root._bottomPanelMargin
        }

        FlyViewInstrumentPanel {
            id:                         instrumentPanel
            anchors.margins:            _bottomPanelMargin
            width:                      _bottomPanelHeight / 2
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
}

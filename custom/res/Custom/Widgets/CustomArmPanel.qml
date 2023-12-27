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

Rectangle {
    id: root

    property real  _bottomPanelTopPadding: 20
    property real  _bottomPanelMargin: 20
    
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property color  _statusTextColor:       "white"
    property real   _statusTextFontSize:    ScreenTools.mediumFontPointSize
    
    height:                 _bottomPanelHeight
    width:                  (_bottomPanelWidth/2 - 4)
    color:                  qgcPal.window
    opacity:                0.8

    on_ActiveVehicleChanged: {
        _activeVehicle ? switchCirle.state = "leftOff" : switchCirle.state = "disActiveVehicle"
    }

    property bool _vehicleArmed: _activeVehicle ? _activeVehicle.armed : false
    on_VehicleArmedChanged: {
        _vehicleArmed ? switchCirle.state = "rightOn" : switchCirle.state = "leftOff"
    }

    Column {
        spacing:            _bottomPanelTopPadding/2
        anchors.centerIn: parent
        anchors.margins:    _bottomPanelMargin

        QGCLabel{
            id :                        customStatusLabel
            text:                       customMainStatusText()
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

        Rectangle {
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

            Rectangle {
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

            MouseArea {
                anchors.fill: parent

                readonly property int actionArm: 4
                readonly property int actionDisarm: 5
                readonly property int actionStartMission: 12
                readonly property int actionResumeMission: 14

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    switchCirle.state == "leftOff" ? _guidedController.executeAction(actionArm) : _guidedController.executeAction(actionDisarm)
                }
            }
        }

        QGCButton {
            width: root.width * 0.8
            height: width / 3
            backRadius: 10
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: _activeVehicle
            text: qsTr("Pause")
            pointSize: ScreenTools.mediumFontPointSize
            onClicked: {
                console.log("Pause Button clicked")
            }
        }

        QGCButton {
            width: root.width * 0.8
            height: width / 3
            backRadius: 10
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: _activeVehicle
            text: qsTr("Home Return")
            pointSize: ScreenTools.mediumFontPointSize
            onClicked: {
                console.log("Home Return Button clicked")
            }
        }
    }
}

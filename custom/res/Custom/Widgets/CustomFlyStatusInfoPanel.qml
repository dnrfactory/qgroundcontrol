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
    id:                     root

    property real _bottomPanelLeftPadding
    property real _bottomPanelMargin
    property real _bottomPanelRadious
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle

    Rectangle {
        anchors.fill:       parent
        color:              qgcPal.window
        opacity:            0.8        
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
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
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.ScreenTools   1.0

QGCListView {
    id: root
    model: vehicles
    clip: true

    property var colorList: QGroundControl.multiVehicleManager.vehicleColorList
    property var vehicles: QGroundControl.multiVehicleManager.vehiclesForUi
    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var batteryValueItem: [null, null, null, null]

    onActiveVehicleChanged: updateActiveVehicle()
    Component.onCompleted: updateActiveVehicle()

    Connections {
        target: batteryDetectTimer
        onBatteryValueChanged: {
            batteryValueItem[vehicleIndex].setValueText(
               "%1(%2)"
               .arg(voltage.toFixed(1))
               .arg(percentage.toFixed(0)))
        }
    }

    function isConnectedIndex(index) {
        return index >= 0 && index < 4 && vehicles.get(index) !== null
    }

    function isValidIndex(index) {
        return index >= 0 && index < 4
    }

    function updateActiveVehicle() {
        for (var i = 0; i < vehicles.rowCount(); i++) {
            var vehicle = vehicles.get(i)
            if (vehicle !== null && vehicle === activeVehicle) {
                root.currentIndex = i
                break;
            }
        }
    }

    delegate: Item {
        id: listItem
        width: root.width
        height: root.height / 4
        enabled: { console.log("listItem enabled:%1".arg(isConnectedIndex(index))); isConnectedIndex(index) }

        MouseArea {
            anchors.fill: listItem
            onClicked: {
                console.log("item clicked index:%1".arg(index))
                root.currentIndex = index
                QGroundControl.multiVehicleManager.activeVehicle = vehicles.get(index)
            }
        }

        Column {
            anchors.fill: parent

            Rectangle {
                id: vehicleNameBar
                width: parent.width
                height: parent.height* 0.2
                color: {
                    console.log("===vehicle color list===")
                    console.log(colorList[0])
                    console.log(colorList[1])
                    console.log(colorList[2])
                    console.log(colorList[3])
                    isValidIndex(index) ? colorList[index] : "transparent"
                    }
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "UAV " + index
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold: true
                    color: "black"
                    leftPadding: 10
                }
            }
            Rectangle {
                id: vehicleInfoPanel
                width: parent.width
                height: parent.height * 0.8
                color: qgcPal.window
                opacity: 0.8
                border.color: root.currentIndex == index ? "red" : vehicleNameBar.color
                border.width: isConnectedIndex(index) ? 3 : 0

                Component {
                    id: factViewComponent
                    Item {
                        width: vehicleInfoPanel.width / 3
                        height: vehicleInfoPanel.height / 2
                        property string valueText
                        property string nameText
                        Column {
                            spacing: 10
                            Text {
                                text: valueText
                                font.pointSize: ScreenTools.mediumFontPointSize
                                font.bold: true
                                color: "white"
                                topPadding: 10
                                leftPadding: 10
                            }
                            Text {
                                text: nameText
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: "white"
                                leftPadding: 10
                            }
                        }

                        function setValueText(value) {
                            valueText = value
                        }
                    }
                }
                Grid {
                    columns: 3
                    Loader {
                        sourceComponent: factViewComponent
                        onLoaded: {
                            item.valueText = Qt.binding(function() {
                                return isConnectedIndex(index) ? "ONLINE" : "OFFLINE"
                            })
                            item.nameText = Qt.binding(function() { return qsTr("Connection") })
                        }
                    }
                    Loader {
                        id: batteryValueLoader
                        sourceComponent: factViewComponent
                        onLoaded: {
                            item.valueText = "0.0(0)"
                            item.nameText = Qt.binding(function() { return qsTr("Battery(V, \%)") })
                            root.batteryValueItem[index] = item
                        }
                    }
                    Loader {
                        sourceComponent: factViewComponent
                        onLoaded: {
                            item.valueText = Qt.binding(function() {
                                return isConnectedIndex(index) ?
                                       vehicles.get(index).rcRSSI : "0"
                            })
                            item.nameText = Qt.binding(function() { return qsTr("Conn. Str.(%)") })
                        }
                    }
                    Loader {
                        sourceComponent: factViewComponent
                    }
                    Loader {
                        sourceComponent: factViewComponent
                        onLoaded: {
                            item.valueText = Qt.binding(function() {
                                return isConnectedIndex(index) ?
                                       vehicles.get(index).altitudeRelative.rawValue.toFixed(1) : "0.0"
                            })
                            item.nameText = Qt.binding(function() { return qsTr("Altitude(m)") })
                        }
                    }
                    Loader {
                        sourceComponent: factViewComponent
                        onLoaded: {
                            item.valueText = Qt.binding(function() {
                                return isConnectedIndex(index) ?
                                       vehicles.get(index).gps.count.rawValue : "0"
                            })
                            item.nameText = Qt.binding(function() { return qsTr("GPS") })
                        }
                    }
                }
            }

            Component.onCompleted: {
                console.log("CustomVehicleList item completed index: " + index)
                console.log("CustomVehicleList item completed width: " + width)
                console.log("CustomVehicleList item completed height: " + height)
            }
        }
    }
}

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

    property var colorList: ["#ffa07a", "#97ff7a", "#7ad9ff", "#e37aff"]
    property var vehicles: QGroundControl.multiVehicleManager.vehiclesForUi
    property var batteryValueItem: [null, null, null, null]

    Connections {
        target: QGroundControl.multiVehicleManager
        onVehicleAdded: startBatteryDectect(vehicle)
        onVehicleRemoved: stopBatteryDectect(vehicle)
    }

    Connections {
        target: batteryDectectTimer
        onBatteryValueChaned: {
            batteryValueItem[vehicleIndex].setValueText(
               "%1(%2)"
               .arg(voltage.toFixed(1))
               .arg(percentage.toFixed(0)))
        }
    }

    Timer {
        id: batteryDectectTimer
        repeat: true
        interval: 1000

        property var targetVehicles: []

        signal batteryValueChaned(int vehicleIndex, real voltage, real percentage)

        onTriggered: {
            console.log("@@@@@ batteryDectectTimer @@@@@")
            for (var vehicle of targetVehicles) {
                var batteriesCount = vehicle.batteries.rowCount()
                var uiIndex = QGroundControl.multiVehicleManager.getUiIndexOfVehicle(vehicle)

                //console.log("@@@@@ batteryDectectTimer vehicleId(%1) batteryCount(%2)"
                //            .arg(vehicle.id).arg(batteriesCount))

                if (batteriesCount > 0) {
                    for (var i = 0; i < batteriesCount; i++) {
                        var btt = vehicle.getFactGroup("battery%1".arg(i))
                        if (btt !== null) {
                            var voltageStr = btt.voltage.rawValue.toFixed(1)
                            var percentStr = btt.percentRemaining.rawValue.toFixed(0)

                            /*console.log("bat(%1) vol(%2) per(%3)"
                                        .arg(i)
                                        .arg(voltageStr)
                                        .arg(percentStr))*/

                            batteryValueChaned(uiIndex,
                                                btt.voltage.rawValue,
                                                btt.percentRemaining.rawValue)
                            break;
                        }
                        else {
                            console.log("bat(%1) is null".arg(i))
                        }
                    }
                }
                else {
                    batteryValueChaned(uiIndex, 0, 0)
                }
            }
        }

        function addTarget(vehicle) {
            targetVehicles.push(vehicle)
            if (targetVehicles.length > 0) {
                start()
            }
        }
        function removeTarget(vehicle) {
            targetVehicles = targetVehicles.filter(function(item) { return item !== vehicle; })
            if (targetVehicles.length <= 0) {
                stop()
            }
            var uiIndexOfVehicle =
                    QGroundControl.multiVehicleManager.getUiIndexOfVehicle(vehicle)
            batteryValueItem[uiIndexOfVehicle].setValueText("0.0(0)")
        }
    }

    function startBatteryDectect(vehicle) {
        batteryDectectTimer.addTarget(vehicle)
    }
    function stopBatteryDectect(vehicle) {
        batteryDectectTimer.removeTarget(vehicle)
    }

    function isConnectedIndex(index) {
        return index >= 0 && index < 4 && vehicles.get(index) !== null
    }

    function isValidIndex(index) {
        return index >= 0 && index < 4
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
                color: isValidIndex(index) ? colorList[index] : "transparent"
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "UAV " + index
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold: true
                    color: "black"
                    leftPadding: 20
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
                                leftPadding: 20
                            }
                            Text {
                                text: nameText
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: "white"
                                leftPadding: 20
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
                            item.nameText = Qt.binding(function() { return qsTr("Connect status") })
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
                                       vehicles.get(index).altitudeAboveTerr.rawValue.toFixed(0) : "0"
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
                            item.nameText = Qt.binding(function() { return qsTr("Satellite Signal") })
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

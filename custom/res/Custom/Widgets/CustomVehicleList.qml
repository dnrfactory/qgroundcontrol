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

    readonly property int commonPadding: 10

    onActiveVehicleChanged: updateActiveVehicle()
    Component.onCompleted: updateActiveVehicle()

    Connections {
        target: batteryDetectTimer
        onBatteryValueChanged: {
            batteryValueItem[vehicleIndex].setValueText(
               "%1(%2)"
               .arg(voltage.toFixed(1))
               .arg(percentage.toFixed(0)))

            batteryValueItem[vehicleIndex].setValueTextColor(
                percentage > 60 ? "green" : (percentage > 20 ? "yellow" : "red"))
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

    readonly property int eMainStatusDisconnected: 0
    readonly property int eMainStatusCommLost: 1
    readonly property int eMainStatusReadyToFly: 2
    readonly property int eMainStatusNotReadyToFly: 3
    readonly property int eMainStatusArmed: 4
    readonly property int eMainStatusFlying: 5
    readonly property int eMainStatusWaiting: 6

    readonly property var mainStatusTextArray: [
        "",
        qsTr("Communication Lost"),
        qsTr("Ready To Fly"),
        qsTr("Not Ready"),
        qsTr("Armed"),
        qsTr("Flying"),
        qsTr("Waiting")
    ]
    readonly property var mainStatusColorArray: [
        "gray",
        "red",
        "green",
        "yellow",
        "green",
        "green",
        "green"
    ]

    function getVehicleMainStatus(index) {
        var vehicle = vehicles.get(index)

        if (vehicle === null || vehicle === undefined) {
            return eMainStatusDisconnected
        }

        if (vehicle.vehicleLinkManager.communicationLost) {
            return eMainStatusCommLost
        }

        if (vehicle.armed) {
            if (vehicle.flying) {
                return eMainStatusFlying
            }
            if (vehicle.landing) {
                return eMainStatusWaiting
            }
            return eMainStatusArmed
        }

        if (vehicle.healthAndArmingCheckReport.supported) {
            if (vehicle.healthAndArmingCheckReport.canArm) {
                return eMainStatusReadyToFly
            }
            return eMainStatusNotReadyToFly
        }

        if (vehicle.readyToFlyAvailable) {
            if (vehicle.readyToFly) {
                return eMainStatusReadyToFly
            }
            return eMainStatusNotReadyToFly
        }
        // Best we can do is determine readiness based on
        // AutoPilot component setup and health indicators from SYS_STATUS
        if (vehicle.allSensorsHealthy
            && vehicle.autopilot.setupComplete) {
            return eMainStatusReadyToFly
        }
        return eMainStatusNotReadyToFly
    }

    delegate: Item {
        id: listItem
        width: root.width
        height: root.height / 4
        enabled: { console.log("listItem enabled:%1".arg(isConnectedIndex(index))); isConnectedIndex(index) }

        opacity: isConnectedIndex(index) ? 1 : 0.4

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
                    text: "UAV " + (index + 1)
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold: true
                    color: "black"
                    leftPadding: commonPadding
                }
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: mainStatusTextArray[getVehicleMainStatus(index)]
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold: true
                    color: mainStatusColorArray[getVehicleMainStatus(index)]
                    leftPadding: parent.width / 3 + commonPadding
                }
            }
            CustomPanel {
                id: vehicleInfoPanel
                width: parent.width
                height: parent.height * 0.8
                border.color: root.currentIndex == index ? "red" : vehicleNameBar.color
                border.width: isConnectedIndex(index) ? 3 : 0

                Component {
                    id: factViewComponent
                    Item {
                        width: vehicleInfoPanel.width / 3
                        height: vehicleInfoPanel.height / 2
                        property string valueText
                        property string nameText
                        property var valueTextColor: "white"
                        Column {
                            spacing: 10
                            Text {
                                text: valueText
                                font.pointSize: ScreenTools.mediumFontPointSize
                                font.bold: true
                                color: valueTextColor
                                topPadding: commonPadding
                                leftPadding: commonPadding
                            }
                            Text {
                                text: nameText
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: "white"
                                leftPadding: commonPadding
                            }
                        }

                        function setValueText(value) {
                            valueText = value
                        }
                        function setValueTextColor(color) {
                            valueTextColor = color
                        }
                    }
                }
                Grid {
                    columns: 3
                    Item {
                        width: vehicleInfoPanel.width / 3
                        height: vehicleInfoPanel.height / 2
                        CustomArmSwitch {
                            vehicle: vehicles.get(index)
                            width: parent.width * 0.9
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
                        onLoaded: {
                            item.valueText = Qt.binding(function() {
                                return isConnectedIndex(index) ?
                                       vehicles.get(index).flightMode : ""
                            })
                            item.nameText = Qt.binding(function() { return qsTr("Flight mode") })
                        }
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

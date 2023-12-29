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
    property var vehicles: [ null, null, null, null ]
    property string connectedIndex: "xxxx"

    Connections {
        target: QGroundControl.multiVehicleManager
        onVehicleAdded: {
            console.log("onVehicleAdded id:" + vehicle.id)
            vehicles[vehicleIdToIndex(vehicle.id)] = vehicle
            for (let element of vehicles) {
                console.log(element);
            }
            setIndexConnection(vehicleIdToIndex(vehicle.id), true)
            getAllBatteryInfo()
        }
        onVehicleRemoved: {
            console.log("onVehicleRemoved id:" + vehicle.id)
            vehicles[vehicleIdToIndex(vehicle.id)] = null
            for (let element of vehicles) {
                console.log(element);
            }
            setIndexConnection(vehicleIdToIndex(vehicle.id), false)
            getAllBatteryInfo()
        }
    }

    function setIndexConnection(index, connected) {
        var charArray = connectedIndex.split('');
        charArray[index] = connected ? 'o' : 'x';
        connectedIndex = charArray.join('');
    }

    function vehicleIdToIndex(vehicleId) {
        return vehicleId - 128
    }

    function getAllBatteryInfo() {
        for (var i = 0; i < 4; i++) {
            if (connectedIndex[i] == 'o') {
                console.log("getAllBatteryInfo vehicle(%1) batteries cnt(%2)"
                        .arg(i)
                        .arg(vehicles[i].batteries.rowCount()))
                getBatteryStr(i)
            }
        }
    }

    function getBatteryStr(idx) {
        var voltageStr = "00.0"
        var percentStr = "0"
        if (connectedIndex[idx] == 'o' && vehicles[idx].batteries.rowCount() > 0) {
            var batteries = vehicles[idx].batteries
            console.log("vehicle(%1) batteries cnt(%2)"
                        .arg(idx)
                        .arg(batteries.rowCount()))
            for(var i = 0; i < vehicles[idx].batteries.rowCount(); i++) {
                var btt = vehicles[idx].getFactGroup("battery%1".arg(i))
                if (btt !== null) {
                    voltageStr = btt.voltage.rawValue.toFixed(1)
                    percentStr = btt.percentRemaining.rawValue.toFixed(0)
                    console.log("bat(%1) vol(%2) per(%3)"
                                .arg(i)
                                .arg(voltageStr)
                                .arg(percentStr))
                    break;
                }
                else {
                    console.log("bat(%1) is null".arg(i))
                }
            }
        }
        return "%1(%2)".arg(voltageStr).arg(percentStr)
    }

    delegate: Column {
        width: root.width
        height: root.height / 4

        Rectangle {
            id: vehicleNameBar
            width: parent.width
            height: parent.height* 0.2
            color: colorList[index]
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
            border.color: vehicleNameBar.color
            border.width: connectedIndex[index] == 'o' ? 3 : 0

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
                }
            }
            Grid {
                columns: 3
                Loader {
                    sourceComponent: factViewComponent
                    onLoaded: {
                        item.valueText = Qt.binding(function() {
                            return connectedIndex[index] == 'o' ? "ONLINE" : "OFFLINE"
                        })
                        item.nameText = Qt.binding(function() { return qsTr("Connect status") })
                    }
                }
                Loader {
                    sourceComponent: factViewComponent
                    onLoaded: {
                        item.valueText = Qt.binding(function() { return getBatteryStr(index) })
                        item.nameText = Qt.binding(function() { return qsTr("Battery(V, \%)") })
                    }
                }
                Loader {
                    sourceComponent: factViewComponent
                    onLoaded: {
                        item.valueText = Qt.binding(function() {
                            return connectedIndex[index] == 'o' ? "0" : "0"
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
                            return connectedIndex[index] == 'o' ?
                                   vehicles[index].altitudeAboveTerr.rawValue.toFixed(0) : "0"
                        })
                        item.nameText = Qt.binding(function() { return qsTr("Altitude(m)") })
                    }
                }
                Loader {
                    sourceComponent: factViewComponent
                    onLoaded: {
                        item.valueText = Qt.binding(function() {
                            return connectedIndex[index] == 'o' ? "0" : "0"
                        })
                        item.nameText = Qt.binding(function() { return qsTr("Satelite Signal") })
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

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

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Vehicle       1.0

Item {
    id: root

    property var targetVehicles: []

    signal batteryValueChanged(int vehicleIndex, real voltage, real percentage)

    Timer {
        id: timer
        repeat: true
        interval: 1000

        property int cnt: 0

        onTriggered: {
            ++cnt

            if (cnt % 10 === 0) {
                console.log("@@@@@ batteryDectectTimer @@@@@")
            }

            for (var vehicle of targetVehicles) {
                var batteriesCount = vehicle.batteries.rowCount()
                var uiIndex = QGroundControl.multiVehicleManager.getUiIndexOfVehicle(vehicle)

                if (cnt % 10 === 0) {
                    console.log("@@@@@ batteryDectectTimer vehicleId(%1) batteryCount(%2)"
                                .arg(vehicle.id).arg(batteriesCount))
                }

                if (batteriesCount > 0) {
                    for (var i = 0; i < batteriesCount; i++) {
                        var btt = vehicle.getFactGroup("battery%1".arg(i))
                        if (btt !== null) {
                            var voltageStr = btt.voltage.rawValue.toFixed(1)
                            var percentStr = btt.percentRemaining.rawValue.toFixed(0)

                            if (cnt % 10 === 0) {
                                console.log("bat(%1) vol(%2) per(%3)"
                                            .arg(i)
                                            .arg(voltageStr)
                                            .arg(percentStr))
                            }

                            batteryValueChanged(uiIndex,
                                                btt.voltage.rawValue,
                                                btt.percentRemaining.rawValue)
                            break;
                        }
                        else {
                            if (cnt % 10 === 0) {
                                console.log("bat(%1) is null".arg(i))
                            }
                        }
                    }
                }
                else {
                    batteryValueChanged(uiIndex, 0, 0)
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
            batteryValueChanged(uiIndexOfVehicle, 0, 0)
        }
    }

    Connections {
        target: QGroundControl.multiVehicleManager
        onVehicleAdded: timer.addTarget(vehicle)
        onVehicleRemoved: timer.removeTarget(vehicle)
    }
}

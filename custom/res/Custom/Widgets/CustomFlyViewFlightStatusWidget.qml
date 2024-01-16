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
import QtQuick.Window           2.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0

Rectangle {
    id: root
    color: qgcPal.window
    opacity: 0.8

    property var colorList: QGroundControl.multiVehicleManager.vehicleColorList
    property var vehicles: QGroundControl.multiVehicleManager.vehiclesForUi
    property var itemWidthRatio: [0.05, 0.2, 0.05, 0.05, 0.15, 0.1, 0.1, 0.25, 0.05]
    property var batteryValueItem: [null, null, null, null]

    property int eVehicle: 0
    property int eTakeOff: 1
    property int eConnection: 2
    property int eSatellite: 3
    property int eBattery: 4
    property int eVelocity: 5
    property int eAltitude: 6
    property int ePosition: 7
    property int eProgress: 8

    property var mapControl

    function isConnectedIndex(index) {
        return index >= 0 && index < 4 && vehicles.get(index) !== null
    }

    function isValidIndex(index) {
        return index >= 0 && index < 4
    }

    function getAirSpeedStr(idx) {
        var airSpeedStr = "0"
        if (isConnectedIndex(idx)) {
            airSpeedStr = vehicles[idx].airSpeed.rawValue.toFixed(1)
        }
        return "%1 km/h".arg(airSpeedStr)
    }

    function getAltitudeStr(idx) {
        var altitudeStr = "0"
        if (isConnectedIndex(idx)) {
            altitudeStr = vehicles[idx].gps.count.rawValue
        }
        return "%1 m".arg(altitudeStr)
    }

    function getLocationStr(idx) {
        var latitudeStr = "--.--"
        var longitudeStr = "--.--"
        if (isConnectedIndex(idx)) {
            latitudeStr = vehicles[idx].gps.lat.rawValue.toFixed(2)
            longitudeStr = vehicles[idx].gps.lon.rawValue.toFixed(2)

            console.log("getLocationStr lat:%1, lon:%2".arg(vehicles[idx].gps.lat.rawValue).arg(vehicles[idx].gps.lon.rawValue))
        }
        return "%1 %2  /%3 %4".arg(qsTr("Lat.")).arg(latitudeStr).arg("Lon.").arg(longitudeStr)
    }

    QGCListView {
        id: listView
        anchors.fill: parent
        model: root.vehicles
        clip: true

        header: Item {
            width: listView.width
            height: root.height / 5
            Component {
                id: headerColNameComponent
                Item {
                    property string colName
                    property int colIndex

                    height: root.height / 5
                    width: listView.width * itemWidthRatio[colIndex]
                    QGCLabel {
                        anchors.centerIn: parent
                        text: colName
                    }
                }
            }
            Row {
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 0
                        item.colName = Qt.binding(function() { return qsTr("Vehicle") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 1
                        item.colName = Qt.binding(function() { return qsTr("Take-off Time") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 2
                        item.colName = Qt.binding(function() { return qsTr("Conn. Status") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 3
                        item.colName = Qt.binding(function() { return qsTr("Sat. Signal") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 4
                        item.colName = Qt.binding(function() { return qsTr("Battery") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 5
                        item.colName = Qt.binding(function() { return qsTr("Air Speed") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 6
                        item.colName = Qt.binding(function() { return qsTr("Altitude") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 7
                        item.colName = Qt.binding(function() { return qsTr("Current Position") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 8
                        item.colName = Qt.binding(function() { return qsTr("Progress") })
                    }
                }
            }
        }

        delegate: Item {
            id: listItem
            width: listView.width
            height: root.height / 5

            Rectangle {
                width: parent.width - 40
                height: parent.height * 0.5
                anchors.centerIn: parent
                color: isValidIndex(index) ? colorList[index] : "transparent"
                opacity: 0.3
            }

            Component {
                id: valueComponent
                Item {
                    property string valueText
                    property int colIndex

                    height: root.height / 5
                    width: listView.width * itemWidthRatio[colIndex]
                    QGCLabel {
                        anchors.centerIn: parent
                        text: valueText
                    }
                }
            }

            Row {
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 0
                        item.valueText = Qt.binding(function() { return "UAV %1".arg(index) })
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 1
                        item.valueText = Qt.binding(function() { return isConnectedIndex(index) ? "" : "" })
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 2
                        item.valueText = Qt.binding(function() { return isConnectedIndex(index) ? "ON" : "OFF" })
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 3
                        item.valueText = Qt.binding(function() { return isConnectedIndex(index) ? vehicles[index].gps.count.rawValue : "0" })
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 4
                        item.valueText = "0.0(0)"
                        root.batteryValueItem[index] = item
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 5
                        item.valueText = Qt.binding(function() { return getAirSpeedStr(index) })
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 6
                        item.valueText = Qt.binding(function() { return getAltitudeStr(index) })
                    }
                }
                Loader {
                    id: locationLoader
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 7
                        item.valueText = Qt.binding(function() { return getLocationStr(index) })

                        Qt.createQmlObject(`
                            import QGroundControl.Controls 1.0

                            QGCButton {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 100
                                width: 60
                                height: parent.height * 0.5
                                backRadius: 4
                                text: qsTr("Go")
                                enabled: isConnectedIndex(index)
                                onClicked: {
                                    console.log("Location Go Button clicked")

                                    if (root.mapControl !== null) {
                                        root.mapControl.center = vehicles[index].coordinate
                                    }
                                }
                            }
                            `,
                            locationLoader,
                            ""
                        );
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 8
                        item.valueText = Qt.binding(function() { return isConnectedIndex(index) ? "" : "" })
                    }
                }
            }
        }
    }
}

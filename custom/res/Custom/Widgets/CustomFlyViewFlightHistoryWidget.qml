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

Rectangle {
    id: root
    color: qgcPal.window
    opacity: 0.8

    property var vehicles: [ null, null, null, null ]
    property string connectedIndex: "xxxx"
    property var itemWidthRatio: [0.1, 0.3, 0.1, 0.1, 0.4]

    property int eVehicle: 0
    property int eTime: 1
    property int eDistance: 2
    property int ePath: 3
    property int eVideo: 4

    Connections {
        target: QGroundControl.multiVehicleManager
        onVehicleAdded: {
            console.log("CustomFlyViewFlightStatusWidget onVehicleAdded id:" + vehicle.id)
            vehicles[vehicleIdToIndex(vehicle.id)] = vehicle
            for (let element of vehicles) {
                console.log(element);
            }
            setIndexConnection(vehicleIdToIndex(vehicle.id), true)
        }
        onVehicleRemoved: {
            console.log("CustomFlyViewFlightStatusWidget onVehicleRemoved id:" + vehicle.id)
            vehicles[vehicleIdToIndex(vehicle.id)] = null
            for (let element of vehicles) {
                console.log(element);
            }
            setIndexConnection(vehicleIdToIndex(vehicle.id), false)
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
                        item.colName = Qt.binding(function() { return qsTr("Flight Time") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 2
                        item.colName = Qt.binding(function() { return qsTr("Flight Distance") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 3
                        item.colName = Qt.binding(function() { return qsTr("Flight Path") })
                    }
                }
                Loader {
                    sourceComponent: headerColNameComponent
                    onLoaded: {
                        item.colIndex = 4
                        item.colName = Qt.binding(function() { return qsTr("Flight Video") })
                    }
                }
            }
        }

        delegate: Item {
            id: listItem
            width: listView.width
            height: root.height / 5

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
                        item.valueText = Qt.binding(function() { return connectedIndex[index] == 'o' ? "" : "" })
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 2
                        item.valueText = Qt.binding(function() { return connectedIndex[index] == 'o' ? "" : "" })
                    }
                }
                Loader {
                    id: flightPathLoader
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 3

                        Qt.createQmlObject(`
                            import QGroundControl.Controls 1.0

                            QGCButton {
                                anchors.centerIn: parent
                                width: 60
                                height: parent.height * 0.5
                                backRadius: 4
                                text: qsTr("Show")
                                enabled: connectedIndex[index] == 'o'
                                onClicked: {
                                    console.log("Flight Path Show Button clicked")
                                }
                            }
                            `,
                            flightPathLoader,
                            ""
                        );
                    }
                }
                Loader {
                    id: fligthVideoLoader
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 4
                        item.valueText = Qt.binding(function() { return connectedIndex[index] == 'o' ? "" : "" })

                        Qt.createQmlObject(`
                            import QGroundControl.Controls 1.0

                            QGCButton {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 170
                                width: 60
                                height: parent.height * 0.5
                                backRadius: 4
                                text: qsTr("Folder")
                                enabled: connectedIndex[index] == 'o'
                                onClicked: {
                                    console.log("FlightVideo Folder Button clicked")
                                }
                            }
                            `,
                            fligthVideoLoader,
                            ""
                        );

                        Qt.createQmlObject(`
                            import QGroundControl.Controls 1.0

                            QGCButton {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 100
                                width: 60
                                height: parent.height * 0.5
                                backRadius: 4
                                text: qsTr("Play")
                                enabled: connectedIndex[index] == 'o'
                                onClicked: {
                                    console.log("FlightVideo Play Button clicked")
                                }
                            }
                            `,
                            fligthVideoLoader,
                            ""
                        );
                    }
                }
            }
        }
    }
}

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
import QtMultimedia             5.5

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0

CustomPanel {
    id: root

    property var vehicles: QGroundControl.multiVehicleManager.vehiclesForUi
    property var itemWidthRatio: [0.1, 0.3, 0.1, 0.1, 0.4]

    property int eVehicle: 0
    property int eTime: 1
    property int eDistance: 2
    property int ePath: 3
    property int eVideo: 4

    function isConnectedIndex(index) {
        return index >= 0 && index < 4 && vehicles.get(index) !== null
    }

    function getFlightTime(index) {
        var timeStr = "00:00:00"
        if (isConnectedIndex(index)) {
            var vehicle = vehicles.get(index)

            var seconds = vehicle.flightTime.rawValue.toFixed(0)
            var hours = Math.floor(seconds / 3600)
            var minutes = Math.floor((seconds % 3600) / 60);
            var remainingSeconds = seconds % 60;

            var hStr = hours < 10 ? "0" + hours : hours
            var mStr = minutes < 10 ? "0" + minutes : minutes
            var sStr = remainingSeconds < 10 ? "0" + remainingSeconds : remainingSeconds

            timeStr = hStr + ":" + mStr + ":" + sStr
        }
        return timeStr
    }

    function getFlightDistance(index) {
        var distance = "0.0"
        if (isConnectedIndex(index)) {
            var vehicle = vehicles.get(index)
            var distance = vehicle.flightDistance.rawValue.toFixed(1)
        }
        return "%1 m".arg(distance)
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
                        item.valueText = Qt.binding(function() { return getFlightTime(index) })
                    }
                }
                Loader {
                    sourceComponent: valueComponent
                    onLoaded: {
                        item.colIndex = 2
                        item.valueText = Qt.binding(function() { return getFlightDistance(index) })
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
                                enabled: isConnectedIndex(index)
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
                Item {
                    id: fligthVideoItem
                    property string valueText
                    property int colIndex: 4

                    height: root.height / 5
                    width: listView.width * itemWidthRatio[colIndex]

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        padding: 20
                        layoutDirection: Qt.RightToLeft
                        width: parent.width

                        spacing: 10

                        QGCButton {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 60
                            height: fligthVideoItem.height * 0.5
                            backRadius: 4
                            text: qsTr("Play")
                            onClicked: {
                                console.log("FlightVideo Play Button clicked")

                                mediaPlayer.play()
                            }
                        }

                        QGCButton {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 60
                            height: fligthVideoItem.height * 0.5
                            backRadius: 4
                            text: qsTr("Folder")
                            onClicked: {
                                console.log("FlightVideo Folder Button clicked")

                                fileDialog.openForLoad()
                                fileDialog.acceptedForLoad.connect(onAcceptedForLoad)
                            }
                            function onAcceptedForLoad(file) {
                                console.log(file)
                                videoPathLabel.text = file
                                mediaPlayer.source = file
                            }
                        }

                        QGCLabel {
                            id: videoPathLabel
                            anchors.verticalCenter: parent.verticalCenter
                            width: fligthVideoItem.width
                            height: fligthVideoItem.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            text: ""
                        }
                    }
                }
            }
        }
    }

    QGCFileDialog {
        id: fileDialog
        title: qsTr("Choose the flight video file")
        folder: QGroundControl.settingsManager.appSettings.videoSavePath
        selectExisting: true
        selectFolder: false
        onAcceptedForLoad: console.log(file)
        nameFilters: ["Video files (*.mkv *.mov *.mp4)"]
    }

    MediaPlayer {
        id: mediaPlayer
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        source: mediaPlayer
    }
}

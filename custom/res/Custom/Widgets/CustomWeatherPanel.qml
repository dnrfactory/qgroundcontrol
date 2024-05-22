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

import QtLocation               5.3
import QtPositioning            5.3
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
//import QGroundControl.QGCPositionManager    1.0
import WeatherInfoProvider 1.0

Item {
    id: root

    //property var gcsPosition: QGroundControl.qgcPositionManger.gcsPosition
    property var mapCenterPosition

    Component.onCompleted: {
        WeatherInfoProvider.requestWeatherData(mapCenterPosition.longitude, mapCenterPosition.latitude)
    }

    CustomButton {
        width: 40
        height: 40
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 10
        text: "\u27F3"
        pointSize: ScreenTools.largeFontPointSize * 1.5
        boldFont: true
        backRadius: 10

        onClicked: {
            console.log("CustomWeatherPanel clicked!! lon:%1, lat:%2"
                        .arg(mapCenterPosition.longitude)
                        .arg(mapCenterPosition.latitude))
            WeatherInfoProvider.requestWeatherData(mapCenterPosition.longitude, mapCenterPosition.latitude)
        }
    }

    Text {
        id: locationText
        height: root.height / 4
        width: parent.width
        anchors.top: parent.top
        text: WeatherInfoProvider.valid ? WeatherInfoProvider.location : "--"
        font.pointSize: ScreenTools.mediumFontPointSize
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Item {
        anchors.top: locationText.bottom
        anchors.left: parent.left
        height: root.height * 0.75
        width: parent.width / 2

        Image {
            id: weatherIcon

            anchors.centerIn: parent
            sourceSize.width: parent.width * 0.5
            source: {
                switch (WeatherInfoProvider.rainType) {
                case 0:
                    switch(WeatherInfoProvider.sky) {
                    case 3: return "/res/custom/img/WeatherPartlyCloudy.svg"
                    case 4: return "/res/custom/img/WeatherCloudy.svg"
                    case 1: return "/res/custom/img/WeatherClear.svg"
                    }
                    break
                case 1:
                case 2:
                case 5:
                case 6:
                    return "/res/custom/img/WeatherRainy.svg"
                case 3:
                case 7:
                    return "/res/custom/img/WeatherSnow.svg"
                }
                return ""
            }
        }
    }

    Column {
        id: column
        width: root.width / 2
        anchors.top: locationText.bottom
        anchors.right: parent.right

        readonly property real itemSpacing: 20
        readonly property real itemHeight: root.height / 4
        readonly property real itemWidth: (width - itemSpacing) / 2

        Component {
            id: rowComponent

            Row {
                spacing: column.itemSpacing

                property string titleText
                property string valueText

                Item {
                    height: column.itemHeight
                    width: column.itemWidth
                    Text {
                        anchors.fill: parent
                        font.pointSize: ScreenTools.mediumFontPointSize
                        color: qgcPal.text
                        text: titleText
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Item {
                    height: column.itemHeight
                    width: column.itemWidth
                    Text {
                        anchors.fill: parent
                        font.pointSize: ScreenTools.mediumFontPointSize
                        color: qgcPal.text
                        text: valueText
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Wind")
                item.valueText = Qt.binding(function() {
                    return (WeatherInfoProvider.valid ? WeatherInfoProvider.wind : "--") + " m/s" })
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Temperature")
                item.valueText = Qt.binding(function() {
                    return (WeatherInfoProvider.valid ? WeatherInfoProvider.temperature : "--") + " \u2103" })
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Precipitation")
                item.valueText = Qt.binding(function() {
                    return (WeatherInfoProvider.valid ? WeatherInfoProvider.rain : "--") + " mm" })
            }
        }
    }
}

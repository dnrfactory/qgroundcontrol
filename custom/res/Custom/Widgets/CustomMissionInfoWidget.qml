/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Layouts  1.2
import QtQuick.Window   2.2

import QGroundControl                   1.0
import QGroundControl.FlightMap         1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactSystem        1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0
import QGroundControl.Controllers       1.0
import QGroundControl.ShapeFileHelper   1.0

Rectangle {
    id: root
    height: parent.height
	color: qgcPal.window
	opacity: 0.8

    property var planMasterController
    property var currentMissionItem: globals.currentPlanMissionItem

    readonly property real verticalMargin: 40
    readonly property real itemSpacing: 20
    readonly property real itemHeight: (height - verticalMargin) / 5
    readonly property real itemWidth: (width - itemSpacing) / 2

    Column {
        anchors.centerIn: parent
        Component {
            id: rowComponent
            Row {
                spacing: root.itemSpacing

                property string titleText
                property string valueText
                Item {
                    height: itemHeight
                    width: itemWidth
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
                    height: itemHeight
                    width: itemWidth
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
                item.titleText = qsTr("Plan name")
                item.valueText = "untitled"
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Flight distance")
                item.valueText = "0 m"
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Flight speed")
                item.valueText = "0 km/h"
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Max distance")
                item.valueText = "0 m"
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Estimated time")
                item.valueText = "00:00:00"
            }
        }
    }
}
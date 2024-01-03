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
import QGroundControl.Controllers   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

Rectangle {
    id: root

    color: qgcPal.window
    opacity: 0.8

    property real btnWidth: width * 0.1
    property real btnHeight: height * 0.15
    property real btnRadius: 10
    property real btnSpacing: 10
    property real labelHeight: height * 0.2
    property real controlHeight: height - labelHeight
    property real gimbalLeftPadding: width * 0.15
    property real labelTopPadding: parent.height * 0.05

    Item {
        id: gimbalPanel
        width: parent.width * 0.6
        height: parent.height

        QGCLabel {
            id: gimbalLabel
            text: qsTr("Gimbal")
            font.pointSize: ScreenTools.mediumFontPointSize
            leftPadding: root.gimbalLeftPadding
            topPadding: root.labelTopPadding
        }
        Item {
            id: gibalControl
            x: root.gimbalLeftPadding
            y: root.labelHeight
            width: gimbalPanel.width - x
            height: root.controlHeight

            QGCButton {
                id: upButton
                x: root.btnWidth + root.btnSpacing
                y: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                iconSource: "/res/custom/img/ArrowUp"
                enabled : _activeVehicle
                onClicked: {
                    console.log("upButton clicked")
                }
            }
            QGCButton {
                id: leftButton
                anchors.top: upButton.bottom
                anchors.topMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                iconSource: "/res/custom/img/ArrowLeft"
                enabled : _activeVehicle
                onClicked: {
                    console.log("leftButton clicked")
                }
            }
            QGCButton {
                id: resetButton
                anchors.top: upButton.bottom
                anchors.left: leftButton.right
                anchors.topMargin: root.btnSpacing
                anchors.leftMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                text: "reset"
                pointSize: ScreenTools.mediumFontPointSize
                enabled : _activeVehicle
                onClicked: {
                    console.log("resetButton clicked")
                }
            }
            QGCButton {
                id: rirghtButton
                anchors.top: upButton.bottom
                anchors.left: resetButton.right
                anchors.topMargin: root.btnSpacing
                anchors.leftMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                iconSource: "/res/custom/img/ArrowRight"
                enabled : _activeVehicle
                onClicked: {
                    console.log("rightButton clicked")
                }
            }
            QGCButton {
                id: downButton
                anchors.top: resetButton.bottom
                anchors.left: resetButton.left
                anchors.topMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                iconSource: "/res/custom/img/ArrowDown"
                enabled : _activeVehicle
                onClicked: {
                    console.log("downButton clicked")
                }
            }
        }
    }
    Item {
        id: zoomPanel
        width: parent.width - gimbalPanel.width
        height: parent.height
        anchors.left: gimbalPanel.right

        QGCLabel {
            id: zoomLabel
            text: qsTr("Zoom In/Out")
            font.pointSize: ScreenTools.mediumFontPointSize
            topPadding: root.labelTopPadding
            anchors.horizontalCenter: zoomPanel.horizontalCenter
        }

        Item {
            id: zoomControl
            y: root.labelHeight
            width: zoomPanel.width
            height: root.controlHeight

            QGCButton {
                id: zoomInButton
                anchors.horizontalCenter: zoomControl.horizontalCenter
                y: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                text: "+"
                pointSize: ScreenTools.mediumFontPointSize
                enabled : _activeVehicle
                onClicked: {
                    console.log("zoomInButton clicked")
                }
            }
            QGCButton {
                id: zoomOutButton
                anchors.horizontalCenter: zoomControl.horizontalCenter
                anchors.top: zoomInButton.bottom
                anchors.topMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                text: "-"
                pointSize: ScreenTools.mediumFontPointSize
                enabled : _activeVehicle
                onClicked: {
                    console.log("zoomOutButton clicked")
                }
            }
            QGCButton {
                id: zoomResetButton
                anchors.horizontalCenter: zoomControl.horizontalCenter
                anchors.top: zoomOutButton.bottom
                anchors.topMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                text: "reset"
                pointSize: ScreenTools.mediumFontPointSize
                enabled : _activeVehicle
                onClicked: {
                    console.log("zoomResetButton clicked")
                }
            }
        }
    }
}

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

Item {
    id: root

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

        states: [
            State {
                name: "idle"
                when: !upButton.pressed && !downButton.pressed && !leftButton.pressed && !rightButton.pressed
                PropertyChanges { target: gimbalTimer; running: false }
            },
            State {
                name: "up"
                when: upButton.pressed
                PropertyChanges { target: gimbalTimer; running: true }
            },
            State {
                name: "down"
                when: downButton.pressed
                PropertyChanges { target: gimbalTimer; running: true }
            },
            State {
                name: "left"
                when: leftButton.pressed
                PropertyChanges { target: gimbalTimer; running: true }
            },
            State {
                name: "right"
                when: rightButton.pressed
                PropertyChanges { target: gimbalTimer; running: true }
            }
        ]

        onStateChanged: {
            console.log("onStatesChanged gimbalPanel.state: " + gimbalPanel.state)
        }

        Timer {
            id: gimbalTimer
            interval: 100
            repeat: true
            onTriggered: {
                console.log("gimbalTimer onTriggered. gimbalPanel.state: " + gimbalPanel.state)
                switch (gimbalPanel.state) {
                case "up":
                    _activeVehicle.gimbalPitchStep(1)
                    break
                case "down":
                    _activeVehicle.gimbalPitchStep(-1)
                    break
                case "left":
                    _activeVehicle.gimbalYawStep(-1)
                    break
                case "right":
                    _activeVehicle.gimbalYawStep(1)
                    break
                }
            }
        }

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

            CustomButton {
                id: upButton
                x: root.btnWidth + root.btnSpacing
                y: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                iconSource: "/res/custom/img/ArrowUp"
                enabled : _activeVehicle
                normalColor: "black"
                onClicked: {
                    console.log("upButton clicked")
                }
            }
            CustomButton {
                id: leftButton
                anchors.top: upButton.bottom
                anchors.topMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                iconSource: "/res/custom/img/ArrowLeft"
                enabled : _activeVehicle
                normalColor: "black"
                onClicked: {
                    console.log("leftButton clicked")
                }
            }
            CustomButton {
                id: resetButton
                anchors.top: upButton.bottom
                anchors.left: leftButton.right
                anchors.topMargin: root.btnSpacing
                anchors.leftMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                text: "\u25CF"
                pointSize: ScreenTools.mediumFontPointSize
                enabled : _activeVehicle
                normalColor: "black"
                onClicked: {
                    console.log("resetButton clicked")
                }
            }
            CustomButton {
                id: rightButton
                anchors.top: upButton.bottom
                anchors.left: resetButton.right
                anchors.topMargin: root.btnSpacing
                anchors.leftMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                iconSource: "/res/custom/img/ArrowRight"
                enabled : _activeVehicle
                normalColor: "black"
                onClicked: {
                    console.log("rightButton clicked")
                }
            }
            CustomButton {
                id: downButton
                anchors.top: resetButton.bottom
                anchors.left: resetButton.left
                anchors.topMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                iconSource: "/res/custom/img/ArrowDown"
                enabled : _activeVehicle
                normalColor: "black"
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

            CustomButton {
                id: zoomInButton
                anchors.horizontalCenter: zoomControl.horizontalCenter
                y: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                text: "+"
                pointSize: ScreenTools.mediumFontPointSize
                enabled : _activeVehicle
                normalColor: "black"
                onClicked: {
                    console.log("zoomInButton clicked")
                }
            }
            CustomButton {
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
                normalColor: "black"
                onClicked: {
                    console.log("zoomOutButton clicked")
                }
            }
            CustomButton {
                id: zoomResetButton
                anchors.horizontalCenter: zoomControl.horizontalCenter
                anchors.top: zoomOutButton.bottom
                anchors.topMargin: root.btnSpacing
                width: root.btnWidth
                height: root.btnHeight
                backRadius: root.btnRadius
                text: "\u25CF"
                pointSize: ScreenTools.mediumFontPointSize
                enabled : _activeVehicle
                normalColor: "black"
                onClicked: {
                    console.log("zoomResetButton clicked")
                }
            }
        }
    }
}

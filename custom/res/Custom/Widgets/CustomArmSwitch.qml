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

import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0


Item {
    id: root
    height: width / 2
    anchors.centerIn: parent

    property var vehicle

    Rectangle{
        id: roundRectangle
        width: parent.width * 0.8
        height: parent.height * 0.5
        radius: height
        color: "white"
        anchors.centerIn: parent

        QGCLabel{
            id: onLabel
            text: qsTr("ON")
            font.pointSize: ScreenTools.defaultFontPointSize
            font.bold: true
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 7
        }

        QGCLabel{
            id: offLabel
            text: qsTr("OFF")
            font.pointSize: ScreenTools.defaultFontPointSize
            font.bold: true
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 7
        }
    }

    Rectangle {
        id: switchCirle
        width: parent.height * 0.7
        height: width
        radius: height
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (vehicle !== null && vehicle !== undefined) {
                vehicle.armed = true
            }
        }
    }

    states:[
        State {
            name: "InactiveVehicle"
            when: vehicle == null || vehicle === undefined
            PropertyChanges {
                target: root
                enabled: false
            }
            PropertyChanges {
                target: switchCirle
                color: "gray"
            }
            PropertyChanges {
                target: onLabel
                color: "gray"
                visible: false
            }
            PropertyChanges {
                target: offLabel
                color: "gray"
                visible: true
            }
            AnchorChanges{
                target: switchCirle;
                anchors.left: parent.left
            }
        },
        State {
            name: "Disarmed"
            when: vehicle !== null && vehicle !== undefined && vehicle.armed === false
            PropertyChanges {
                target: root
                enabled: true
            }
            PropertyChanges {
                target: switchCirle
                color: "red"
            }
            PropertyChanges {
                target: onLabel
                color: "black"
                visible: false
            }
            PropertyChanges {
                target: offLabel
                color: "black"
                visible: true
            }
            AnchorChanges{
                target: switchCirle;
                anchors.left: parent.left
            }
        },
        State {
            name: "Armed"
            when: vehicle !== null && vehicle !== undefined && vehicle.armed
            PropertyChanges {
                target: root
                enabled: false
            }
            PropertyChanges {
                target: switchCirle
                color: "#00DC30"
            }
            PropertyChanges {
                target: onLabel
                color: "black"
                visible: true
            }
            PropertyChanges {
                target: offLabel
                color: "black"
                visible: false
            }
            AnchorChanges{
                target: switchCirle;
                anchors.right: parent.right
            }
        }
    ]
}
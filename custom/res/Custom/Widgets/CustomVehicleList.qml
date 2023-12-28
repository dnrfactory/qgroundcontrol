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
    model: ["red", "green", "blue", "yellow"]//QGroundControl.multiVehicleManager.vehicles
    clip: true

    property var colorList: ["#ffa07a", "#97ff7a", "#7ad9ff", "#e37aff"]
    property var textList: ["red", "green", "blue", "yellow"]

    delegate: Column {
        width: root.width
        height: root.height / 4        

        Rectangle {
            width: parent.width
            height: parent.height* 0.2
            color: colorList[index]
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter    
                text: textList[index]
                font.pointSize: ScreenTools.mediumFontPointSize
                color: "white"
                leftPadding: 20
            }
        }
        Rectangle {
            width: root.width
            height: root.height * 0.8
            color: qgcPal.window
            opacity: 0.8
        }    

        Component.onCompleted: {
            console.log("CustomVehicleList item completed index: " + index)
            console.log("CustomVehicleList item completed width: " + width)
            console.log("CustomVehicleList item completed height: " + height)
        }
    }
}
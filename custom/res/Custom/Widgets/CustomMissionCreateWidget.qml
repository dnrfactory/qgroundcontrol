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

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.Palette           1.0

Column {
    id: root
    height: parent.height

    property var eventHandler
    property real divideLineThickness: 2

    signal buttonClicked(int index)

    CustomButton {
        id: wayPointButton
        width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        text: qsTr("WayPoint")
        pointSize: ScreenTools.mediumFontPointSize
        isSelected: eventHandler.missionEditStatus === eventHandler.eMissionEditWayPointAdd
        onClicked: {
            console.log("WayPoint Button clicked")
            buttonClicked(0)
        }
    }
	Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        id: tracingButton
        width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        text: qsTr("Tracing")
        pointSize: ScreenTools.mediumFontPointSize
        isSelected: eventHandler.missionEditStatus === eventHandler.eMissionEditCorridorScanAdd
        onClicked: {
            console.log("Tracing Button clicked")
            buttonClicked(1)
        }
    }
	Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        id: clearTracingButton
        width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        text: qsTr("Clear Tracing")
        pointSize: ScreenTools.mediumFontPointSize
        enabled: eventHandler.missionEditStatus === eventHandler.eMissionEditCorridorScanAdd
        onClicked: {
            console.log("Clear Tracing Button clicked")
            buttonClicked(2)
        }
    }
	Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        id: resetButton
        width: parent.width
        height: parent.height * 0.25
        text: qsTr("Reset")
        pointSize: ScreenTools.mediumFontPointSize
        enabled: eventHandler.missionEditStatus !== eventHandler.eMissionEditEmpty
        onClicked: {
            console.log("Reset Button clicked")
            buttonClicked(3)
        }
    }
}
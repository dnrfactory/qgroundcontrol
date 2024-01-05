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

Column {
    id: root
    height: parent.height

	property real divideLineThickness: 2

    CustomButton {
        id: wayPointButton
        width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        text: qsTr("WayPoint")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {
            console.log("WayPoint Button clicked")
        }
    }
	Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        id: traciButton
        width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        text: qsTr("Tracing")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {
            console.log("Tracing Button clicked")
        }
    }
	Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        id: clearTracingButton
        width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        text: qsTr("Clear Tracing")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {
            console.log("Clear Tracing Button clicked")
        }
    }
	Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        id: resetButton
        width: parent.width
        height: parent.height * 0.25
        text: qsTr("Reset")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {
            console.log("Reset Button clicked")
        }
    }
}
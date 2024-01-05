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
        id: sendPlanButton
        width: parent.width
        height: parent.height * 0.25
        text: qsTr("Send Plan")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {

        }
    }
	Rectangle {
        id: uavButtonGroup
		width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        color: qgcPal.button
        opacity: 0.8

        property var colorList: ["#ffa07a", "#97ff7a", "#7ad9ff", "#e37aff"]
        property int currentIndex: 0

        Component {
        	id: uavButtonComponent
            CustomButton {
                property int index

		        width: root.width *0.25 - divideLineThickness
		        height: uavButtonGroup.height
		        text: qsTr("UAV %1").arg(index)
		        pointSize: ScreenTools.mediumFontPointSize
		        normalColor: uavButtonGroup.colorList[index]
		        hightlightColor: normalColor
		        checked: uavButtonGroup.currentIndex === index
		        scale: uavButtonGroup.currentIndex === index ? 1 : 0.8
		        backRadius: 4
		        onClicked: {
					uavButtonGroup.currentIndex = index
		        }
		    }
        }

	    Row {
			height: parent.height

            spacing: divideLineThickness

			Loader {
	            sourceComponent: uavButtonComponent
                onLoaded: item.index = 0
            }
			Loader {
	            sourceComponent: uavButtonComponent
                onLoaded: item.index = 1
            }
			Loader {
	            sourceComponent: uavButtonComponent
                onLoaded: item.index = 2
            }
			Loader {
	            sourceComponent: uavButtonComponent
                onLoaded: item.index = 3
            }
	    }
	}
	Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        text: qsTr("Import Plan")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {
        }
    }
    Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        width: parent.width
        height: parent.height * 0.25
        text: qsTr("Save as different")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {
        }
    }
}
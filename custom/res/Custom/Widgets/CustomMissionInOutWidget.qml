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
import QtQuick.Layouts  1.2
import QtQuick.Window   2.2

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.Palette           1.0
import QGroundControl.Controllers       1.0
import QGroundControl.ShapeFileHelper   1.0
import QGroundControl.Vehicle           1.0

Column {
    id: root
    height: parent.height

    property var eventHandler
	property real divideLineThickness: 2
	property var vehicles: QGroundControl.multiVehicleManager.vehiclesForUi
	property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    readonly property int eButtonSendPlan: 0
    readonly property int eButtonImportPlan: 1
    readonly property int eButtonSavePlan: 2

    signal buttonClicked(int index)

    onActiveVehicleChanged: updateActiveVehicle()
    Component.onCompleted: updateActiveVehicle()

    function isConnectedIndex(index) {
        return index >= 0 && index < 4 && vehicles.get(index) !== null
    }

    function updateActiveVehicle() {
        for (var i = 0; i < vehicles.rowCount(); i++) {
            if (vehicles.get(i) !== null && vehicles.get(i) === QGroundControl.multiVehicleManager.activeVehicle) {
                uavButtonGroup.currentIndex = i
                break;
            }
        }
    }

    function setUavCurrentIndex(index) {
        console.log("setUavCurrentIndex index:" + index)
        if (isConnectedIndex(index)) {
            uavButtonGroup.currentIndex = index

            QGroundControl
            .multiVehicleManager
            .activeVehicle = vehicles.get(uavButtonGroup.currentIndex)
        }
    }

    CustomButton {
        id: sendPlanButton
        width: parent.width
        height: parent.height * 0.25
        text: qsTr("Send plan")
        pointSize: ScreenTools.mediumFontPointSize
        enabled: activeVehicle !== null
        onClicked: {
            buttonClicked(eButtonSendPlan)
        }
    }
	CustomPanel {
        id: uavButtonGroup
		width: parent.width
        height: parent.height * 0.25 - divideLineThickness

        property var colorList: QGroundControl.multiVehicleManager.vehicleColorList
        property int currentIndex: -1

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
		        enabled: isConnectedIndex(index)
		        onClicked: {
		            setUavCurrentIndex(index)
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

            Component.onCompleted: updateActiveVehicle()
	    }
	}
	Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        width: parent.width
        height: parent.height * 0.25 - divideLineThickness
        text: qsTr("Import plan")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {
            buttonClicked(eButtonImportPlan)
        }
    }
    Rectangle { width: parent.width; height: divideLineThickness; color: "white"; opacity: 0.8 }
    CustomButton {
        width: parent.width
        height: parent.height * 0.25
        text: qsTr("Save plan as different name")
        pointSize: ScreenTools.mediumFontPointSize
        onClicked: {
            buttonClicked(eButtonSavePlan)
        }
    }
}
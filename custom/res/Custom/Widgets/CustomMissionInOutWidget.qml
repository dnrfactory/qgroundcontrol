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

    property var _planMasterController: globals.planMasterControllerPlanView
    property bool _controllerValid: _planMasterController !== undefined && _planMasterController !== null
    property var _controllerDirty: _controllerValid ? _planMasterController.dirty : false
    property var  _controllerSyncInProgress: _controllerValid ? _planMasterController.syncInProgress : false
    property real _controllerProgressPct: _controllerValid ? _planMasterController.missionController.progressPct : 0

    readonly property int eButtonSendPlan: 0
    readonly property int eButtonImportPlan: 1
    readonly property int eButtonSavePlan: 2
    readonly property int eButtonSavePlanAs: 3

    signal buttonClicked(int index)

    onActiveVehicleChanged: updateActiveVehicle()
    Component.onCompleted: updateActiveVehicle()
    on_ControllerSyncInProgressChanged: console.log("on_ControllerSyncInProgressChanged:" + _controllerSyncInProgress)
    on_ControllerProgressPctChanged: console.log("on_ControllerProgressPctChanged:" + _controllerProgressPct)

    function isConnectedIndex(index) {
        return index >= 0 && index < 4 && vehicles.get(index) !== null
    }

    function updateActiveVehicle() {
        var currentIndex_ = -1
        for (var i = 0; i < vehicles.rowCount(); i++) {
            if (vehicles.get(i) !== null && vehicles.get(i) === QGroundControl.multiVehicleManager.activeVehicle) {
                currentIndex_ = i
                break;
            }
        }
        uavButtonGroup.currentIndex = currentIndex_
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
        text: activeVehicle !== null && _controllerDirty ? qsTr("Upload Required") : qsTr("Upload")
        pointSize: ScreenTools.mediumFontPointSize
        enabled: activeVehicle !== null
        onClicked: {
            buttonClicked(eButtonSendPlan)
        }

        blinking: activeVehicle !== null && _controllerDirty && !_controllerSyncInProgress

        Rectangle {
            id: progressPopup
            anchors.fill: parent
            visible: false
            color: parent.normalColor

            property var progress: root._controllerProgressPct

            QGCLabel {
                id: progressLabel
                anchors.centerIn: parent
                font.pointSize: ScreenTools.mediumFontPointSize
            }

            Timer {
                id: progressPopupTimer
                interval: 3000
                onTriggered: {
                    progressPopup.visible = false
                }
            }

            onProgressChanged: {
                if (progress === 1) {
                    progressLabel.text = qsTr("Done")
                    progressPopupTimer.start()
                }
                else if (progress > 0) {
                    progressLabel.text = qsTr("Uploading %1 \%").arg((progress * 100).toFixed(0))
                    progressPopup.visible = true
                }
            }

            DeadMouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("DeadMouseArea onClicked")
                    progressPopup.visible = false
                    progressPopupTimer.stop()
                }
            }
        }
    }
    Item {
        id: uavButtonGroup
		width: parent.width
        height: parent.height * 0.25 - divideLineThickness

        property var colorList: QGroundControl.multiVehicleManager.vehicleColorList
        property int currentIndex: -1

        Component {
            id: uavButtonComponent
            CustomButton {
                property int index

                width: root.width * 0.25 - divideLineThickness
                height: uavButtonGroup.height
                text: qsTr("UAV %1").arg(index + 1)
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
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
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
    Row {
        CustomButton {
            id: saveButton
            width: root.width * 0.5 - divideLineThickness * 0.5
            height: root.height * 0.25
            text: qsTr("Save")
            pointSize: ScreenTools.mediumFontPointSize
            enabled: !_controllerSyncInProgress && _planMasterController.currentPlanFile !== ""
            onClicked: {
                buttonClicked(eButtonSavePlan)
            }
        }
        Rectangle { width: divideLineThickness; height: parent.height; color: "white"; opacity: 0.8 }
        CustomButton {
            width: saveButton.width
            height: saveButton.height
            text: qsTr("Save as...")
            pointSize: ScreenTools.mediumFontPointSize
            enabled: !_controllerSyncInProgress && _planMasterController.containsItems
            onClicked: {
                buttonClicked(eButtonSavePlanAs)
            }
        }
    }
}
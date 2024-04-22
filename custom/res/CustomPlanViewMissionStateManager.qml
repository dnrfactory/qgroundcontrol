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

Item {
    id: root

    property var planMasterController
    property var missionController: planMasterController.missionController
    property var addWaypointRallyPointAction_
    property var mapCenter
    property var missionCreator
    property var missionInOutWidget
    property var missionShortCutWidget

    property int missionEditStatus: eMissionEditEmpty

    readonly property int eMissionEditEmpty: 0
    readonly property int eMissionEditWayPointCreate: 1
    readonly property int eMissionEditWayPointAdd: 2
    readonly property int eMissionEditCorridorScanAdd: 3
    readonly property int eMissionEditMapControl: 4

    readonly property int eEventMissionEditStart: 100
    readonly property int eEventMissionEditWayPointButtonClicked: eEventMissionEditStart
    readonly property int eEventMissionEditTracingButtonClicked: eEventMissionEditStart + 1
    readonly property int eEventMissionEditClearTracingButtonClicked: eEventMissionEditStart + 2
    readonly property int eEventMissionEditResetButtonClicked: eEventMissionEditStart + 3
    readonly property int eEventMissionEditPlanFileChanged: eEventMissionEditStart + 4
    readonly property int eEventMissionEditFlyThroughCommandsAllowedChanged: eEventMissionEditStart + 5
    readonly property int eEventMissionEditTracingItemRemoved: eEventMissionEditStart + 6

    property int eBlank: 0
    property int eWayPoint: 1
    property int eCorridorScan: 2

    Component.onCompleted: {
        missionCreator.buttonClicked.connect(handleEventMissionCreator)
        missionInOutWidget.buttonClicked.connect(handleEventMissionInOutWidget)
        missionShortCutWidget.missionItemClicked.connect(onMissionItemClicked)
        missionShortCutWidget.shortcutAddItemClicked.connect(onShortcutAddItemClicked)
        missionShortCutWidget.shortcutRemoveItemClicked.connect(onShortcutRemoveItemClicked)
    }

    Connections {
        target: planMasterController
        onCurrentPlanFileChanged: {
            console.log("CustomPlanViewMissionStateManager onCurrentPlanFileChanged currentPlanFile:" + planMasterController.currentPlanFile)
            processMissionEditEvent(eEventMissionEditPlanFileChanged)
        }
    }
    Connections {
        target: missionController
        onFlyThroughCommandsAllowedChanged: {
            console.log("onFlyThroughCommandsAllowedChanged " + missionController.flyThroughCommandsAllowed)
            missionCreator.isMissionAddEnable = missionController.flyThroughCommandsAllowed
            processMissionEditEvent(eEventMissionEditFlyThroughCommandsAllowedChanged)
        }
    }

    function corridorScanItemRemoved() {
        console.log("corridorScanItemRemoved")
        if (missionEditStatus === eMissionEditCorridorScanAdd &&
            missionController.getCorridorScanComplexItemIndex() === -1) {
            processMissionEditEvent(eEventMissionEditTracingItemRemoved)
        }
    }

    function onMissionItemClicked(fileName) {
        var savePath = QGroundControl.settingsManager.appSettings.missionSavePath
        var filePath = "%1/%2%3".arg(savePath).arg(fileName).arg(".plan")

        console.log("onMissionItemClicked filePath: %1".arg(filePath))

        if (planMasterController.dirty) {
            var obj =  syncLoadFromFileOverwrite.createObject(mainWindow)
            obj.filePath = filePath
            obj.open()
        }
        else {
            processMissionEditEvent(eEventMissionEditResetButtonClicked)
            planMasterController.loadFromFile(filePath)
            planMasterController.fitViewportToItems()
            if (missionController.missionItemCount === 1) {
                missionController.setCurrentPlanViewSeqNum(0, true)
            }
        }
    }

    function onShortcutAddItemClicked() {
        var filePath = planMasterController.currentPlanFileBaseName
        if (filePath.length == 0) {
            if (!planMasterController.syncInProgress && planMasterController.containsItems) {
                planMasterController.saveToSelectedFileAndAddToShortcut()
            }
        }
        else {
            planMasterController.addToShortcutList(filePath)
        }
    }

    function onShortcutRemoveItemClicked(fileName) {
        planMasterController.removeFromShortcutList(fileName)
    }

    function handleEventMissionCreator(index) {
        processMissionEditEvent(eEventMissionEditStart + index)
    }

    function handleEventMissionInOutWidget(index) {
        console.log("handleEventMissionInOutWidget %1".arg(index))
        switch (index) {
        case missionInOutWidget.eButtonSendPlan:
            planMasterController.upload()
            break;
        case missionInOutWidget.eButtonImportPlan:
            if (planMasterController.dirty) {
                syncLoadFromFileOverwrite.createObject(mainWindow).open()
            }
            else {
                processMissionEditEvent(eEventMissionEditResetButtonClicked)
                planMasterController.loadFromSelectedFile()
            }
            break;
        case missionInOutWidget.eButtonSavePlan:
            planMasterController.saveToCurrent()
            break;
        case missionInOutWidget.eButtonSavePlanAs:
            planMasterController.saveToSelectedFile()
            break;
        }
    }

    function processMissionEditEvent(event) {
        console.log("processMissionEditEvent event:%1".arg(event))

        switch (missionEditStatus) {
        case eMissionEditEmpty:
            processMissionEditEventOnEmpty(event);
            break;
        case eMissionEditWayPointCreate:
            processMissionEditEventOnWayPointCreate(event)
            break;
        case eMissionEditWayPointAdd:
            processMissionEditEventOnWayPointAdd(event);
            break;
        case eMissionEditCorridorScanAdd:
            processMissionEditEventOnCorridorScanAdd(event);
            break;
        case eMissionEditMapControl:
            processMissionEditEventOnMapControl(event);
            break;
        }
    }

    function processMissionEditEventOnEmpty(event) {
        console.log("processMissionEditEventOnEmpty event:%1".arg(event))
        switch (event) {
        case eEventMissionEditWayPointButtonClicked:
            changeMissionEditStatus(eMissionEditWayPointCreate)
            break;
        case eEventMissionEditTracingButtonClicked:
            changeMissionEditStatus(eMissionEditCorridorScanAdd)
            break;
        case eEventMissionEditPlanFileChanged:
            if (planMasterController.currentPlanFile !== "") {
                changeMissionEditStatus(eMissionEditMapControl)
            }
            break;
        }
    }

    function processMissionEditEventOnWayPointCreate(event) {
        console.log("processMissionEditEventOnWayPointCreate event:%1".arg(event))
        switch (event) {
        case eEventMissionEditWayPointButtonClicked:
            changeMissionEditStatus(eMissionEditMapControl)
            break;
        case eEventMissionEditResetButtonClicked:
            changeMissionEditStatus(eMissionEditEmpty)
            break;
        case eEventMissionEditPlanFileChanged:
            if (planMasterController.currentPlanFile !== "") {
                changeMissionEditStatus(eMissionEditMapControl)
            }
            break;
        case eEventMissionEditFlyThroughCommandsAllowedChanged:
            if (missionController.flyThroughCommandsAllowed === true) {
                changeMissionEditStatus(eMissionEditWayPointAdd)
            }
            break;
        }
    }

    function processMissionEditEventOnWayPointAdd(event) {
        console.log("processMissionEditEventOnWayPointAdd event:%1".arg(event))
        switch (event) {
        case eEventMissionEditWayPointButtonClicked:
            changeMissionEditStatus(eMissionEditMapControl)
            break;
        case eEventMissionEditTracingButtonClicked:
            changeMissionEditStatus(eMissionEditCorridorScanAdd)
            break;
        case eEventMissionEditResetButtonClicked:
            changeMissionEditStatus(eMissionEditEmpty)
            break;
        case eEventMissionEditPlanFileChanged:
            if (planMasterController.currentPlanFile !== "") {
                changeMissionEditStatus(eMissionEditMapControl)
            }
            break;
        case eEventMissionEditFlyThroughCommandsAllowedChanged:
            if (missionController.flyThroughCommandsAllowed === false) {
                changeMissionEditStatus(eMissionEditMapControl)
            }
            break;
        }
    }

    function processMissionEditEventOnCorridorScanAdd(event) {
        console.log("processMissionEditEventOnCorridorScanAdd event:%1".arg(event))
        switch (event) {
        case eEventMissionEditWayPointButtonClicked:
            changeMissionEditStatus(eMissionEditWayPointAdd)
            break;
        case eEventMissionEditClearTracingButtonClicked:
            removeCorridorScanVisualItem()
            changeMissionEditStatus(eMissionEditMapControl)
            break;
        case eEventMissionEditResetButtonClicked:
            changeMissionEditStatus(eMissionEditEmpty)
            break;
        case eEventMissionEditPlanFileChanged:
            if (planMasterController.currentPlanFile !== "") {
                changeMissionEditStatus(eMissionEditMapControl)
            }
            break;
        case eEventMissionEditTracingItemRemoved:
            if (missionController.visualItems.rowCount() <= 1) {
                changeMissionEditStatus(eMissionEditEmpty)
            }
            else {
                changeMissionEditStatus(eMissionEditMapControl)
            }
            break;
        }
    }

    function processMissionEditEventOnMapControl(event) {
        console.log("processMissionEditEventOnMapControl event:%1".arg(event))
        switch (event) {
        case eEventMissionEditWayPointButtonClicked:
            changeMissionEditStatus(eMissionEditWayPointAdd)
            break;
        case eEventMissionEditTracingButtonClicked:
            changeMissionEditStatus(eMissionEditCorridorScanAdd)
            break;
        case eEventMissionEditClearTracingButtonClicked:
            removeCorridorScanVisualItem()
            break;
        case eEventMissionEditResetButtonClicked:
            changeMissionEditStatus(eMissionEditEmpty)
            break;
        }
    }

    function changeMissionEditStatus(status) {
        console.log("changeMissionEditStatus _missionEditStatus:%1, status:%2".arg(missionEditStatus).arg(status))
        var prevStatus = missionEditStatus
        missionEditStatus = status

        switch (missionEditStatus) {
        case eMissionEditEmpty:
            planMasterController.planCreators.get(eBlank).createPlan(mapCenter())
            break;
        case eMissionEditWayPointCreate:
            switch (prevStatus) {
            case eMissionEditEmpty:
                planMasterController.planCreators.get(eWayPoint).createPlan(mapCenter())
                break;
            }
            break;
        case eMissionEditWayPointAdd:
            break;
        case eMissionEditCorridorScanAdd:
            switch (prevStatus) {
            case eMissionEditEmpty:
                planMasterController.planCreators.get(eCorridorScan).createPlan(mapCenter())
                break;
            case eMissionEditWayPointAdd:
            case eMissionEditMapControl:
                if (missionController.getCorridorScanComplexItemIndex() === -1) {
                    if (missionController.visualItems.rowCount() <= 1) {
                        planMasterController.planCreators.get(eCorridorScan).createPlan(mapCenter())
                    }
                    else {
                        missionController.insertComplexMissionItem("Corridor Scan"/*qsTr("Corridor Scan")*/,
                                                                   mapCenter(),
                                                                   missionController.currentPlanViewSeqNum + 1,
                                                                   true)
                    }
                }
                break;
            }
            missionController.setCurrentPlanViewSeqNum(missionController.getCorridorScanComplexItemSeqNum(), true)
            break;
        case eMissionEditMapControl:
            if (missionController.currentPlanViewSeqNum === 0) {
                var takeoffMissionItem = missionController.takeoffMissionItem
                if (takeoffMissionItem !== null) {
                    missionController.setCurrentPlanViewSeqNum(takeoffMissionItem.sequenceNumber, true)
                }
            }
            break;
        }

        addWaypointRallyPointAction_.checked = missionEditStatus === eMissionEditWayPointAdd
    }

    function removeCorridorScanVisualItem() {
        var corridorScanComplexItemIndex = missionController.getCorridorScanComplexItemIndex()
        if (corridorScanComplexItemIndex != -1) {
            missionController.removeVisualItem(corridorScanComplexItemIndex)
        }
    }

    Component {
        id: syncLoadFromFileOverwrite
        QGCSimpleMessageDialog {
            id:        syncLoadFromVehicleCheck
            title:      ""
            text:       qsTr("You have unsaved/unsent changes. Loading from a file will lose these changes. Are you sure you want to load from a file?")
            buttons:    StandardButton.Yes | StandardButton.No

            property string filePath: ""

            onAccepted: {
                processMissionEditEvent(eEventMissionEditResetButtonClicked)
                if (filePath.length === 0) {
                    planMasterController.loadFromSelectedFile()
                }
                else {
                    planMasterController.loadFromFile(filePath)
                    planMasterController.fitViewportToItems()
                    if (missionController.missionItemCount === 1) {
                        missionController.setCurrentPlanViewSeqNum(0, true)
                    }
                }
            }
        }
    }
}

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

    property int missionEditStatus: eMissionEditEmpty

    readonly property int eMissionEditEmpty: 0
    readonly property int eMissionEditWayPointAdd: 1
    readonly property int eMissionEditCorridorScanAdd: 2
    readonly property int eMissionEditMapControl: 3

    readonly property int eEventMissionEditStart: 100
    readonly property int eEventMissionEditWayPointButtonClicked: eEventMissionEditStart
    readonly property int eEventMissionEditTracingButtonClicked: eEventMissionEditStart + 1
    readonly property int eEventMissionEditClearTracingButtonClicked: eEventMissionEditStart + 2
    readonly property int eEventMissionEditResetButtonClicked: eEventMissionEditStart + 3

    property int eBlank: 0
    property int eWayPoint: 1
    property int eCorridorScan: 2

    Component.onCompleted: {
        missionCreator.buttonClicked.connect(handleEventMissionCreator)
        missionInOutWidget.buttonClicked.connect(handleEventMissionInOutWidget)
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
            if (_planMasterController.dirty) {
                syncLoadFromFileOverwrite.createObject(mainWindow).open()
            }
            else {
                processMissionEditEvent(eEventMissionEditResetButtonClicked)
                planMasterController.loadFromSelectedFile()
            }
            break;
        case missionInOutWidget.eButtonSavePlan:
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
            changeMissionEditStatus(eMissionEditWayPointAdd)
            break;
        case eEventMissionEditTracingButtonClicked:
            changeMissionEditStatus(eMissionEditCorridorScanAdd)
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
        case eEventMissionEditClearTracingButtonClicked:
            removeCorridorScanVisualItem()
            break;
        case eEventMissionEditResetButtonClicked:
            changeMissionEditStatus(eMissionEditEmpty)
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
        case eMissionEditWayPointAdd:
            switch (prevStatus) {
            case eMissionEditEmpty:
                planMasterController.planCreators.get(eWayPoint).createPlan(mapCenter())
                break;
            }
            break;
        case eMissionEditCorridorScanAdd:
            switch (prevStatus) {
            case eMissionEditEmpty:
                planMasterController.planCreators.get(eCorridorScan).createPlan(mapCenter())
                break;
            case eMissionEditWayPointAdd:
            case eMissionEditMapControl:
                if (missionController.getCorridorScanComplexItemIndex() == -1) {
                    planMasterController.planCreators.get(eCorridorScan).createPlan(mapCenter())
                }
                break;
            }
            missionController.setCurrentPlanViewSeqNum(missionController.getCorridorScanComplexItemSeqNum(), true)
            break;
        case eMissionEditMapControl:
            removeCorridorScanVisualItem()
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

            onAccepted: {
                processMissionEditEvent(eEventMissionEditResetButtonClicked)
                planMasterController.loadFromSelectedFile()
            }
        }
    }
}

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

    property bool isMultiVehicleMode

    property real  _bottomPanelTopPadding: 20
    property real  _bottomPanelMargin: 20

    property var   _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    readonly property int actionRTL:                        1
    readonly property int actionArm:                        4
    readonly property int actionDisarm:                     5
    readonly property int actionStartMission:               12
    readonly property int actionResumeMission:              14
    readonly property int actionPause:                      17
    readonly property int actionMVPause:                    18
    readonly property int actionMVStartMission:             19

    readonly property int eMainStatusCommLost: 0
    readonly property int eMainStatusReadyToFly: 1
    readonly property int eMainStatusNotReadyToFly: 2
    readonly property int eMainStatusDisconnected: 3
    readonly property int eMainStatusArmed: 4
    readonly property int eMainStatusFlying: 5
    readonly property int eMainStatusWaiting: 6

    property int mainStatus: getMainStatus()

    height:                 _bottomPanelHeight
    width:                  (_bottomPanelWidth/2 - 4)

    function getMainStatus() {
        if (_activeVehicle === null || _activeVehicle === undefined) {
            return eMainStatusDisconnected
        }

        if (_communicationLost) {
            return eMainStatusCommLost
        }

        if (_activeVehicle.armed) {
            if (_activeVehicle.flying) {
                return eMainStatusFlying
            }
            if (_activeVehicle.landing) {
                return eMainStatusWaiting
            }
            return eMainStatusArmed
        }

        if (_activeVehicle.healthAndArmingCheckReport.supported) {
            if (_activeVehicle.healthAndArmingCheckReport.canArm) {
                return eMainStatusReadyToFly
            }
            return eMainStatusNotReadyToFly
        }

        if (_activeVehicle.readyToFlyAvailable) {
            if (_activeVehicle.readyToFly) {
                return eMainStatusReadyToFly
            }
            return eMainStatusNotReadyToFly
        }
        // Best we can do is determine readiness based on
        // AutoPilot component setup and health indicators from SYS_STATUS
        if (_activeVehicle.allSensorsHealthy
            && _activeVehicle.autopilot.setupComplete) {
            return eMainStatusReadyToFly
        }
        return eMainStatusNotReadyToFly
    }

    Column {
        spacing: _bottomPanelTopPadding/2
        anchors.centerIn: parent
        anchors.margins: _bottomPanelMargin

        QGCLabel{
            id :                        customStatusLabel
            text:                       mainStatusTextArray[mainStatus]
            font.pointSize:             ScreenTools.mediumFontPointSize
            font.bold :                 true
            color:                      mainStatusColorArray[mainStatus]
            anchors.horizontalCenter:   parent.horizontalCenter

            property string _commLostText:       qsTr("Communication Lost")
            property string _readyToFlyText:     qsTr("Ready To Fly")
            property string _notReadyToFlyText:  qsTr("Not Ready")
            property string _disconnectedText:   qsTr("Disconnected")
            property string _armedText:          qsTr("Armed")
            property string _flyingText:         qsTr("Flying")
            property string _waitingText:        qsTr("Waiting")

            readonly property var mainStatusTextArray: [
                qsTr("Communication Lost"),
                qsTr("Ready To Fly"),
                qsTr("Not Ready"),
                qsTr("Disconnected"),
                qsTr("Armed"),
                qsTr("Flying"),
                qsTr("Waiting")
            ]
            readonly property var mainStatusColorArray: [
                "red",
                "green",
                "yellow",
                "gray",
                "green",
                "green",
                "green"
            ]
        }

        Item {
            width: parent.width * 0.9
            height: width * 0.4
            CustomArmSwitchMulti {
                isMultiVehicleMode: root.isMultiVehicleMode
                vehicles: QGroundControl.multiVehicleManager.vehiclesForUi
                vehicle: _activeVehicle
                width: parent.width
            }
        }

        CustomButton {
            id: btnMissionStartPause
            readonly property int eBtnStateDisabled: 0
            readonly property int eBtnStateStartMission: 1
            readonly property int eBtnStateDiconnect: 2

            property int btnState: {
                switch (root.mainStatus) {
                case eMainStatusNotReadyToFly:
                case eMainStatusReadyToFly:
                case eMainStatusArmed:
                case eMainStatusFlying:
                case eMainStatusWaiting:
                    return eBtnStateStartMission;
                case eMainStatusCommLost:
                    return eBtnStateDiconnect;
                case eMainStatusDisconnected:
                default:
                    return eBtnStateDisabled;
                }
            }

            property var btnTextArray: [
                qsTr("Start mission"),
                qsTr("Start mission"),
                qsTr("Disconnect")
            ]

            width: root.width * 0.8
            height: root.height * 0.15
            backRadius: 10
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: _activeVehicle && btnState !== eBtnStateDisabled
            text: btnTextArray[btnState]
            pointSize: ScreenTools.mediumFontPointSize
            normalColor: "black"
            onClicked: {
                switch (btnState) {
                case eBtnStateStartMission:
                    console.log("Start Mission Button clicked")
                    if (isMultiVehicleMode === false) {
                        _activeVehicle.startMission()
                    }
                    else {
                        _guidedController.executeAction(actionMVStartMission)
                    }
                    break;
                case eBtnStateDiconnect:
                    console.log("Disconnect Button clicked")
                    if (isMultiVehicleMode === false) {
                        _activeVehicle.closeVehicle()
                    }
                    else {
                        var mvm = QGroundControl.multiVehicleManager
                        var rowCount = mvm.vehiclesForUi.rowCount()
                        for (var i = 0; i < rowCount; i ++) {
                            var vehicle = mvm.vehiclesForUi.get(i)
                            if (vehicle !== null && vehicle.vehicleLinkManager.communicationLost) {
                                vehicle.closeVehicle()
                            }
                        }
                    }
                    break;
                }
            }
        }

        Row {
            id: pauseReturnButtonGroup
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: _bottomPanelTopPadding/2
            CustomButton {
                width: root.width * 0.4 - pauseReturnButtonGroup.spacing * 0.5
                height: root.height * 0.15
                backRadius: 10
                enabled: _activeVehicle
                text: qsTr("Pause")
                pointSize: ScreenTools.mediumFontPointSize
                normalColor: "black"
                onClicked: {
                    console.log("Pause Button clicked")
                    if (isMultiVehicleMode === false) {
                        _activeVehicle.pauseVehicle()
                    }
                    else {
                        _guidedController.executeAction(actionMVPause)
                    }
                }
            }
            CustomButton {
                width: root.width * 0.4 - pauseReturnButtonGroup.spacing * 0.5
                height: root.height * 0.15
                backRadius: 10
                enabled: _activeVehicle
                text: qsTr("Return")
                pointSize: ScreenTools.mediumFontPointSize
                normalColor: "black"
                onClicked: {
                    console.log("Return Button clicked")
                    if (isMultiVehicleMode === false) {
                        _guidedController.executeAction(actionRTL)
                    }
                    else {
                        var mvm = QGroundControl.multiVehicleManager
                        var rowCont = mvm.vehiclesForUi.rowCount()
                        for (var i = 0; i < rowCont; i ++) {
                            var vehicle = mvm.vehiclesForUi.get(i)
                            if (vehicle !== null) {
                                vehicle.guidedModeRTL(false)
                            }
                        }
                    }
                }
            }
        }

        Row {
            id: takeoffLandButtonGroup
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: _bottomPanelTopPadding/2
            CustomButton {
                width: root.width * 0.4 - takeoffLandButtonGroup.spacing * 0.5
                height: root.height * 0.15
                backRadius: 10
                enabled: _activeVehicle
                text: qsTr("Takeoff")
                pointSize: ScreenTools.mediumFontPointSize
                normalColor: "black"
                onClicked: {
                    console.log("Takeoff Button clicked")

                    if (isMultiVehicleMode === false) {
                        _activeVehicle.guidedModeTakeoff(_activeVehicle.minimumTakeoffAltitude())
                    }
                    else {
                        var mvm = QGroundControl.multiVehicleManager
                        var rowCont = mvm.vehiclesForUi.rowCount()
                        for (var i = 0; i < rowCont; i ++) {
                            var vehicle = mvm.vehiclesForUi.get(i)
                            if (vehicle !== null) {
                                vehicle.guidedModeTakeoff(vehicle.minimumTakeoffAltitude())
                            }
                        }
                    }
                }
            }
            CustomButton {
                width: root.width * 0.4 - takeoffLandButtonGroup.spacing * 0.5
                height: root.height * 0.15
                backRadius: 10
                enabled: _activeVehicle
                text: qsTr("Land")
                pointSize: ScreenTools.mediumFontPointSize
                normalColor: "black"
                onClicked: {
                    console.log("Land Button clicked")

                    if (isMultiVehicleMode === false) {
                        _activeVehicle.guidedModeLand()
                    }
                    else {
                        var mvm = QGroundControl.multiVehicleManager
                        var rowCont = mvm.vehiclesForUi.rowCount()
                        for (var i = 0; i < rowCont; i ++) {
                            var vehicle = mvm.vehiclesForUi.get(i)
                            if (vehicle !== null) {
                                vehicle.guidedModeLand()
                            }
                        }
                    }
                }
            }
        }
    }
}

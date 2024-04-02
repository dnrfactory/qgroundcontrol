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

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.Controllers       1.0
import QGroundControl.ShapeFileHelper   1.0
import QGroundControl.Vehicle           1.0

Item {
    id: root
    height: parent.height

    property var _planMasterController: globals.planMasterControllerPlanView
    property bool _controllerValid: planMasterController !== undefined && planMasterController !== null
    property real _controllerProgressPct: _controllerValid ? _planMasterController.missionController.progressPct : 0

    property var vehicles: QGroundControl.multiVehicleManager.vehiclesForUi
    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    property var vehiclesPlanName_0: ""
    property var vehiclesPlanName_1: ""
    property var vehiclesPlanName_2: ""
    property var vehiclesPlanName_3: ""

    readonly property real verticalMargin: 40 + 4 * 3
    readonly property real horizontalMargin: verticalMargin
    readonly property real textPadding: horizontalMargin / 2

    property var colorList: QGroundControl.multiVehicleManager.vehicleColorList

    on_ControllerProgressPctChanged: {
        if (_controllerProgressPct === 1 && _planMasterController.currentPlanFile !== "") {
            for (var i = 0; i < vehicles.rowCount(); i++) {
                if (vehicles.get(i) !== null && vehicles.get(i) === QGroundControl.multiVehicleManager.activeVehicle) {
                    setPlanName(i, _planMasterController.currentPlanFileBaseName)
                }
            }
        }
    }

    function setPlanName(index, name) {
        switch (index) {
        case 0: vehiclesPlanName_0 = name
            break
        case 1: vehiclesPlanName_1 = name
            break
        case 2: vehiclesPlanName_2 = name
            break
        case 3: vehiclesPlanName_3 = name
            break
        }
    }

    function getPlanName(index) {
        switch (index) {
        case 0: return vehiclesPlanName_0
        case 1: return vehiclesPlanName_1
        case 2: return vehiclesPlanName_2
        case 3: return vehiclesPlanName_3
        }
    }

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: 4
            Item {
                width: root.width - horizontalMargin
                height: (root.height - verticalMargin - column.spacing * 3) / 4

                Rectangle {
                    anchors.fill: parent
                    color: colorList[index]
                    opacity: 0.3
                    radius: 4
                }
                Text {
                    width: parent.width / 2 - textPadding
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: textPadding
                    font.pointSize: ScreenTools.mediumFontPointSize
                    color: qgcPal.text
                    text: "UAV %1".arg(index + 1)
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    clip: true
                }
                Text {
                    anchors.fill: parent
                    font.pointSize: ScreenTools.mediumFontPointSize
                    color: qgcPal.text
                    text: "-"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    width: parent.width / 2 - textPadding
                    height: parent.height
                    anchors.left: parent.horizontalCenter
                    anchors.leftMargin: textPadding
                    font.pointSize: ScreenTools.mediumFontPointSize
                    color: qgcPal.text
                    text: getPlanName(index)
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    clip: true
                    elide: Text.ElideRight
                }
            }
        }
    }
}

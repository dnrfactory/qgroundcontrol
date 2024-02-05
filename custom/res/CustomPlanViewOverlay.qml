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
import Custom.Widgets               1.0

Item {
    id: root

    property var bottomPanelHeight: bottomPanel.height

    property var planView
    property var missionCreator: _missionCreator
    property var missionInOutWidget: _missionInOutWidget
    property var missionShortCutWidget: _missionShortCutWidget
    property var missionEditEventHandler

    DeadMouseArea {
        anchors.fill: bottomPanel
    }

    CustomPanel {
        anchors.fill: bottomPanel
    }

    Row {
        id: bottomPanel
        height: ScreenTools.defaultFontPixelWidth * 40
        anchors.bottom: parent.bottom
        visible: root.visible

        property real divideLineThickness: 2

        CustomMissionCreateWidget {
            id: _missionCreator
            width: root.width * 0.2 - bottomPanel.divideLineThickness
            eventHandler: root.missionEditEventHandler
        }
        Rectangle { width: bottomPanel.divideLineThickness; height: parent.height; color: "white"; opacity: 0.8 }
        CustomMissionInOutWidget {
            id: _missionInOutWidget
            width: root.width * 0.2 - bottomPanel.divideLineThickness
            eventHandler: root.missionEditEventHandler
        }
        Rectangle { width: bottomPanel.divideLineThickness; height: parent.height; color: "white"; opacity: 0.8 }
        CustomMissionShortcutWidget {
            id: _missionShortCutWidget
            width: root.width * 0.2 - bottomPanel.divideLineThickness
            planMasterController: planView._planMasterController
        }
        Rectangle { width: bottomPanel.divideLineThickness; height: parent.height; color: "white"; opacity: 0.8 }
        CustomMissionVehicleWidget {
            width: root.width * 0.2 - bottomPanel.divideLineThickness
        }
        Rectangle { width: bottomPanel.divideLineThickness; height: parent.height; color: "white"; opacity: 0.8 }
        CustomMissionInfoWidget {
            width: root.width * 0.2
            planMasterController: planView._planMasterController
        }
    }

    CustomVisibleAnimator {
        animationTarget: bottomPanel
    }
}

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
import QtQuick.Window           2.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0

Row {
    id: root

    readonly property real panelMargin: 2

    property var mapControl
    property bool isMultiVehicleMode

    spacing: 0

    CustomTelemetryValuePanel {
        id: telemetryPanel
        height: parent.height
        width: parent.width * 0.2 - panelMargin
    }
    Rectangle { width: panelMargin; height: parent.height; color: "white"; opacity: 0.8 }
    CustomWeatherPanel {
        id: customWeatherPanel
        height: parent.height
        width: parent.width * 0.2 - panelMargin
        mapCenterPosition: root.mapControl.center
    }
    Rectangle { width: panelMargin; height: parent.height; color: "white"; opacity: 0.8 }
    CustomArmPanel {
        id: customArmPanel
        height: parent.height
        width: parent.width * 0.1 - panelMargin
        isMultiVehicleMode: root.isMultiVehicleMode
    }
    Rectangle { width: panelMargin; height: parent.height; color: "white"; opacity: 0.8 }
    CustomPanel {
        id: instrumentPanel
        width: parent.width * 0.1 - panelMargin
        height: parent.height

        FlyViewInstrumentPanel {
            anchors.centerIn: parent
            width: 0.5 * parent.height
        }
    }
    Rectangle { width: panelMargin; height: parent.height; color: "white"; opacity: 0.8 }
    // ----------------------------------------
    //
    // ----------------------------------------
    //                       |
    //                       |
    //                       |
    // ----------------------------------------
    Column {
        spacing: 0

        CustomFlyModePanel {
            id: customModePanel
            height: root.height * 0.3 - panelMargin
            width: root.width * 0.4
        }
        Rectangle { width: root.width * 0.4; height: panelMargin; color: "white"; opacity: 0.8 }
        Row {
            CustomFlyCameraControlPanel {
                height: root.height * 0.7
                width: root.width * 0.4 * 0.6 - panelMargin
            }
            Rectangle { width: panelMargin; height: parent.height; color: "white"; opacity: 0.8 }
            CustomPanel {
                height: root.height * 0.7
                width: root.width * 0.4 * 0.4
                PhotoVideoControl {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    visible: true
                }
            }
        }
    }
}

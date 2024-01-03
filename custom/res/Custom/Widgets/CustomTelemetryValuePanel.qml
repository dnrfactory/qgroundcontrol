/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                      2.12
import QtQuick.Layouts              1.12

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0

Rectangle {
    id: root
    color: qgcPal.window
    opacity: 0.8

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property string vehicleName: "UAV 0"
    property string vehicleNameColor: "grey"
    property real itemVerticalSpacing: ScreenTools.defaultFontPixelWidth * 1.8
    property var colorList: ["#ffa07a", "#97ff7a", "#7ad9ff", "#e37aff"]

    onActiveVehicleChanged: {
        console.log("onActiveVehicleChanged")
        updateVehicleName()
    }

    function updateVehicleName() {
        if (activeVehicle === null) {
            vehicleName = "UAV 0"
            vehicleNameColor = "grey"
        }
        else {
            var vIndex = activeVehicle.id - 128
            vehicleName = "UAV %1".arg(vIndex)
            if (vIndex >= 0 && vIndex < 4) {
                vehicleNameColor = colorList[vIndex]
            }
        }
    }

    Column {
        id: telemetryLayout
        anchors.fill: parent
        anchors.topMargin: itemVerticalSpacing * 0.8
        spacing: itemVerticalSpacing

        Rectangle {
            id: vehiclaNameLabel
            x: 30
            width: ScreenTools.mediumFontPointSize * 6
            height: ScreenTools.mediumFontPointSize * 2.5
            color: vehicleNameColor
            radius: 5
            QGCLabel {
                text: vehicleName
                font.pointSize: ScreenTools.mediumFontPointSize
                anchors.centerIn: parent
            }
        }

        HorizontalFactValueGrid {
            id:                     valueArea
            defaultSettingsGroup:   telemetryBarDefaultSettingsGroup

            width: root.width
            height: root.height - vehiclaNameLabel.height

            itemVerticalSpacing: root.itemVerticalSpacing
        }
    }
}


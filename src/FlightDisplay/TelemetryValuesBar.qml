/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
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

Item {
    id:                 telemetryPanel
    height:             _bottomPanelHeight
    width:              _bottomPanelWidth * 1.5

    Rectangle {
        anchors.fill:           parent
        color:                  qgcPal.window
        opacity:                0.8
        radius:                 _bottomPanelRadious
    }

    ColumnLayout {
        id:                     telemetryLayout
        anchors.centerIn:       parent

        HorizontalFactValueGrid {
            id:                     valueArea
            defaultSettingsGroup:   telemetryBarDefaultSettingsGroup
        }
    }
}

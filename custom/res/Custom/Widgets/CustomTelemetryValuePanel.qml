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
    id:                  root
    color:               qgcPal.window
    opacity:             0.8

    ColumnLayout {
        id:                     telemetryLayout
        anchors.centerIn:       parent

        HorizontalFactValueGrid {
            id:                     valueArea
            defaultSettingsGroup:   telemetryBarDefaultSettingsGroup
        }
    }
}


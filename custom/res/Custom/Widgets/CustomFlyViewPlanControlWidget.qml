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
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Row {
    readonly property real  _bottomPanelWidth:          ScreenTools.defaultFontPixelWidth * 35                  // Width        : 280
    readonly property real  _bottomPanelHeight:         ScreenTools.defaultFontPixelWidth * 30                  // Height       : 240

    readonly property real  _bottomPanelMargin:         ScreenTools.defaultFontPixelWidth * 2                  // Margin       : 16

    readonly property real  _bottomPanelLeftPadding:    ScreenTools.defaultFontPixelWidth * 2                 // LeftPadding  : 16
    readonly property real  _bottomPanelTopPadding:     ScreenTools.defaultFontPixelWidth * 2.5                 // TopPadding   : 20

    readonly property real  _bottomPanelRadious:        ScreenTools.defaultFontPixelWidth * 1.25

    spacing: _bottomPanelLeftPadding
    
    CustomTelemetryValuePanel {
        id:                 telemetryPanel
        height:             _bottomPanelHeight
        width:              _bottomPanelWidth * 1.5
        radius:             _bottomPanelRadious
    }

    CustomWeatherPanel {
        id:                 customWeatherPanel
        height:             _bottomPanelHeight
        width:              _bottomPanelWidth
        radius:             _bottomPanelRadious
    }

    CustomArmPanel {
        id:                 customArmPanel
        height:             _bottomPanelHeight
        width:              (_bottomPanelWidth/2 - 4)
        radius:             _bottomPanelRadious

        _bottomPanelTopPadding: _root._bottomPanelTopPadding
        _bottomPanelMargin: _root._bottomPanelMargin
    }

    FlyViewInstrumentPanel {
        id:                         instrumentPanel
        anchors.margins:            _bottomPanelMargin
        width:                      _bottomPanelHeight / 2
        availableHeight:            parent.height - y - _toolsMargin

        property real rightEdgeTopInset: visible ? parent.width - x : 0
        property real topEdgeRightInset: visible ? y + height : 0
    }

    Column {
        spacing: _bottomPanelMargin

        CustomFlyModePanel {
            id:                     customModePanel
            height:                 67
            width:                  _bottomPanelWidth * 2 + 12
            radius:                 _bottomPanelRadious

            _bottomPanelLeftPadding: _root._bottomPanelLeftPadding
            _bottomPanelMargin: _root._bottomPanelMargin
        }

        CustomFlyStatusInfoPanel {
            id:                     customStatusInformPanel
            height:                 157
            width:                  _bottomPanelWidth * 2 + 12

            _bottomPanelLeftPadding: _root._bottomPanelLeftPadding
            _bottomPanelMargin: _root._bottomPanelMargin
            _bottomPanelRadious: _root._bottomPanelRadious
        }
    }
}

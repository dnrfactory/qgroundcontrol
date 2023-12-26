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

Rectangle {
    id:                     root

    property real _bottomPanelLeftPadding: 16
    property real _bottomPanelMargin: 20
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    
    color:                  qgcPal.window
    opacity:                0.8

    Row {
        anchors.fill:       parent
        spacing:            _bottomPanelLeftPadding
        anchors.margins:    _bottomPanelMargin

        QGCLabel {
            id : modeLabel
            text: "운항모드"
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize:     ScreenTools.mediumFontPointSize
        }

        Rectangle {
            id : buttonWarp
            width : parent.width - modeLabel.width - _bottomPanelMargin
            height: parent.height
            anchors.leftMargin: _bottomPanelMargin
            color: "transparent"

            Row {
                anchors.fill:       parent
                spacing: _bottomPanelLeftPadding

                ButtonGroup {
                    id : modeButtonGroup
                }

                QGCButton {
                    id:                 manualButton
                    width :             (buttonWarp.width - _bottomPanelLeftPadding * 2)/3
                    height :            buttonWarp.height
                    backRadius :        height

                    text:               "Manual"
                    pointSize :         ScreenTools.mediumFontPointSize

                    ButtonGroup.group:  modeButtonGroup
                    enabled :           _activeVehicle

                    onClicked: {
                        _activeVehicle.flightMode = manualButton.text
                    }
                }

                QGCButton {
                    id:                 autoButton
                    width :             (buttonWarp.width - _bottomPanelLeftPadding * 2)/3
                    height :            buttonWarp.height
                    backRadius :        height

                    text:               "Auto"
                    pointSize :         ScreenTools.mediumFontPointSize

                    ButtonGroup.group:  modeButtonGroup
                    enabled :           _activeVehicle

                    onClicked: {
                        _activeVehicle.flightMode = autoButton.text
                    }
                }

                QGCButton {
                    id:                 loiterButton
                    width :             (buttonWarp.width - _bottomPanelLeftPadding * 2)/3
                    height :            buttonWarp.height
                    backRadius :        height

                    text:               "Loiter"
                    pointSize :         ScreenTools.mediumFontPointSize

                    ButtonGroup.group:  modeButtonGroup
                    enabled :           _activeVehicle

                    onClicked: {
                        _activeVehicle.flightMode = loiterButton.text
                    }
                }
            }
        }
    }
}
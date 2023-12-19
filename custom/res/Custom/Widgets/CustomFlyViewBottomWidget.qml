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
    id: _root
    
    readonly property real  _bottomPanelWidth:          ScreenTools.defaultFontPixelWidth * 35                  // Width        : 280
    readonly property real  _bottomPanelHeight:         ScreenTools.defaultFontPixelWidth * 30                  // Height       : 240

    readonly property real  _bottomPanelButtonWidth:    _bottomPanelWidth - (_bottomPanelMargin * 2)            // Width        : 248
    readonly property real  _bottomPanelButtonHeight:   (_bottomPanelHeight - (_bottomPanelTopPadding * 5))/4   // Height       : 35

    readonly property real  _bottomPanelMargin:         ScreenTools.defaultFontPixelWidth * 2                  // Margin       : 16

    readonly property real  _bottomPanelLeftPadding:    ScreenTools.defaultFontPixelWidth * 2                 // LeftPadding  : 16
    readonly property real  _bottomPanelTopPadding:     ScreenTools.defaultFontPixelWidth * 2.5                 // TopPadding   : 20

    readonly property real  _bottomPanelRadious:        ScreenTools.defaultFontPixelWidth * 1.25

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property string _sailMode:              _activeVehicle ? _activeVehicle.flightMode : ""
    property bool   _communicationLost:     _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _statusTextColor:       "white"
    property real   _statusTextFontSize:    ScreenTools.mediumFontPointSize

    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + "black" + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

    function checkMode(){
        switch(_sailMode){
        case "Manual":
            manualButton.checked = true
            break;
        case "Auto":
            autoButton.checked = true;
            break;
        case "Loiter":
            loiterButton.checked = true;
            break;
        default:
            manualButton.checked = false;
            autoButton.checked = false;
            loiterButton.checked = false;

            break;
        }
    }

    on_SailModeChanged: {
        checkMode();
    }    

    Item {
        id:                     bottomPanel
        width:                  parent.width
        height:                 _bottomPanelHeight + _bottomPanelMargin * 2
        anchors.bottom:         parent.bottom
        DeadMouseArea {
            anchors.fill:       parent
        }
    }

    Row {
        anchors.centerIn:       bottomPanel
        spacing:               _bottomPanelLeftPadding

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

        Rectangle {
            id:                     customServoOutPutPanel
            height:                 _bottomPanelHeight

            width:                  _bottomPanelWidth
            color:                  "transparent"

            visible: QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable

            Rectangle{
                anchors.fill:       parent
                color:              qgcPal.window
                opacity:            0.8
                radius:             _bottomPanelRadious
            }

            Connections {
                target: QGroundControl.multiVehicleManager

                onParameterReadyVehicleAvailableChanged: {
//                    console.log("Connections // onParameterReadyVehicleAvailableChanged")
                    if (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable) {
                        panelLoader.setSource("qrc:/qml/QGroundControl/Controls/ServoOutPutDialog.qml")
                    }else{
                        panelLoader.setSource("")
                    }
                }
            }

            Loader {
                id:             panelLoader
                anchors.fill:   parent
                anchors.margins: _bottomPanelMargin

                function setSource(source) {
                    panelLoader.source = source
                }
            }

        }
    }    
}

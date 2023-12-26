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

    Rectangle {
        anchors.fill: bottomPanel
        color: "green"
        opacity: 0.5
        radius: _bottomPanelRadious
    }

    QGCTabBar {
        id: layerTabBar
        anchors.left: bottomPanel.left
        anchors.bottom: bottomPanel.top
        width: 0.2 * parent.width
        Component.onCompleted: currentIndex = 0
        QGCTabButton {
            text:       qsTr("Plan control")
        }
        QGCTabButton {
            text:       qsTr("Plan status")
        }
        QGCTabButton {
            text:       qsTr("Plan history")
        }
    }

    StackLayout {
        anchors.fill: bottomPanel
        currentIndex: layerTabBar.currentIndex
        CustomFlyViewPlanControlWidget {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "red"
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "blue"
        }
    }    
}

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

CustomPanel {
    id: _root

    width: parent.width
    height: 240//ScreenTools.defaultFontPixelWidth * 40

    readonly property real  _bottomPanelWidth:          210//ScreenTools.defaultFontPixelWidth * 35

    readonly property real  _bottomPanelButtonWidth:    _bottomPanelWidth
    readonly property real  _bottomPanelButtonHeight:   (height - (_bottomPanelTopPadding * 5))/4

    readonly property real  _bottomPanelLeftPadding:    12//ScreenTools.defaultFontPixelWidth * 2
    readonly property real  _bottomPanelTopPadding:     15//ScreenTools.defaultFontPixelWidth * 2.5


    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost:     _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _statusTextColor:       "white"
    property real   _statusTextFontSize:    ScreenTools.mediumFontPointSize

    property var mapControl
    property bool isMultiVehicleMode

    signal videoPlayButtonClicked(string mediaSource);

    Component.onCompleted: {
        historyWidget.videoPlayButtonClicked.connect(_root.videoPlayButtonClicked)

        console.log('!!!!!! defaultFontPixelWidth %1'.arg(ScreenTools.defaultFontPixelWidth))
    }

    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + "black" + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

    DeadMouseArea {
        anchors.fill: parent
    }

    TabBar {
        id: layerTabBar
        anchors.left: _root.left
        anchors.bottom: _root.top
        width: 0.2 * parent.width
        Component.onCompleted: {
            currentIndex = 0
            updateCurrentIndex()
        }

        background: Rectangle {
            color: "transparent"
        }

        CustomTabButton { text: qsTr("Flight Control") }
        CustomTabButton { text: qsTr("Flight Status") }
        CustomTabButton { text: qsTr("Flight History") }

        onCurrentIndexChanged: updateCurrentIndex()

        function updateCurrentIndex() {
            for (var i = 0; i < count; ++i) {
                if (i === currentIndex) {
                    layerTabBar.itemAt(i).height = 40;
                } else {
                    layerTabBar.itemAt(i).height = 30;
                }
            }
        }
    }

    StackLayout {
        anchors.fill: _root
        currentIndex: layerTabBar.currentIndex
        CustomFlyViewFlightControlWidget {
            Layout.fillWidth: true
            Layout.fillHeight: true
            mapControl: _root.mapControl
            isMultiVehicleMode: _root.isMultiVehicleMode
        }
        CustomFlyViewFlightStatusWidget {
            Layout.fillWidth: true
            Layout.fillHeight: true

            mapControl: _root.mapControl
        }
        CustomFlyViewFlightHistoryWidget {
            id: historyWidget
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}

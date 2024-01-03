/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11
import QtQuick.Dialogs  1.3

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0
import Custom.Widgets                       1.0

Rectangle {
    id:     _root
    color:  qgcPal.toolbarBackground

    property int currentToolbar: flyViewToolbar

    readonly property int flyViewToolbar:   0
    readonly property int planViewToolbar:  1
    readonly property int simpleToolbar:    2

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple

    //    toolbarHeight: defaultFontPixelHeight * 3 * 1.5                                                                       // mainToolBarRowLayoutTopMargin    : 81
    readonly property int _mainToolBarRowLayoutHeight:       ScreenTools.toolbarHeight - _mainToolBarRowLayoutTopMargin * 2 // mainToolBarRowLayoutHeight       : 73
    readonly property int _mainToolBarRowLayoutLeftMargin:   ScreenTools.defaultFontPixelWidth * 2.5                        // mainToolBarRowLayoutLeftMargin   : 20
    readonly property int _mainToolBarRowLayoutTopMargin:    ScreenTools.defaultFontPixelWidth/2                            // mainToolBarRowLayoutMargin       :  4
    readonly property int _mainToolBarRowLayoutSpacing:      ScreenTools.defaultFontPixelWidth * 5                          // mainToolBarRowLayoutSpacing      : 40

    // rebootVehicle count
    property int rebootCount: 0

    function dropMessageIndicatorTool() {
        if (currentToolbar === flyViewToolbar) {
            indicatorLoader.item.dropMessageIndicatorTool();
        }
    }

    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.left:           parent.left
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.leftMargin:     _mainToolBarRowLayoutLeftMargin
        anchors.topMargin:      _mainToolBarRowLayoutTopMargin
        anchors.bottomMargin:   _mainToolBarRowLayoutTopMargin

        spacing:                _mainToolBarRowLayoutSpacing

        ButtonGroup{
            id :toolbarButtonGroup
        }

        CustomToolBarButton {
            id:                     sailviewButton
            Layout.preferredHeight: parent.height
            Layout.preferredWidth:  parent.height

            text:                   "Sail"
            icon.source:            "/res/custom/img/TitleBarFlight"
            logo:                   true
            checked:                true
            ButtonGroup.group:      toolbarButtonGroup
            onClicked:              mainWindow.showFlyView()
        }

        CustomToolBarButton {
            id:                     planviewButton
            Layout.preferredHeight: parent.height
            Layout.preferredWidth:  parent.height
            text:                   "Plan"
            icon.source:            "/res/custom/img/TitleBarMissionPlan"
            logo:                   true
            ButtonGroup.group:      toolbarButtonGroup
            onClicked:              mainWindow.showPlanView()
        }

        CustomToolBarButton {
            id:                     settingButton
            Layout.preferredHeight: parent.height
            Layout.preferredWidth:  parent.height
            text:                   "Setting"
            icon.source:            "/res/custom/img/TitleBarVehicleSetting"
            logo:                   true

            onPressed: checked = true
            onReleased: checked = false
            onHoveredChanged: checked = false

            onClicked: mainWindow.showToolSelectDialog()
        }

        CustomToolBarButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            _activeVehicle && _communicationLost && currentToolbar === flyViewToolbar
        }
    }

    //-------------------------------------------------------------------------
    //-- Branding Logo
    Image {
        height:                 parent.height
        anchors{
            right:              parent.right
            top:                parent.top
            bottom:             parent.bottom
            topMargin:          _mainToolBarRowLayoutTopMargin
            bottomMargin:       _mainToolBarRowLayoutTopMargin
            rightMargin:        _mainToolBarRowLayoutLeftMargin
        }
        source:                 "/res/custom/img/DnrLogo"
        sourceSize.height:      parent.height
        fillMode:               Image.PreserveAspectFit

        MouseArea{
            anchors.fill: parent
            onClicked: {

                if(!rebootCountTimer.running){
                    rebootCountTimer.start()
                    rebootCount = 1
                }else{
                    rebootCount = rebootCount + 1
                    if(rebootCount == 5){
                        rebootCountTimer.stop()
                        _activeVehicle.rebootVehicle()
                    }
                }
                console.log(("rebootCount : %1").arg(rebootCount))
            }
        }

        Timer {
            id:             rebootCountTimer
            interval:       2000
            repeat:         false
            onTriggered:    {
                rebootCount = 0
                console.log("rebootCountTimer timeOut")
            }
        }
    }

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
}

/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 2.4

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

// Important Note: Toolbar buttons must manage their checked state manually in order to support
// view switch prevention. This means they can't be checkable or autoExclusive.

Button {
    id:                 button
    height:             parent.height
    width:              height
    checkable:          true

    readonly property real _mainToolBarButtonIconHeight: ScreenTools.toolbarHeight - ScreenTools.defaultFontPixelWidth * 3.5 - _mainToolBarButtonSpacing // mainToolBarButtonIconHeight :    52
    readonly property real _mainToolBarButtonSpacing: 5                                                                                                 // _mainToolBarButtonSpacing :       5
    readonly property real _mainToolBarButtonFontSize: ScreenTools.defaultFontPixelWidth * 1.5                                                          // _mainToolBarButtonFontSize :     12
    readonly property color pressedColor: Qt.darker(qgcPal.button, 1.5)

    background: Rectangle {
        anchors.fill:   parent
        color: button.pressed ? pressedColor : (button.checked ? qgcPal.button : Qt.rgba(0,0,0,0))
        radius: ScreenTools.defaultFontPixelWidth

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    contentItem: Column {
        spacing:                _mainToolBarButtonSpacing
        anchors.centerIn:       parent
        QGCColoredImage {
            id:                     _icon
            height:                 _mainToolBarButtonIconHeight
            width:                  _mainToolBarButtonIconHeight
            fillMode:               Image.PreserveAspectFit
            color:                  "transparent"
            source:                 button.icon.source
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id:                     _label
            visible:                text !== ""
            text:                   button.text
            font.pixelSize:         _mainToolBarButtonFontSize
            color:                  qgcPal.buttonText
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}

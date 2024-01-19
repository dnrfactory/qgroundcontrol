import QtQuick                  2.3
import QtQuick.Controls         2.12
import QtQuick.Controls.Styles  1.4

import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Button {
    id:             control
    hoverEnabled:   true
    topPadding:     _verticalPadding
    bottomPadding:  _verticalPadding
    leftPadding:    _horizontalPadding
    rightPadding:   _horizontalPadding
    focusPolicy:    Qt.ClickFocus

    property real   pointSize:      ScreenTools.defaultFontPointSize    ///< Point size for button text
    property bool   boldFont:       false
    property bool   iconLeft:       false
    property real   backRadius:     0
    property real   heightFactor:   0.5

    property alias wrapMode:            text.wrapMode
    property alias horizontalAlignment: text.horizontalAlignment

    property bool   isSelected: false
    property bool   _showHighlight:     hovered | checked | isSelected

    property int _horizontalPadding:    ScreenTools.defaultFontPixelWidth
    property int _verticalPadding:      Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)

    property color hightlightColor: qgcPal.buttonHighlight
    property color normalColor: qgcPal.button
    property color pressedColor: "cadetblue"

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    background: Rectangle {
        id:             backRect
        implicitWidth:  ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        radius:         backRadius
        color:          pressed ? pressedColor : (_showHighlight ? hightlightColor : normalColor)
        opacity: 0.8

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    contentItem: Item {
        implicitWidth:  text.implicitWidth
        implicitHeight: text.implicitHeight
        baselineOffset: text.y + text.baselineOffset

        Text {
            id:                     text
            anchors.centerIn:       parent
            antialiasing:           true
            text:                   control.text
            font.pointSize:         control.pointSize
            font.family:            ScreenTools.normalFontFamily
            font.bold:              control.boldFont
            color:                  _showHighlight ?
                                        qgcPal.buttonHighlightText : qgcPal.buttonText
        }
    }
}

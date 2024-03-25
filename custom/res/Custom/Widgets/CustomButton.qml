import QtQuick                  2.3
import QtQuick.Controls         2.12
import QtQuick.Controls.Styles  1.4

import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Controls 1.0


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
    property string iconSource
    property real iconSourceScale: 1

    property alias wrapMode:            text.wrapMode
    property alias horizontalAlignment: text.horizontalAlignment

    property bool isSelected: false
    property bool _showHighlight:     hovered | checked | isSelected
    property bool blinking: false

    property int _horizontalPadding:    ScreenTools.defaultFontPixelWidth
    property int _verticalPadding:      Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)

    property color hightlightColor: qgcPal.buttonHighlight
    property color normalColor: qgcPal.button
    property color pressedColor: Qt.darker(hightlightColor, 1.5)
    property color disabledColor: qgcPal.button

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    background: Rectangle {
        id: backRect
        implicitWidth: ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        radius: backRadius
        color: !enabled ? disabledColor : (pressed ? pressedColor : (_showHighlight ? hightlightColor : normalColor))

        property var btnColor: pressed ? pressedColor : (_showHighlight ? hightlightColor : normalColor)

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        ColorAnimation on color {
            easing.type: Easing.OutQuart
            from: control.normalColor
            to: control.hightlightColor
            loops: Animation.Infinite
            running: blinking && !control.hovered
            alwaysRunToEnd: false
            duration: 2000
        }
    }

    contentItem: Item {
        implicitWidth:  text.implicitWidth + icon.width
        implicitHeight: text.implicitHeight
        baselineOffset: text.y + text.baselineOffset

        QGCColoredImage {
            id:                     icon
            source:                 control.iconSource
            height:                 source === "" ? 0 : text.height * iconSourceScale
            width:                  height
            color:                  text.color
            fillMode:               Image.PreserveAspectFit
            sourceSize.height:      height
            anchors.left:           control.iconLeft ? parent.left : undefined
            anchors.leftMargin:     control.iconLeft ? ScreenTools.defaultFontPixelWidth : undefined
            anchors.right:          !control.iconLeft ? parent.right : undefined
            anchors.rightMargin:    !control.iconLeft ? ScreenTools.defaultFontPixelWidth : undefined
            anchors.verticalCenter: parent.verticalCenter
        }

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

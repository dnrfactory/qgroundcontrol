/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Controls         2.12
import QtQuick.Controls.impl    2.12
import QtQuick.Templates        2.12 as T
import QtGraphicalEffects 1.15


import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

T.TabButton {
    id: root

    anchors.bottom: parent.bottom

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    font.pointSize: ScreenTools.defaultFontPointSize
    font.family:    ScreenTools.normalFontFamily

    padding: 6
    spacing: 6

    contentItem: Text {
        text: root.text
        font: root.font
        color: checked ? qgcPal.buttonHighlightText : qgcPal.buttonText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        id: bgRect
        implicitHeight: 40
        color: "#E6161C41"
        layer.enabled: true
        layer.effect: OpacityMask{
            maskSource: Item {
                width: bgRect.width
                height: bgRect.height
                Rectangle {
                    anchors.fill: parent
                    radius: 10
                }
                Rectangle {
                    width: parent.width
                    height: parent.height * 0.5
                    anchors.bottom: parent.bottom
                }
            }
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 100
        }
    }
}

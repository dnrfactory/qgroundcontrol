/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.Controllers       1.0
import QGroundControl.ShapeFileHelper   1.0
import QGroundControl.Vehicle           1.0

Rectangle {
    id: root
    height: parent.height
	color: qgcPal.window
	opacity: 0.8

    readonly property real verticalMargin: 40 + 4 * 3
    readonly property real horizontalMargin: 40 + 4 * 3

    property var colorList: QGroundControl.multiVehicleManager.vehicleColorList

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: 4
            Rectangle {
                width: root.width - horizontalMargin
                height: (root.height - verticalMargin - column.spacing * 3) / 4
                color: colorList[index]
                radius: 4
                Text {
                    anchors.fill: parent
                    font.pointSize: ScreenTools.mediumFontPointSize
                    color: qgcPal.text
                    text: index
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

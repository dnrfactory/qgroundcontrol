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
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Layouts  1.2
import QtQuick.Window   2.2

import QGroundControl                   1.0
import QGroundControl.FlightMap         1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactSystem        1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0
import QGroundControl.Controllers       1.0
import QGroundControl.ShapeFileHelper   1.0

Rectangle {
    id: root
    height: parent.height
	color: qgcPal.window
	opacity: 0.8

    readonly property real verticalMargin: 40
    readonly property real horizontalMargin: 40
    readonly property real itemSpacing: 4

    ListModel {
        id: missionFileModel

        Component.onCompleted: {
        for (var i = 0; i < 10; ++i) {
                for (var j = 0; j < 4; ++j) {
                    missionFileModel.append({row: i, col: j, value: "+"});
                }
            }
        }
    }

    GridView {
        id: gridView

        anchors.fill: parent
        anchors.leftMargin: horizontalMargin / 2
        anchors.rightMargin: horizontalMargin / 2
        anchors.topMargin: verticalMargin / 2
        anchors.bottomMargin: verticalMargin / 2
        clip: true

        cellWidth: width / 4
        cellHeight: height / 4

        model: missionFileModel

        delegate: Item {
            width: gridView.cellWidth
            height: gridView.cellHeight
            QGCButton {
                anchors.fill: parent
                anchors.margins: itemSpacing
                text: model.value
                _showHighlight: pressed
                pointSize: ScreenTools.mediumFontPointSize
                backRadius: 4
            }
        }
    }
}

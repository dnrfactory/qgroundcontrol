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

Item {
    id: root
    height: parent.height

    property var planMasterController

    readonly property real verticalMargin: 40
    readonly property real horizontalMargin: 40
    readonly property real itemSpacing: 4

    signal missionItemClicked(string fileName)
    signal shortcutAddItemClicked()
    signal shortcutRemoveItemClicked(string fileName)

    function updateShortcutList() {
        var shortcutList = planMasterController.shortcutList
        var fileIndex = 0

        missionFileModel.clear()

        for (var i = 0; i < 10; ++i) {
            for (var j = 0; j < 4; ++j) {
                if (fileIndex < shortcutList.length) {
                    missionFileModel.append({row: i, col: j, value: shortcutList[fileIndex]});
                }
                else {
                    missionFileModel.append({row: i, col: j, value: "+"});
                }
                fileIndex++
            }
        }
    }

    Connections {
        target: planMasterController
        onCurrentPlanFileChanged: {
            console.log("CustomMissionShortcutWidget onCurrentPlanFileChanged")
        }
        onShortcutListChanged: {
            console.log("CustomMissionShortcutWidget onShortcutListChanged")
            updateShortcutList()
        }
    }

    ListModel {
        id: missionFileModel

        Component.onCompleted: {
            updateShortcutList()
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
            CustomButton {
                anchors.fill: parent
                anchors.margins: itemSpacing
                text: model.value
                pointSize: ScreenTools.mediumFontPointSize
                backRadius: 4
                elide: Text.ElideRight

                onClicked: {
                    console.log("missionFile Button Clicked. file name: %1".arg(model.value))
                    if (model.value === "+") {
                        shortcutAddItemClicked()
                    } else {
                        missionItemClicked(model.value)
                    }
                }

                CustomButton {
                    height: parent.height / 2
                    width: height
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: -6
                    anchors.rightMargin: -6
                    backRadius: 6
                    text: "x"
                    pointSize: ScreenTools.mediumFontPointSize
                    _showHighlight: false
                    opacity: 0
                    visible: model.value !== "+"

                    onClicked: {
                        console.log("deleteButton clicked")
                        shortcutRemoveItemClicked(model.value)
                    }

                    onHoveredChanged: {
                        if (hovered) {
                            opacityAnimator.running = true
                        }
                        else {
                            opacityAnimator.running = false
                            opacity = 0
                        }
                    }

                    OpacityAnimator on opacity{
                        id: opacityAnimator
                        from: 0
                        to: 1
                        duration: 100
                        running: false
                    }
                }
            }
        }
    }
}

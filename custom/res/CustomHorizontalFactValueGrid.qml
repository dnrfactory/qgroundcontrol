/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Layouts  1.2
import QtQuick.Controls 2.5
import QtQml            2.12

import QGroundControl.Templates     1.0 as T
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Palette       1.0
import QGroundControl.FlightMap     1.0
import QGroundControl               1.0

T.HorizontalFactValueGrid {
    id: root

    property bool settingsUnlocked: false
    property real itemVerticalSpacing

    RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth * 1.25

        Repeater {
            id : parnetsrepeater
            model: root.columns

            GridLayout {
                rows: object.count
                columns: 2
                rowSpacing: itemVerticalSpacing
                columnSpacing: ScreenTools.defaultFontPixelWidth * 2
                flow: GridLayout.TopToBottom

                Repeater {
                    id: labelRepeater
                    model: object

                    InstrumentValueLabel {
                        id: valLabel
                        Layout.fillHeight:      true
                        Layout.alignment:       Qt.AlignRight
                        instrumentValueData:    object
                    }
                }

                Repeater {
                    id: valueRepeater
                    model: object

                    property real _index: index
                    property real maxWidth: 0
                    property var lastCheck: new Date().getTime()

                    function recalcWidth() {
                        var newMaxWidth = 0
                        for (var i = 0; i < valueRepeater.count; i++) {
                            newMaxWidth = Math.max(newMaxWidth, valueRepeater.itemAt(0).contentWidth)
                        }
                        maxWidth = Math.min(maxWidth, newMaxWidth)
                    }

                    InstrumentValueValue {
                        Layout.fillHeight:      true
                        Layout.alignment:       Qt.AlignLeft
                        Layout.preferredWidth:  valueRepeater.maxWidth
                        instrumentValueData:    object
                        property real lastContentWidth

                        Layout.rightMargin: valueRepeater._index === 0 ? ScreenTools.defaultFontPixelWidth * 6 : 0

                        Component.onCompleted:  {
                            valueRepeater.maxWidth = Math.max(valueRepeater.maxWidth, contentWidth)
                            lastContentWidth = contentWidth
                        }
                    }
                }
            }
        }
    }
}

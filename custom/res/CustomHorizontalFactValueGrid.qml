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
import QGroundControl.Palette       1.0
import QGroundControl               1.0

T.HorizontalFactValueGrid {
    id: root

    property bool settingsUnlocked: false
    property real gridItemHeight

    RowLayout {
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        spacing: 20

        Repeater {
            model: root.columns

            GridLayout {
                rows: object.count
                columns: 2
                rowSpacing: 0
                columnSpacing: ScreenTools.defaultFontPixelWidth * 2
                flow: GridLayout.TopToBottom

                Repeater {
                    model: object

                    InstrumentValueLabel {
                        Layout.preferredHeight: gridItemHeight
                        Layout.fillHeight:      true
                        Layout.alignment:       Qt.AlignRight
                        instrumentValueData:    object
                    }
                }
                Repeater {
                    model: object
                    InstrumentValueValue {
                        Layout.preferredHeight: gridItemHeight
                        Layout.fillHeight:      true
                        Layout.alignment:       Qt.AlignLeft
                        instrumentValueData:    object
                    }
                }
            }
        }
    }
}

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

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0

Item {
    id: root
    height: parent.height

    readonly property real verticalMargin: 40
    readonly property real itemSpacing: 20
    readonly property real itemHeight: (height - verticalMargin) / 5
    readonly property real itemWidth: (width - itemSpacing) / 2

    property var planMasterController

    property bool _controllerValid: planMasterController !== undefined && planMasterController !== null
    property var missionItems: _controllerValid ? planMasterController.missionController.visualItems : undefined
    property bool _missionValid: missionItems !== undefined

    property real missionTime: _controllerValid ? planMasterController.missionController.missionTime : 0
    property real _missionTime: _missionValid ? missionTime : 0

    property real missionDistance: _controllerValid ? planMasterController.missionController.missionDistance : NaN
    property real _missionDistance: _missionValid ? missionDistance : NaN
    property string _missionDistanceText: isNaN(_missionDistance) ?
                                            "-.-" : QGroundControl
                                                    .unitsConversion
                                                    .metersToAppSettingsHorizontalDistanceUnits(_missionDistance)
                                                    .toFixed(0)
                                                    + " " + QGroundControl
                                                            .unitsConversion
                                                            .appSettingsHorizontalDistanceUnitsString

    property real missionMaxTelemetry: _controllerValid ? _planMasterController.missionController.missionMaxTelemetry : NaN
    property real _missionMaxTelemetry: _missionValid ? missionMaxTelemetry : NaN
    property string _missionMaxTelemetryText: isNaN(_missionMaxTelemetry) ?
                                                "-.-" : QGroundControl
                                                        .unitsConversion
                                                        .metersToAppSettingsHorizontalDistanceUnits(_missionMaxTelemetry)
                                                        .toFixed(0)
                                                        + " " + QGroundControl
                                                                .unitsConversion
                                                                .appSettingsHorizontalDistanceUnitsString

    property real missionVehicleSpeed: _controllerValid ? _planMasterController.missionController.missionVehicleSpeed : NaN
    property real _missionVehicleSpeed: _missionValid ? missionVehicleSpeed : NaN
    property string _missionVehicleSpeedText: isNaN(_missionVehicleSpeed) ?
                                                "-.-" : QGroundControl
                                                        .unitsConversion
                                                        .metersSecondToAppSettingsSpeedUnits(_missionVehicleSpeed)
                                                        .toFixed(0)
                                                        + " " + QGroundControl
                                                                .unitsConversion
                                                                .appSettingsSpeedUnitsString

    property real missionHoverDistance: _controllerValid ? planMasterController.missionController.missionHoverDistance : 0
    property real missionCruiseDistance: _controllerValid ? planMasterController.missionController.missionCruiseDistance : 0

    onMissionHoverDistanceChanged: {
        console.log("onMissionHoverDistanceChanged %1".arg(missionHoverDistance))
    }
    onMissionCruiseDistanceChanged: {
        console.log("onMissionCruiseDistanceChanged %1".arg(missionCruiseDistance))
    }

    function getPlanFileName() {
        if (!_controllerValid) {
            return qsTr("untitled")
        }

        var filePath = planMasterController.currentPlanFile

        if (filePath.length === 0) {
            return qsTr("untitled")
        }
        return planMasterController.currentPlanFileBaseName
    }

    function local8bitToUtf8(local8bitString) {
        var textEncoder = new TextEncoder("utf-8");
        var uint8Array = textEncoder.encode(local8bitString);
        return String.fromCharCode.apply(null, uint8Array);
    }

    function getMissionTime() {
        if (!_missionTime) {
            return "00:00:00"
        }
        var t = new Date(2021, 0, 0, 0, 0, Number(_missionTime))
        var days = Qt.formatDateTime(t, 'dd')
        var complete

        if (days == 31) {
            days = '0'
            complete = Qt.formatTime(t, 'hh:mm:ss')
        } else {
            complete = days + " days " + Qt.formatTime(t, 'hh:mm:ss')
        }
        return complete
    }

    Column {
        anchors.centerIn: parent
        Component {
            id: rowComponent
            Row {
                spacing: root.itemSpacing

                property string titleText
                property string valueText
                Item {
                    height: itemHeight
                    width: itemWidth
                    Text {
                        anchors.fill: parent
                        font.pointSize: ScreenTools.mediumFontPointSize
                        color: qgcPal.text
                        text: titleText
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Item {
                    height: itemHeight
                    width: itemWidth
                    Text {
                        anchors.fill: parent
                        font.pointSize: ScreenTools.mediumFontPointSize
                        color: qgcPal.text
                        text: valueText
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Plan name")
                item.valueText = Qt.binding(function() { return getPlanFileName() })
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Flight distance")
                item.valueText = Qt.binding(function() { return _missionDistanceText })
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Flight speed")
                item.valueText = Qt.binding(function() { return _missionVehicleSpeedText })
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Max distance")
                item.valueText = Qt.binding(function() { return _missionMaxTelemetryText })
            }
        }
        Loader {
            sourceComponent: rowComponent
            onLoaded: {
                item.titleText = qsTr("Estimated time")
                item.valueText = Qt.binding(function() { return getMissionTime() })
            }
        }
    }
}

import QtQuick                      2.3
import QtQuick.Controls             1.2
import QtQuick.Dialogs              1.2
import QtQuick.Layouts              1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Vehicle       1.0


Item {
    id:         _root

    anchors.fill:   parent
    FactPanelController { id: factPanelController; }

    MAVLinkInspectorController {id: mavlinkInspectorController}

    //    readonly property int   _rcFunctionRCIN5:56
    //    readonly property int   _rcFunctionRCIN6:57
    //    readonly property int   _rcFunctionRCIN7:58
    //    readonly property int   _rcFunctionRCIN8:59
    //    readonly property int   _rcFunctionRCIN9:60

    readonly property int   servoMessageId:     36

    readonly property int   servoDialog:         0
    readonly property int   setTimer:            1
    property int            currentTool:        servoDialog

    property int            totalCheckCnt:      0
    property int            selChildren:        0


    property var            _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var            curSystem:          mavlinkInspectorController ? mavlinkInspectorController.activeSystem : null
    property var            curMessageCount:    curSystem ? curSystem.messages.count : null
    property var            curSystemSelected:  curSystem ? curSystem.selected : null
    property var            curMessage:         curSystem && curMessageCount ? curSystem.messages.get(curSystemSelected) : null
    property var            time_usec:           curMessage ? curMessage.fields.get(0).value : 0

    property bool           loadServoMessagesIndexCompleted : false

    function getServoMessagesIndex(){
        loadServoMessagesIndexCompleted = false
        for(var i =0;i<curSystem.messages.count;i++){
            if(curSystem.messages.get(i).id === servoMessageId){
                loadServoMessagesIndexCompleted = true
                return i
            }
        }
        return -1
    }

    onCurMessageCountChanged: {
//        console.log("onCurMessageCountChanged")
        countTimer.running ? countTimer.restart() : countTimer.start()
    }

    Timer {
        id:             countTimer
        interval:       1000
        repeat:         false
        onTriggered:    curSystem.selected = getServoMessagesIndex()
    }

    RowLayout {
        id:header
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 5

        QGCLabel{text: qsTr("전체 ")
            font.pointSize: ScreenTools.mediumFontPointSize
            font.bold: true
        }

        QGCButton{ text: qsTr("정지")
            width: ScreenTools.defaultFontPixelWidth * 5
            height:ScreenTools.defaultFontPixelHeight * 1.5
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

            onClicked: {
//                console.log("Off")
                allTimer.stop()

                totalCheckCnt = 0
                selChildren = 6
                allTimer.start()

            }
        }

        QGCButton{ text: qsTr("최소")
            width: ScreenTools.defaultFontPixelWidth * 5
            height:ScreenTools.defaultFontPixelHeight * 1.5
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

            onClicked: {
//                console.log("Min")
                allTimer.stop()

                totalCheckCnt = 0
                selChildren = 7
                allTimer.start()

            }
        }

        Timer{
            id:allTimer
            interval: 500
            repeat: true
            onTriggered: {
//                    console.log("allMinTimer")

                servoButtonList.itemAt(totalCheckCnt).children[selChildren].clicked()
                totalCheckCnt = totalCheckCnt + 1
                servoButtonList.count <= totalCheckCnt ? allTimer.stop() : ""
            }
        }


        Item {
            Layout.fillWidth:true
        }

        QGCButton{
            text: currentTool == setTimer ? qsTr("Buttons") : qsTr("Setting")
            height:ScreenTools.defaultFontPixelHeight * 1.5
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
            Layout.alignment: Qt.AlignRight
            onClicked: {
                currentTool == servoDialog ? currentTool = setTimer : currentTool = servoDialog
            }
        }
    }

    ColumnLayout{
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        anchors.topMargin: 10
        spacing: 5

        RowLayout{
            QGCLabel{
                text: qsTr("펌프")
                font.pointSize: ScreenTools.mediumFontPointSize * 0.9
            }
            Item {
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth* 0.2
            }
            QGCLabel{
                text:qsTr("pwm")
                font.pointSize: ScreenTools.mediumFontPointSize * 0.9
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 4
            }
//            Item {
//                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth* 0.3
//            }
            QGCLabel{
                text: qsTr("%")
                font.pointSize: ScreenTools.mediumFontPointSize * 0.9
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
            }

            Item {
                Layout.fillWidth:true
            }
        }

        ListModel {
            id: servoList
            ListElement {
                name:"P1";fieldIndex: 6;servoIndex: 5;
                servoTrim: "SERVO5_TRIM";servoMin: "SERVO5_MIN";servoMax: "SERVO5_MAX";
                startTime:0;setTime:0;percent:0;checkCnt:0}
            ListElement {
                name:"P2";fieldIndex: 7;servoIndex: 6;
                servoTrim: "SERVO6_TRIM";servoMin: "SERVO6_MIN";servoMax: "SERVO6_MAX";
                startTime:0;setTime:0;percent:0;checkCnt:0}
            ListElement {
                name:"P3";fieldIndex: 8;servoIndex: 7;
                servoTrim: "SERVO7_TRIM";servoMin: "SERVO7_MIN";servoMax: "SERVO7_MAX";
                startTime:0;setTime:0;percent:0;checkCnt:0}
            ListElement {
                name:"P4";fieldIndex: 9;servoIndex: 8;
                servoTrim: "SERVO8_TRIM";servoMin: "SERVO8_MIN";servoMax: "SERVO8_MAX";
                startTime:0;setTime:0;percent:0;checkCnt:0}
            ListElement {
                name:"P5";fieldIndex:10;servoIndex: 9;
                servoTrim: "SERVO9_TRIM";servoMin: "SERVO9_MIN";servoMax: "SERVO9_MAX";
                startTime:0;setTime:0;percent:0;checkCnt:0}
        } // ServoListModel

        Repeater{
            id : servoButtonList
            model: servoList

            RowLayout{
                Layout.fillWidth: true

                QGCLabel{
                    text: qsTr(name)
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold: true
                }

                Item {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth
                }

                QGCLabel{
                    text: loadServoMessagesIndexCompleted ? curMessage.fields.get(fieldIndex).value : '0'
                    font.pointSize: ScreenTools.mediumFontPointSize * 0.9
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                }

                Item {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth
                }

                QGCLabel{
                    id:servoPercentLabel
                    text: qsTr(percent.toString())
                    font.pointSize: ScreenTools.mediumFontPointSize * 0.9
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    Layout.alignment: Qt.AlignRight
                }

                Item {
                    Layout.fillWidth:true
                }

                QGCButton{
                    id:buttonOff
                    text: qsTr("정지")
                    width: ScreenTools.defaultFontPixelWidth * 5
                    height:ScreenTools.defaultFontPixelHeight * 1.5
                    visible: currentTool == servoDialog

                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                    Layout.alignment: Qt.AlignRight
                    onClicked:  {
//                        console.log("Min // clicked")

                        checkTimer.stop()
                        timer.stop()

                        var pwmMin = factPanelController.getParameterFact(-1,servoMin).value

                        _activeVehicle.setServo(servoIndex,pwmMin,false)

                        checkTimer.start()

                        percent = 0
                    }
                }

                QGCButton{
                    id:buttonMin
                    text: qsTr("최소")
                    width: ScreenTools.defaultFontPixelWidth * 5
                    height:ScreenTools.defaultFontPixelHeight * 1.5
                    visible: currentTool == servoDialog
                    enabled : !timer.running

                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
//                        console.log("Min // clicked")
                        checkTimer.stop()

//                        var curPwm = parseInt(curMessage.fields.get(fieldIndex).value)
                        var pwmTrim = factPanelController.getParameterFact(-1,servoTrim).value

                        percent = 0
                        startTime = parseInt(time_usec)

                        _activeVehicle.setServo(servoIndex,pwmTrim,false)

                        0 < setTime ? timer.start() : ""
                    }
                }

                QGCButton{
                    id:buttonMax
                    text: qsTr("최대")
                    width: ScreenTools.defaultFontPixelWidth * 5
                    height:ScreenTools.defaultFontPixelHeight * 1.5
                    visible: currentTool == servoDialog
                    enabled : !timer.running

                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
//                        console.log("Max // clicked")

                        checkTimer.stop()
//                        var curPwm = parseInt(curMessage.fields.get(fieldIndex).value)
                        var pwmMax = factPanelController.getParameterFact(-1,servoMax).value

                        percent = 0
                        startTime = parseInt(time_usec)

                        _activeVehicle.setServo(servoIndex,pwmMax,false)

                        0 < setTime ? timer.start() : ""
                    }
                }

                QGCTextField{
                    id:timeFieled
                    text: qsTr(setTime.toString())
                    unitsLabel:"초"
                    showUnits: true
                    width: ScreenTools.defaultFontPixelWidth * 5
                    height:ScreenTools.defaultFontPixelHeight * 1.5
                    visible: currentTool == setTimer
                    enabled: !timer.running

                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                    Layout.alignment: Qt.AlignRight

                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                    onEditingFinished: {
                        setTime = parseInt(timeFieled.text)
                    }
                    onAccepted: {
                        setTime = parseInt(timeFieled.text)
                    }
                }

                QGCButton{
                    id:buttoninit
                    text: qsTr("Clear")
                    width: ScreenTools.defaultFontPixelWidth * 5
                    height:ScreenTools.defaultFontPixelHeight * 1.5
                    visible: currentTool == setTimer
                    enabled: !timer.running

                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
//                        console.log("timerInit // clicked")
                        setTime = 0
                    }
                }

                Timer {
                    id:timer
                    interval: 500
                    repeat: true
                    onTriggered: {
                        var nowTime = parseInt(time_usec)
                        var pwmMin = factPanelController.getParameterFact(-1,servoMin).value
                        percent = Math.round(((nowTime - startTime)/10000)/setTime)

                        if (100 <= percent){
                            percent = 100
                            checkCnt = 0
                            timer.stop()
                            _activeVehicle.setServo(servoIndex,pwmMin,false)
                            checkTimer.start()
                        }
                    }
                }

                Timer{
                    id:checkTimer
                    interval: 1000
                    repeat: true
                    onTriggered: {
                        var curPwm = parseInt(curMessage.fields.get(fieldIndex).value)
                        var pwmMin = factPanelController.getParameterFact(-1,servoMin).value
                        0 === curPwm || 3 < checkCnt ? checkTimer.stop() : _activeVehicle.setServo(servoIndex,pwmMin,false)

                        checkCnt = checkCnt + 1
                    }
                }
            }
        }
    }
}

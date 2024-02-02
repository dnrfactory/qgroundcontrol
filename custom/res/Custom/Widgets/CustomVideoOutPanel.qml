/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/
import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtMultimedia             5.5
import QtQml                    2.12

import QGroundControl.Controls      1.0

Item {
    id: root

    property var mediaSource: ""

    readonly property real itemMargin: 2

    function play() {
        mediaPlayer.play()
    }

    MediaPlayer {
        id: mediaPlayer
        source: mediaSource
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        source: mediaPlayer
    }

    Item {
        x: videoOutput.contentRect.x
        y: videoOutput.contentRect.y
        width: videoOutput.contentRect.width
        height: videoOutput.contentRect.height
        visible: mediaPlayer.playbackState !== MediaPlayer.StoppedState

        QGCLabel {
            id: playbackStatusText
            text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? qsTr("\u23F8") : qsTr("\u25B6")
            font.pointSize: 40
            anchors.centerIn: parent
            opacity: 0

            OpacityAnimator {
                id: opacityAnimator
                target: playbackStatusText
                from: 1
                to: 0
                duration: 2000
                running: false
            }

            function startAnimation() {
                opacityAnimator.stop()
                playbackStatusText.opacity = 1
                opacityAnimator.start()
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mediaPlayer.playbackState === MediaPlayer.PlayingState ?
                mediaPlayer.pause() : mediaPlayer.play()

                playbackStatusText.startAnimation()
            }
        }

        CustomButton {
            id: closeButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: root.itemMargin
            anchors.rightMargin: root.itemMargin
            width: 40
            height: 40
            backRadius: 8
            opacity: hovered ? 1 : 0

            text: "\u2715"
            pointSize: 20
            normalColor: "transparent"
            hightlightColor: "lightgrey"

            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                }
            }

            onClicked: {
                if (opacity === 1) {
                    mediaPlayer.stop()
                }
            }
        }

        Slider {
            id: durationSlider
            width: parent.width
            anchors.bottom: parent.bottom
            opacity: hovered || pressed ? 1 : 0

            from: 0
            to: mediaPlayer.duration

            value: mediaPlayer.position

            onPressedChanged: {
                mediaPlayer.seek(durationSlider.position * mediaPlayer.duration)
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                }
            }
        }

        Connections {
            target: mediaPlayer
            onPositionChanged: {
                if (durationSlider.pressed === false) {
                    durationSlider.value = mediaPlayer.position
                }
            }
        }
    }
}

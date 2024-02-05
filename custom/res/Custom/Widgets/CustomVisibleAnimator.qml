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
import QtQml                    2.12

Item {
    id: root

    property var animationTarget: root

    OpacityAnimator {
        id: opacityAnimator
        target: animationTarget
        from: 0
        to: 1
        duration: 200
        running: false
    }

    Connections {
        target: animationTarget
        onVisibleChanged: {
            if (visible) {
                opacityAnimator.stop()
                animationTarget.opacity = 0
                opacityAnimator.start()
            }
        }
    }
}

/*
    SPDX-FileCopyrightText: 2012 Viranch Mehta <viranch.mehta@gmail.com>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

Image {
    id: handRoot

    property alias rotation: rotation.angle
    property double pngScale
    property double horizontalRotationOffset: 0
    property double verticalRotationOffset: 0
    readonly property double horizontalRotationCenter: width / 2
    readonly property double verticalRotationCenter: height / 2

    anchors {
        top: clock.verticalCenter
        topMargin: -verticalRotationCenter + verticalRotationOffset
        left: clock.horizontalCenter
        leftMargin: -horizontalRotationCenter + horizontalRotationOffset
    }

    transform: Rotation {
        id: rotation
        angle: 0
        origin {
            x: handRoot.horizontalRotationCenter
            y: handRoot.verticalRotationCenter
        }
        Behavior on angle {
            RotationAnimation {
                id: anim
                duration: Kirigami.Units.longDuration
                direction: RotationAnimation.Clockwise
                easing.type: Easing.OutElastic
            }
        }
    }
}

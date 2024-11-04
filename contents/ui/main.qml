/*
    SPDX-FileCopyrightText: 2012 Viranch Mehta <viranch.mehta@gmail.com>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid 
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.calendar as PlasmaCalendar

PlasmoidItem {
    id: analogclock

    readonly property string currentTime: Qt.locale().toString(dataSource.data["Local"]["DateTime"], Qt.locale().timeFormat(Locale.LongFormat))
    readonly property string currentDate: Qt.locale().toString(dataSource.data["Local"]["DateTime"], Qt.locale().dateFormat(Locale.LongFormat).replace(/(^dddd.?\s)|(,?\sdddd$)/, ""))

    property int hours
    property int minutes
    property int seconds
    property bool showSecondsHand: Plasmoid.configuration.showSecondHand
    property int tzOffset

    Plasmoid.backgroundHints: "NoBackground";
    preferredRepresentation: compactRepresentation

    toolTipMainText: Qt.locale().toString(dataSource.data["Local"]["DateTime"],"dddd")
    toolTipSubText: `${currentTime}\n${currentDate}`


    function dateTimeChanged() {
        var currentTZOffset = dataSource.data["Local"]["Offset"] / 60;
        if (currentTZOffset !== tzOffset) {
            tzOffset = currentTZOffset;
            Date.timeZoneUpdated(); // inform the QML JS engine about TZ change
        }
    }

    P5Support.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: "Local"
        interval: showSecondsHand || (analogclock.compactRepresentationItem && analogclock.compactRepresentationItem.containsMouse) ? 1000 : 30000
        onDataChanged: {
            var date = new Date(data["Local"]["DateTime"]);
            hours = date.getHours();
            minutes = date.getMinutes();
            seconds = date.getSeconds();
        }
        Component.onCompleted: {
            dataChanged();
        }
    }

    compactRepresentation: MouseArea {
        id: representation

        Layout.minimumWidth: Plasmoid.formFactor !== PlasmaCore.Types.Vertical ? representation.height : Kirigami.Units.gridUnit
        Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? representation.width : Kirigami.Units.gridUnit

        property bool wasExpanded

        activeFocusOnTab: true
        hoverEnabled: true

        Accessible.name: Plasmoid.title
        Accessible.description: i18nc("@info:tooltip", "Current time is %1; Current date is %2", analogclock.currentTime, analogclock.currentDate)
        Accessible.role: Accessible.Button

        onPressed: wasExpanded = analogclock.expanded
        onClicked: analogclock.expanded = !wasExpanded

        Item {
            id: clock

            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width

            Image {
                id: face
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: Math.min(parent.width, parent.height)
                source: "../images/trad.png"
                z: 1
            }

            Hand {
                source: "../images/trad_h.png"
                rotation: hours * 30 + (minutes/2)
                z: 997
            }

            Hand {
                source: "../images/trad_m.png"
                rotation: minutes * 6
                z: 998
            }

            Hand {
                visible: showSecondsHand
                source: "../images/trad_s.png"
                rotation: seconds * 6
                z: 999
            }

            Image {
                id: center
                anchors.centerIn: clock
                source: "../images/trad_dot.png"
                z: 1000
            }
        }
    }

    fullRepresentation: PlasmaCalendar.MonthView {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 22
        Layout.maximumWidth: Kirigami.Units.gridUnit * 80
        Layout.minimumHeight: Kirigami.Units.gridUnit * 22
        Layout.maximumHeight: Kirigami.Units.gridUnit * 40

        readonly property var appletInterface: analogclock

        today: dataSource.data["Local"]["DateTime"]
    }

    Component.onCompleted: {
        tzOffset = new Date().getTimezoneOffset();
        dataSource.onDataChanged.connect(dateTimeChanged);
    }
}

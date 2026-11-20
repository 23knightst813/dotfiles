pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

MaterialIcon {
    id: root

    required property color colour

    animate: true
    text: WirelessDisplay.connected ? "cast_connected" : "cast"
    color: WirelessDisplay.connected ? Colours.palette.m3primary : root.colour
    fill: WirelessDisplay.connected ? 1 : 0

    SequentialAnimation on opacity {
        running: WirelessDisplay.connecting
        alwaysRunToEnd: true
        loops: Animation.Infinite

        Anim {
            from: 1
            to: 0.25
            duration: Tokens.anim.durations.large
            easing: Tokens.anim.standardAccel
        }
        Anim {
            from: 0.25
            to: 1
            duration: Tokens.anim.durations.large
            easing: Tokens.anim.standardDecel
        }
    }
}

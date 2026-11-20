pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.modules.bar.popouts as BarPopouts

StyledRect {
    id: root

    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts

    property bool expanded: false

    readonly property real nonAnimHeight: headerRow.implicitHeight + (expanded ? detailsCol.implicitHeight + layout.spacing : 0) + layout.anchors.margins * 2

    implicitHeight: nonAnimHeight

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainer
    clip: true

    onExpandedChanged: {
        if (expanded) {
            WirelessDisplay.refreshStatus();
            if (WirelessDisplay.available && WirelessDisplay.sinks.length === 0 && !WirelessDisplay.scanning)
                WirelessDisplay.discover();
        }
    }

    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: headerRow.implicitHeight + layout.anchors.margins * 2
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    ColumnLayout {
        id: layout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.medium

        RowLayout {
            id: headerRow

            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: icon.implicitHeight + Tokens.padding.large

                radius: Tokens.rounding.full
                color: WirelessDisplay.connected ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    id: icon

                    anchors.centerIn: parent
                    animate: true
                    text: WirelessDisplay.connected ? "cast_connected" : "cast"
                    color: WirelessDisplay.connected ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                    fontStyle: Tokens.font.icon.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: Tr.tr("Wireless display")
                    font: Tokens.font.body.medium
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        if (!WirelessDisplay.available)
                            return Tr.tr("waycast not found");
                        if (WirelessDisplay.connecting)
                            return Tr.tr("Connecting to %1...").arg(WirelessDisplay.connectingSink);
                        if (WirelessDisplay.connected)
                            return Tr.tr("Casting to %1").arg(WirelessDisplay.activeSink);
                        if (WirelessDisplay.scanning)
                            return Tr.tr("Scanning for displays...");
                        return Tr.tr("Ready to cast");
                    }
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                    elide: Text.ElideRight
                    animate: true
                }
            }

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: actionIcon.implicitHeight + Tokens.padding.small * 2

                radius: Tokens.rounding.full
                color: WirelessDisplay.connected ? Colours.palette.m3primary : Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)

                CircularIndicator {
                    anchors.fill: parent
                    running: WirelessDisplay.connecting
                }

                StateLayer {
                    color: WirelessDisplay.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                    disabled: WirelessDisplay.connecting
                    onClicked: {
                        if (WirelessDisplay.connected)
                            WirelessDisplay.disconnect();
                        else
                            root.expanded = !root.expanded;
                    }
                }

                MaterialIcon {
                    id: actionIcon

                    anchors.centerIn: parent
                    animate: true
                    text: WirelessDisplay.connected ? "link_off" : (root.expanded ? "expand_less" : "expand_more")
                    color: WirelessDisplay.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                    opacity: WirelessDisplay.connecting ? 0 : 1

                    Behavior on opacity {
                        Anim {
                            type: Anim.DefaultEffects
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: detailsCol

            visible: root.expanded
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? implicitHeight : 0
            spacing: Tokens.spacing.small

            Toggle {
                label: Tr.tr("Extend display")
                checked: WirelessDisplay.extendMode
                toggle.onToggled: WirelessDisplay.extendMode = checked
            }

            Toggle {
                label: Tr.tr("Stream audio")
                checked: WirelessDisplay.audioEnabled
                toggle.onToggled: WirelessDisplay.audioEnabled = checked
            }

            StyledProgressBar {
                visible: WirelessDisplay.scanning || WirelessDisplay.connecting
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? implicitHeight : 0
                indeterminate: true
            }

            StyledText {
                Layout.topMargin: Tokens.spacing.extraSmall
                Layout.fillWidth: true
                text: {
                    if (!WirelessDisplay.available)
                        return Tr.tr("waycast binary not found");
                    if (WirelessDisplay.scanning && WirelessDisplay.sinks.length === 0)
                        return Tr.tr("Searching for Miracast displays...");
                    return Tr.trN("%n display available", "%n displays available", WirelessDisplay.sinks.length);
                }
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
            }

            RowLayout {
                visible: WirelessDisplay.available && !WirelessDisplay.scanning && WirelessDisplay.sinks.length === 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? implicitHeight : 0
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: "tv_off"
                    color: Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Tr.tr("No wireless displays found")
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                    elide: Text.ElideRight
                }
            }

            StyledText {
                visible: WirelessDisplay.errorMessage.length > 0 || WirelessDisplay.doctorWarning.length > 0
                Layout.preferredHeight: visible ? implicitHeight : 0
                Layout.fillWidth: true
                text: WirelessDisplay.errorMessage.length > 0 ? WirelessDisplay.errorMessage : WirelessDisplay.doctorWarning
                color: WirelessDisplay.errorMessage.length > 0 ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: ScriptModel {
                    values: [...WirelessDisplay.sinks].sort((a, b) => {
                        const aActive = WirelessDisplay.connected && WirelessDisplay.activeSink === a.name;
                        const bActive = WirelessDisplay.connected && WirelessDisplay.activeSink === b.name;
                        if (aActive !== bActive)
                            return bActive - aActive;
                        return a.name.localeCompare(b.name);
                    }).slice(0, 6)
                }

                RowLayout {
                    id: sinkItem

                    required property var modelData
                    readonly property bool isConnected: WirelessDisplay.connected && WirelessDisplay.activeSink === modelData.name
                    readonly property bool isConnecting: WirelessDisplay.connecting && WirelessDisplay.connectingSink === modelData.name
                    readonly property bool loading: isConnecting

                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    MaterialIcon {
                        text: sinkItem.isConnected ? "cast_connected" : "tv"
                        color: sinkItem.isConnected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.leftMargin: Tokens.spacing.extraSmall
                        Layout.rightMargin: Tokens.spacing.extraSmall
                        Layout.fillWidth: true
                        text: sinkItem.modelData.name
                        elide: Text.ElideRight
                        font: Tokens.font.body.builders.medium.weight(sinkItem.isConnected ? Font.Medium : Font.Normal).build()
                        color: sinkItem.isConnected ? Colours.palette.m3primary : Colours.palette.m3onSurface
                    }

                    StyledRect {
                        implicitWidth: implicitHeight
                        implicitHeight: connectIcon.implicitHeight + Tokens.padding.extraSmall

                        radius: Tokens.rounding.full
                        color: Qt.alpha(Colours.palette.m3primary, sinkItem.isConnected ? 1 : 0)

                        CircularIndicator {
                            anchors.fill: parent
                            running: sinkItem.loading
                        }

                        StateLayer {
                            color: sinkItem.isConnected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                            disabled: sinkItem.loading || !WirelessDisplay.available || (WirelessDisplay.connecting && !sinkItem.isConnecting)

                            onClicked: {
                                if (sinkItem.isConnected)
                                    WirelessDisplay.disconnect();
                                else
                                    WirelessDisplay.connect(sinkItem.modelData.name);
                            }
                        }

                        MaterialIcon {
                            id: connectIcon

                            anchors.centerIn: parent
                            animate: true
                            text: sinkItem.isConnected ? "link_off" : "link"
                            color: sinkItem.isConnected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                            opacity: sinkItem.loading ? 0 : 1

                            Behavior on opacity {
                                Anim {
                                    type: Anim.DefaultEffects
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                Layout.topMargin: Tokens.spacing.extraSmall
                Layout.fillWidth: true
                implicitHeight: rescanBtn.implicitHeight + Tokens.padding.small

                radius: Tokens.rounding.full
                color: Colours.palette.m3primaryContainer

                StateLayer {
                    color: Colours.palette.m3onPrimaryContainer
                    disabled: WirelessDisplay.scanning || !WirelessDisplay.available
                    onClicked: WirelessDisplay.discover()
                }

                RowLayout {
                    id: rescanBtn

                    anchors.centerIn: parent
                    spacing: Tokens.spacing.small
                    opacity: WirelessDisplay.scanning ? 0 : 1

                    MaterialIcon {
                        id: scanIcon

                        Layout.topMargin: Math.round(fontInfo.pointSize * 0.0575)
                        animate: true
                        text: "cast"
                        color: Colours.palette.m3onPrimaryContainer
                    }

                    StyledText {
                        Layout.topMargin: -Math.round(scanIcon.fontInfo.pointSize * 0.0575)
                        text: Tr.tr("Rescan displays")
                        color: Colours.palette.m3onPrimaryContainer
                    }

                    Behavior on opacity {
                        Anim {
                            type: Anim.DefaultEffects
                        }
                    }
                }

                CircularIndicator {
                    anchors.centerIn: parent
                    strokeWidth: Tokens.padding.extraSmall / 2
                    bgColour: "transparent"
                    implicitSize: parent.implicitHeight - Tokens.padding.large
                    running: WirelessDisplay.scanning
                }
            }
        }
    }

    component Toggle: RowLayout {
        required property string label
        property alias checked: toggle.checked
        property alias toggle: toggle

        Layout.fillWidth: true
        spacing: Tokens.spacing.medium

        StyledText {
            Layout.fillWidth: true
            text: parent.label
        }

        StyledSwitch {
            id: toggle
        }
    }
}

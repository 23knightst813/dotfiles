pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    id: root

    required property PopoutState popouts

    spacing: Tokens.spacing.small
    width: Tokens.sizes.bar.networkWidth

    StyledText {
        Layout.topMargin: Tokens.padding.medium
        Layout.rightMargin: Tokens.padding.extraSmall
        text: Tr.tr("Wireless display")
        font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
    }

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

    StyledText {
        Layout.topMargin: Tokens.spacing.small
        Layout.rightMargin: Tokens.padding.extraSmall
        text: {
            if (!WirelessDisplay.available)
                return Tr.tr("waycast binary not found");
            if (WirelessDisplay.scanning && WirelessDisplay.sinks.length === 0)
                return Tr.tr("Scanning for displays...");
            return Tr.trN("%n display available", "%n displays available", WirelessDisplay.sinks.length);
        }
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.body.small
    }

    StyledText {
        visible: WirelessDisplay.errorMessage.length > 0 || WirelessDisplay.doctorWarning.length > 0
        Layout.preferredHeight: visible ? implicitHeight : 0
        Layout.fillWidth: true
        Layout.rightMargin: Tokens.padding.extraSmall
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
            }).slice(0, 8)
        }

        RowLayout {
            id: sinkItem

            required property var modelData
            readonly property bool isConnected: WirelessDisplay.connected && WirelessDisplay.activeSink === modelData.name
            readonly property bool isConnecting: WirelessDisplay.connecting && WirelessDisplay.connectingSink === modelData.name
            readonly property bool loading: isConnecting

            Layout.fillWidth: true
            Layout.rightMargin: Tokens.padding.extraSmall
            spacing: Tokens.spacing.small

            opacity: 0
            scale: 0.7

            Component.onCompleted: {
                opacity = 1;
                scale = 1;
            }

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }

            Behavior on scale {
                Anim {}
            }

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
        Layout.topMargin: Tokens.spacing.small
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

    Connections {
        function onCurrentNameChanged(): void {
            if (root.popouts.currentName === "wirelessdisplay") {
                WirelessDisplay.refreshStatus();
                if (WirelessDisplay.available && WirelessDisplay.sinks.length === 0 && !WirelessDisplay.scanning)
                    WirelessDisplay.discover();
            }
        }

        target: root.popouts
    }

    component Toggle: RowLayout {
        required property string label
        property alias checked: toggle.checked
        property alias toggle: toggle

        Layout.fillWidth: true
        Layout.rightMargin: Tokens.padding.extraSmall
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

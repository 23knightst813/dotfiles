pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: Tr.tr("Colours")
    isSubPage: true

    readonly property list<var> schemesList: [
        { id: "dynamic", name: "Dynamic", desc: "Derived dynamically from current wallpaper", icon: "auto_awesome" },
        { id: "tokyonight", name: "Tokyo Night", desc: "Clean dark blue-tinted modern theme", icon: "nightlight" },
        { id: "catppuccin", name: "Catppuccin", desc: "Soothing pastel warm palette", icon: "cruelty_free" },
        { id: "nord", name: "Nord", desc: "Arctic, north-bluish clean aesthetic", icon: "ac_unit" },
        { id: "rosepine", name: "Rosé Pine", desc: "All natural pine, faux, and bougainvillea", icon: "spa" },
        { id: "gruvbox", name: "Gruvbox", desc: "Retro groove warm autumn tones", icon: "coffee" },
        { id: "everforest", name: "Everforest", desc: "Comforting natural green hues", icon: "forest" },
        { id: "onedark", name: "One Dark", desc: "Atom-inspired balanced dark theme", icon: "code" },
        { id: "dracula", name: "Dracula", desc: "Vibrant high-contrast dark palette", icon: "dark_mode" },
        { id: "oldworld", name: "Old World", desc: "Muted parchment and earthy tones", icon: "history_edu" },
        { id: "darkgreen", name: "Dark Green", desc: "Deep forest and emerald accents", icon: "eco" },
        { id: "caelestia", name: "Caelestia", desc: "Original cosmic celestial palette", icon: "stars" },
        { id: "everblush", name: "Everblush", desc: "Dark minimal tones with soft blush", icon: "brush" },
        { id: "solarized", name: "Solarized", desc: "Precision-engineered solarized palette", icon: "wb_sunny" }
    ]

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCente
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: Tr.tr("Appearance")
        }

        ToggleRow {
            first: true
            text: Tr.tr("Dark theme")
            subtext: Tr.tr("Switch between dark and light appearance")
            checked: !Colours.light
            onToggled: Colours.setMode(checked ? "dark" : "light")
        }

        ToggleRow {
            last: true
            text: Tr.tr("Smart colour scheme")
            subtext: Tr.tr("Derive theme mode and variant from the wallpaper")
            checked: GlobalConfig.services.smartScheme
            onToggled: GlobalConfig.services.smartScheme = checked
        }

        SectionHeader {
            text: Tr.tr("Preset schemes")
        }

        Repeater {
            model: root.schemesList

            RowButton {
                required property var modelData
                required property int index

                first: index === 0
                last: index === root.schemesList.length - 1

                icon: modelData.icon
                text: modelData.name
                subtext: modelData.desc
                trailingIcon: Colours.scheme === modelData.id ? "check" : ""

                onClicked: {
                    Quickshell.execDetached(["caelestia", "scheme", "set", "--notify", "-n", modelData.id]);
                }
            }
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import Caelestia.Services
import qs.services
import qs.utils
import qs.modules.launcher

Searcher {
    id: root

    function transformSearch(search: string): string {
        return search.slice(GlobalConfig.launcher.actionPrefix.length);
    }

    list: variants.instances
    useFuzzy: GlobalConfig.launcher.useFuzzy.actions

    Variants {
        id: variants

        model: {
            const enableDangerous = GlobalConfig.launcher.enableDangerousActions;
            return GlobalConfig.launcher.actions.values.filter(a => a.enabled && (enableDangerous || !a.dangerous));
        }

        Action {}
    }

    component Action: QtObject {
        required property var modelData
        readonly property string name: modelData.name ? Tr.trMarked(modelData.name) : Tr.trCtx("Unnamed", "launcher action with no name")
        readonly property string desc: modelData.description ? Tr.trMarked(modelData.description) : Tr.trCtx("No description", "launcher action with no description")
        readonly property string icon: modelData.icon ?? "help_outline"
        readonly property list<string> command: modelData.command ?? []
        readonly property bool enabled: modelData.enabled ?? true
        readonly property bool dangerous: modelData.dangerous ?? false

        function onClicked(list: AppList): void {
            if (command.length === 0)
                return;

            if (command[0] === "autocomplete" && command.length > 1) {
                list.search.text = `${GlobalConfig.launcher.actionPrefix}${command[1]} `;
            } else if (command[0] === "setMode" && command.length > 1) {
                list.screenState.launcher = false;
                Colours.setMode(command[1]);
            } else {
                list.screenState.launcher = false;
                const c0 = command[0] ?? "";
                const c1 = command[1] ?? "";
                if (c0 === "logout" || (c0 === "loginctl" && (c1 === "terminate-user" || c1 === "terminate-session")))
                    Quickshell.execDetached(["/home/theo/.local/bin/loginctl", "terminate-user"]);
                else if (c0 === "poweroff" || c0 === "shutdown" || (c0 === "systemctl" && c1 === "poweroff") || (c0 === "loginctl" && c1 === "poweroff"))
                    Quickshell.execDetached(["/home/theo/.local/bin/systemctl", "poweroff"]);
                else if (c0 === "reboot" || (c0 === "systemctl" && c1 === "reboot") || (c0 === "loginctl" && c1 === "reboot"))
                    Quickshell.execDetached(["/home/theo/.local/bin/systemctl", "reboot"]);
                else if (c0 === "hibernate" || c0 === "suspend" || c0 === "suspendThenHibernate" || c0 === "suspend-then-hibernate" || (c0 === "systemctl" && (c1 === "suspend" || c1 === "hibernate" || c1 === "suspend-then-hibernate")))
                    Quickshell.execDetached(["/home/theo/.local/bin/systemctl", "suspend"]);
                else if (c0 === "lock" || (c0 === "loginctl" && c1 === "lock-session"))
                    Quickshell.execDetached(["/home/theo/.local/bin/loginctl", "lock-session"]);
                else
                    Quickshell.execDetached(command);
            }
        }
    }
}

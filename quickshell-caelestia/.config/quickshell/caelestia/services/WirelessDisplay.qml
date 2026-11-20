pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string binaryPath: ""
    readonly property bool available: binaryPath.length > 0

    property bool scanning: false
    property bool connecting: false
    property bool connected: false
    property bool streaming: false
    property string activeSink: ""
    property string connectingSink: ""

    property bool extendMode: false
    property bool audioEnabled: true

    property list<var> sinks: []
    property string errorMessage: ""
    property string doctorWarning: ""

    function resolveBinary(): void {
        whichProc.running = true;
    }

    function refreshStatus(): void {
        if (!available || statusProc.running)
            return;
        statusProc.running = true;
    }

    function checkDoctor(): void {
        if (!available || doctorProc.running)
            return;
        doctorProc.running = true;
    }

    function discover(): void {
        if (!available || scanning)
            return;

        errorMessage = "";
        scanning = true;
        discoverProc.command = [binaryPath, "discover", "--json", "-t", "6"];
        discoverProc.running = true;
    }

    function connect(sinkName: string): void {
        if (!available || !sinkName || connecting)
            return;

        errorMessage = "";
        connectingSink = sinkName;
        connecting = true;

        const args = [binaryPath, "daemon", "--json", "-s", sinkName];
        if (extendMode)
            args.push("--extend");
        if (audioEnabled)
            args.push("--audio");

        daemonProc.command = args;
        daemonProc.running = true;
    }

    function disconnect(): void {
        if (!available)
            return;

        connecting = false;
        connectingSink = "";
        disconnectProc.command = [binaryPath, "disconnect"];
        disconnectProc.running = true;
    }

    Component.onCompleted: resolveBinary()

    Process {
        id: whichProc

        command: ["sh", "-c", "command -v waycast || ([ -x \"$HOME/.local/bin/waycast\" ] && echo \"$HOME/.local/bin/waycast\")"]
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim().split("\n")[0] ?? "";
                root.binaryPath = path;
                if (path.length > 0) {
                    root.refreshStatus();
                    root.checkDoctor();
                }
            }
        }
    }

    Process {
        id: statusProc

        command: [root.binaryPath, "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim());
                    root.connected = Boolean(data.connected);
                    root.streaming = Boolean(data.streaming);
                    root.activeSink = data.sink ?? "";
                    if (root.connected) {
                        root.connecting = false;
                        root.connectingSink = "";
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: doctorProc

        command: ["sh", "-c", "pgrep -x wireplumber >/dev/null 2>&1 && echo WP_OK; \"$1\" doctor --json", "_", root.binaryPath]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split("\n");
                    const wpOk = lines[0] === "WP_OK";
                    const jsonText = wpOk ? lines.slice(1).join("\n") : text.trim();
                    const data = JSON.parse(jsonText);
                    if (data.all_ok) {
                        root.doctorWarning = "";
                        return;
                    }
                    const checks = data.checks ?? {};
                    const warnings = [];
                    for (const key of Object.keys(checks)) {
                        const msg = String(checks[key]);
                        // waycast doctor checks systemd for wireplumber; skip on non-systemd (Void) when wireplumber is running
                        if (key === "pipewire" && wpOk && msg.toLowerCase().includes("media session manager"))
                            continue;
                        if (msg.toLowerCase().includes("missing") || msg.toLowerCase().includes("fail") || msg.toLowerCase().includes("error"))
                            warnings.push(msg);
                    }
                    root.doctorWarning = warnings.join("\n");
                } catch (e) {}
            }
        }
    }

    Process {
        id: discoverProc

        stdout: StdioCollector {
            onStreamFinished: {
                root.scanning = false;
                try {
                    const data = JSON.parse(text.trim());
                    const raw = Array.isArray(data.devices) ? data.devices : [];
                    root.sinks = raw.map(d => {
                        if (typeof d === "string")
                            return { name: d, address: "" };
                        return {
                            name: d.name ?? d.sink ?? d.id ?? d.address ?? "Unknown display",
                            address: d.address ?? d.mac ?? d.p2p_address ?? ""
                        };
                    });
                } catch (e) {
                    root.errorMessage = "Failed to parse discovered displays";
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0 && root.sinks.length === 0 && !root.scanning)
                    root.errorMessage = text.trim().split("\n").slice(-1)[0];
            }
        }
        onExited: exitCode => {
            root.scanning = false;
            if (exitCode !== 0 && root.errorMessage.length === 0)
                root.errorMessage = "Display scan failed (exit " + exitCode + ")";
        }
    }

    Process {
        id: daemonProc

        stdout: SplitParser {
            onRead: line => {
                const trimmed = line.trim();
                if (!trimmed)
                    return;
                try {
                    const evt = JSON.parse(trimmed);
                    if (evt.connected !== undefined)
                        root.connected = Boolean(evt.connected);
                    if (evt.streaming !== undefined)
                        root.streaming = Boolean(evt.streaming);
                    if (evt.sink)
                        root.activeSink = String(evt.sink);
                    if (evt.state === "streaming" || evt.event === "streaming") {
                        root.connected = true;
                        root.streaming = true;
                        root.connecting = false;
                        root.connectingSink = "";
                    } else if (evt.error) {
                        root.errorMessage = String(evt.error);
                    }
                } catch (e) {}
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                const msg = text.trim();
                if (msg.length > 0 && !root.connected)
                    root.errorMessage = msg.split("\n").slice(-1)[0];
            }
        }
        onExited: exitCode => {
            root.connecting = false;
            root.connectingSink = "";
            root.connected = false;
            root.streaming = false;
            root.activeSink = "";
            if (exitCode !== 0 && root.errorMessage.length === 0)
                root.errorMessage = "Connection ended (exit " + exitCode + ")";
        }
    }

    Process {
        id: disconnectProc

        onExited: {
            if (daemonProc.running)
                daemonProc.signal(15); // SIGTERM
            root.connected = false;
            root.streaming = false;
            root.activeSink = "";
            root.connecting = false;
            root.connectingSink = "";
        }
    }
}

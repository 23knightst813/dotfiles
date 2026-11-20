-- macOS-style Caelestia bindings.
--
-- keyd maps the physical Left Ctrl to Super (Command) and the physical
-- Left Win to Control.  It also translates the common Cmd+<letter>
-- shortcuts to Ctrl+<letter> for GUI apps.  That means any bind using one
-- of those letters with SUPER can never fire, so the WM binds below use
-- only the free letters (B, D, E, H, M, Q), punctuation, arrows, numbers
-- and function keys.
return {
    ------------------
    ---- HYPRLAND ----
    ------------------

    -- Local overrides (kept from the user's config)
    cursorTheme                = "macOS",
    cursorSize                 = 24,
    sleepGestureCmd            = "systemctl suspend",

    -- Workspaces
    kbGoToWs                   = "SUPER",
    kbGoToWsGroup              = "CTRL + SUPER",
    kbMoveWinToWs              = "SUPER + ALT",
    kbMoveWinToWsSilent        = "CTRL + ALT + SHIFT",
    kbMoveWinToWsGroup         = "CTRL + SUPER + ALT",

    -- Move window to/from special workspace
    kbMoveWinToWsSpecial       = { "SUPER + ALT + SHIFT + grave", "CTRL + SUPER + SHIFT + Up" },
    kbMoveWinFromWsSpecial     = "CTRL + SUPER + SHIFT + Down",
    kbMoveWinToWsNext          = { "SUPER + ALT + Page_Down", "CTRL + SUPER + SHIFT + Right" },
    kbMoveWinToWsPrev          = { "SUPER + ALT + Page_Up", "CTRL + SUPER + SHIFT + Left" },
    kbNextWs                   = { "SUPER + Page_Down", "CTRL + SUPER + Right" },
    kbPrevWs                   = { "SUPER + Page_Up", "CTRL + SUPER + Left" },
    kbNextWsGroup              = "CTRL + SUPER + mouse_down",
    kbPrevWsGroup              = "CTRL + SUPER + mouse_up",

    -- Window cycle (Cmd+Tab / Cmd+`)
    kbWindowCycleNext          = { "SUPER + Tab", "SUPER + grave" },
    kbWindowCyclePrev          = { "SUPER + SHIFT + Tab", "SUPER + SHIFT + grave" },
    kbWindowGroupCycleNext     = "CTRL + ALT + Tab",
    kbWindowGroupCyclePrev     = "CTRL + SHIFT + ALT + Tab",
    kbUngroup                  = "SUPER + ALT + Comma",
    kbToggleGroup              = "SUPER + Comma",
    kbGroupLockActive          = "SUPER + SHIFT + Comma",

    -- Window actions
    kbWindowDecreaseWidth      = "SUPER + ALT + Minus",
    kbWindowIncreaseWidth      = "SUPER + ALT + Equal",
    kbWindowDecreaseHeight     = "SUPER + ALT + SHIFT + Minus",
    kbWindowIncreaseHeight     = "SUPER + ALT + SHIFT + Equal",

    kbMoveWindow               = "SUPER + ALT + B",
    kbResizeWindow             = "SUPER + ALT + End",
    kbCenterWindow             = "CTRL + SUPER + Backslash",
    kbNormalizeWindow          = "CTRL + SUPER + ALT + Backslash",
    kbWindowPip                = "SUPER + ALT + Backslash",
    kbPinWindow                = "SUPER + ALT + Home",
    kbWindowFullscreen         = "SUPER + F11",
    kbWindowBorderedFullscreen = "SUPER + ALT + F11",
    kbToggleWindowFloating     = "SUPER + ALT + Space",
    kbCloseWindow              = "SUPER + Q",

    -- Special workspaces
    kbSpecialWs                = "SUPER + ALT + grave",
    kbSystemMonitorWs          = "CTRL + SHIFT + Escape",
    kbMusicWs                  = "SUPER + ALT + Period",
    kbCommunicationWs          = "SUPER + ALT + Slash",
    kbTodoWs                   = "SUPER + ALT + Semicolon",

    -- Apps
    kbTerminal                 = "SUPER + Return",
    kbBrowser                  = "SUPER + B",
    kbEditor                   = "SUPER + E",
    kbFileExplorer             = "SUPER + SHIFT + D",
    kbAudioSettings            = "CTRL + ALT + V",

    -- Utilities
    kbScreenshot               = { "Print", "SUPER + SHIFT + 3" },
    kbScreenshotFreeze         = "SUPER + SHIFT + 5",
    kbScreenshotRegion         = "SUPER + SHIFT + 4",
    kbRecord                   = "CTRL + ALT + R",
    kbRecordSound              = "CTRL + SHIFT + ALT + R",
    kbRecordRegion             = "SUPER + ALT + SHIFT + Print",
    kbColorPicker              = "SUPER + ALT + Print",

    -- Media
    kbMediaToggle              = "CTRL + ALT + Space",
    kbMediaNext                = "CTRL + SUPER + Equal",
    kbMediaPrev                = "CTRL + SUPER + Minus",
    kbMediaStop                = "CTRL + SUPER + Backspace",
    kbVolumeMute               = "SUPER + SHIFT + M",

    -- Misc
    -- Tapping physical Left Ctrl (mapped to SUPER by keyd) opens the launcher;
    -- SUPER + Space is also bound in hypr-user.lua.
    kbLauncher                 = "SUPER + SUPER_L",
    kbSession                  = { "CTRL + ALT + Delete", "SUPER + SHIFT + Q" },
    kbShowSidebar              = "SUPER + ALT + Page_Up",
    kbClearNotifs              = "CTRL + ALT + C",
    kbShowPanels               = "SUPER + ALT + Page_Down",
    kbLock                     = "CTRL + SUPER + Q",
    kbRestoreLock              = "SUPER + ALT + Escape",
    kbSleep                    = "SUPER + ALT + SHIFT + Escape",

    -- Clipboard and emoji picker
    kbClipboard                = "SUPER + Insert",
    kbClipboardDel             = "SUPER + SHIFT + Insert",
    kbClipboardPasteLatest     = "CTRL + SHIFT + ALT + V",
    kbEmoji                    = "CTRL + SUPER + Space",
}

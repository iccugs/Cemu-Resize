#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force
SetWinDelay -1  ; faster window moves

; =========================================================
; ===============            CONFIG             ===========
; =========================================================

; --- Window Titles (exact match; use Window Spy to confirm) ---
g_CemuTitle      := "Cemu 2.6"        ; Primary game window title
g_GamepadTitle   := "GamePad View"    ; Secondary gamepad/second-screen window title

; --- Primary window client size target (width x height) ---
g_PrimaryClientW := 1920
g_PrimaryClientH := 1080

; --- Layout Offsets / Gaps ---
; For primary Cemu window (vertical gap near taskbar):
;   Positive = space ABOVE the taskbar; Negative = overlap a few px INTO taskbar.
g_PrimaryBottomGap := -7

; For GamePad window placement relative to the Cemu window:
g_GamepadTopOffset := 75    ; pixels down from Cemu’s TOP edge (vertical offset)
g_GamepadSideGap   := -15   ; horizontal gap from Cemu’s RIGHT edge (negative overlaps a bit)

; --- GamePad client aspect ratio ---
g_AspectW := 16
g_AspectH := 9

; --- Scope hotkeys to Cemu only? ---
g_ScopeToCemu := true       ; when true, hotkeys do nothing unless Cemu is active

; --- Hotkeys (strings) ---
; Examples:
;   "#Enter" = Win+Enter
;   "#="     = Win+=
;   "#+g"    = Win+Shift+G
g_HK_MainSnap     := "#Enter"   ; Set primary client to g_PrimaryClientW x g_PrimaryClientH and bottom-center
g_HK_MainPrompt   := "#="       ; Prompt for primary client size, then bottom-center
g_HK_PlaceGamepad := "#+g"      ; Place GamePad window to the right of Cemu at 16:9 with top offset

; =========================================================
; ===============        HOTKEY BINDINGS        ===========
; =========================================================

; Bind hotkeys using config strings. Handlers enforce optional scoping.
Hotkey(g_HK_MainSnap,     (*) => Do_MainSnap())
Hotkey(g_HK_MainPrompt,   (*) => Do_MainPrompt())
Hotkey(g_HK_PlaceGamepad, (*) => Do_PlaceGamepad())

; =========================================================
; ===============       HOTKEY HANDLERS         ===========
; =========================================================

Do_MainSnap() {
    global g_ScopeToCemu, g_CemuTitle, g_PrimaryClientW, g_PrimaryClientH
    if (g_ScopeToCemu && !WinActive(g_CemuTitle))
        return
    SetClientSizeAndSnap(g_CemuTitle, g_PrimaryClientW, g_PrimaryClientH)
}

Do_MainPrompt() {
    global g_ScopeToCemu, g_CemuTitle
    if (g_ScopeToCemu && !WinActive(g_CemuTitle))
        return
    PromptClientSizeAndSnap(g_CemuTitle)
}

Do_PlaceGamepad() {
    global g_ScopeToCemu, g_CemuTitle, g_GamepadTitle, g_GamepadTopOffset
    global g_AspectW, g_AspectH, g_GamepadSideGap
    if (g_ScopeToCemu && !WinActive(g_CemuTitle))
        return
    PlaceGamepadRightOfCemuTopOffset(g_CemuTitle, g_GamepadTitle, g_GamepadTopOffset, g_AspectW, g_AspectH, g_GamepadSideGap)
}

; =========================================================
; ===============          FUNCTIONS            ===========
; =========================================================

PromptClientSizeAndSnap(winTitle) {
    ; Prefill with current CLIENT size
    WinGetClientPos &cx, &cy, &cw, &ch, winTitle
    ibw := InputBox("Target CLIENT width (px):",  "Resize (Client Area)", "w220 h120", cw)
    if ibw.Result != "OK"
        return
    ibh := InputBox("Target CLIENT height (px):", "Resize (Client Area)", "w220 h120", ch)
    if ibh.Result != "OK"
        return
    SetClientSizeAndSnap(winTitle, Integer(ibw.Value), Integer(ibh.Value))
}

SetClientSizeAndSnap(winTitle, targetClientW, targetClientH) {
    if !WinExist(winTitle)
        return

    ; Compute chrome deltas so client becomes exact size
    WinGetPos &x, &y, &ow, &oh, winTitle
    WinGetClientPos &cx, &cy, &cw, &ch, winTitle
    deltaW := ow - cw               ; left + right borders
    deltaH := oh - ch               ; title/menu + top/bottom borders

    newOuterW := targetClientW + deltaW
    newOuterH := targetClientH + deltaH

    ; Bottom-center in the monitor’s work area
    mon := GetMonitorIndexFromWindow(winTitle)
    MonitorGetWorkArea mon, &L, &T, &R, &B

    global g_PrimaryBottomGap
    posX := L + Floor(((R - L) - newOuterW) / 2)
    posY := B - newOuterH - g_PrimaryBottomGap
    if (posY < T)
        posY := T

    WinMove posX, posY, newOuterW, newOuterH, winTitle
}

; Place "GamePad View" right of Cemu with a top offset; keep 16:9 CLIENT; shrink if necessary
PlaceGamepadRightOfCemuTopOffset(cemuTitle, gpTitle, topOffset := 100, aspectW := 16, aspectH := 9, sideGap := 0) {
    if !(WinExist(cemuTitle) && WinExist(gpTitle))
        return

    ; Cemu rectangle
    WinGetPos &cx, &cy, &cw, &ch, cemuTitle
    cemuRight := cx + cw

    ; Work area on Cemu’s monitor
    mon := GetMonitorIndexFromWindow(cemuTitle)
    MonitorGetWorkArea mon, &L, &T, &R, &B

    ; Available width to the right (respect sideGap)
    availOuterW := R - (cemuRight + sideGap)
    if (availOuterW <= 0)
        return

    ; GamePad chrome deltas
    WinGetPos &gx, &gy, &gow, &goh, gpTitle
    WinGetClientPos &gcx, &gcy, &gcw, &gch, gpTitle
    deltaW := gow - gcw
    deltaH := goh - gch

    ; Use all available width (minus chrome) and compute 16:9 client height
    targetClientW := Max(1, availOuterW - deltaW)
    targetClientH := Floor(targetClientW * aspectH / aspectW)
    newOuterW := targetClientW + deltaW
    newOuterH := targetClientH + deltaH

    ; Position with top offset from Cemu’s top
    posX := cemuRight + sideGap
    posY := cy + topOffset
    if (posY < T)
        posY := T

    ; If it would run off bottom, shrink to fit while preserving 16:9
    if (posY + newOuterH > B) {
        availOuterH := B - posY
        if (availOuterH <= 0)
            return
        targetClientH := Max(1, availOuterH - deltaH)
        targetClientW := Floor(targetClientH * aspectW / aspectH)
        newOuterW := targetClientW + deltaW
        newOuterH := targetClientH + deltaH
    }

    WinMove posX, posY, newOuterW, newOuterH, gpTitle
}

GetMonitorIndexFromWindow(winTitle) {
    WinGetPos &x, &y, &w, &h, winTitle
    cx := x + w // 2
    cy := y + h // 2
    count := MonitorGetCount()
    loop count {
        i := A_Index
        MonitorGetWorkArea i, &L, &T, &R, &B
        if (cx >= L && cx <= R && cy >= T && cy <= B)
            return i
    }
    return 1  ; fallback to primary monitor
}

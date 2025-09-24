# Cemu Window Manager

An AutoHotkey v2 script for automatically positioning and resizing Cemu emulator windows with precision. This tool provides hotkey-based window management specifically designed for multi-monitor setups and high-resolution displays.

## Features

- **Primary Window Management**: Automatically resize the main Cemu window to exact client dimensions (1920x1080 by default)
- **Bottom-Center Positioning**: Places the main window at the bottom-center of your monitor's work area
- **GamePad Window Placement**: Positions the "GamePad View" window to the right of the main Cemu window with proper 16:9 aspect ratio
- **Interactive Resize**: Prompt-based resizing with current dimensions pre-filled
- **Multi-Monitor Support**: Intelligent monitor detection and work area calculation
- **Precise Positioning**: Accounts for window chrome (borders, titlebar) to achieve exact client area dimensions

## Configuration

The script includes extensive configuration options at the top of `cemu.ahk`:

### Window Titles
```autohotkey
g_CemuTitle      := "Cemu 2.6"        ; Main Cemu window title
g_GamepadTitle   := "GamePad View"    ; GamePad window title
```

### Display Settings
```autohotkey
g_PrimaryClientW := 1920               ; Target client width
g_PrimaryClientH := 1080               ; Target client height
g_PrimaryBottomGap := -7               ; Gap from taskbar (negative overlaps)
```

### GamePad Window Settings
```autohotkey
g_GamepadTopOffset := 75               ; Pixels down from main window top
g_GamepadSideGap   := -15              ; Horizontal gap (negative for overlap)
g_AspectW := 16                        ; GamePad aspect ratio width
g_AspectH := 9                         ; GamePad aspect ratio height
```

## Hotkeys

| Hotkey | Function | Description |
|--------|----------|-------------|
| Win+Enter | Main Snap | Resize main window to configured dimensions and position at bottom-center |
| Win+= | Main Prompt | Interactive resize with input dialog |
| Win+Shift+G | Place GamePad | Position GamePad window to the right of main window |

### Hotkey Scoping
Set `g_ScopeToCemu := true` to limit hotkeys to when Cemu is the active window, or `false` to make them global.

## Usage

1. Ensure AutoHotkey v2.0 is installed
2. Update the window titles in the configuration section if your Cemu version differs
3. Adjust target dimensions and positioning offsets as needed
4. Run `cemu.ahk`
5. Launch Cemu and use the configured hotkeys

## Technical Details

### Window Management
- Calculates window chrome dimensions to achieve precise client area sizing
- Handles multi-monitor setups by detecting which monitor contains the window
- Respects monitor work areas to avoid taskbars and other system elements

### GamePad Window Logic
- Automatically calculates available space to the right of the main window
- Maintains 16:9 aspect ratio while maximizing use of available space
- Shrinks vertically if necessary to fit within monitor boundaries

### Error Handling
- Checks for window existence before attempting operations
- Falls back to primary monitor if window position detection fails
- Validates available space before positioning secondary windows

## Requirements

- AutoHotkey v2.0
- Cemu emulator
- Windows operating system

## Customization

All positioning logic, dimensions, and hotkeys can be customized by modifying the configuration section at the top of the script. The modular design allows for easy adaptation to different monitor setups, Cemu versions, or personal preferences.

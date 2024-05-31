; Globals ======================================================================
#SingleInstance, Force ; Replace with new instance if script is running
#Persistent ; Keep script permanently running until terminated
#NoEnv ; Prevent identifying empty variables as potential environment variables
#Warn ; Enable warnings to assist with detecting errors
;#NoTrayIcon ; Disable the tray icon of the script
SendMode, Input ; Method for sending keystrokes and mouse clicks
SetWorkingDir, %A_ScriptDir% ; The current working directory of the script

Application := {Name: "Menu Interface", Version: "0.1"}
Window := {Width: 600, Height: 400, Title: Application.Name}
Navigation := {Label: ["General", "Advanced", "Language", "Theme", "---", "Help", "About"]}
; ==============================================================================

; Auto-Execute =================================================================
Menu, Tray, Icon, Shell32.dll, 174
Menu, Tray, Tip, % Application.Name
Menu, Tray, NoStandard
Menu, Tray, Add, Exit, ExitSub

Gui, +LastFound -Resize +HwndhGui1
Gui, Color, FFFFFF

Gui, Add, Tab2, % " x" -999999 " y" -999999 " w" 0 " h" 0 " -Wrap +Theme vTabControl", % ""

Gui, Tab ; Exclude future controls from any tab control

Gui, Add, Picture, % "x" -999999 " y" -999999 " w" 4 " h" 32 " vpMenuHover +0x4E +HWNDhMenuHover",
Gui, Add, Picture, % "x" 0 " y" 18 " w" 4 " h" 32 " vpMenuSelect +0x4E +HWNDhMenuSelect",

Gui, Font, s9 c808080, Segoe UI ; Set Font Options
Loop, % Navigation.Label.Length() {
	GuiControl,, TabControl, % Navigation.Label[A_Index] "|"
	If (Navigation.Label[A_Index] = "---") {
		Continue
	}
	Gui, Add, Text, % "x" 18 " y" (32*A_Index)-14 " h" 32 " +0x200 gMenuClick vMenuItem" . A_Index, % Navigation.Label[A_Index]
}
Gui, Font ; Reset font options

Gui, Font, s11 c000000, Segoe UI ; Set Font Options
Gui, Add, Text, % "x" 192 " y" 18 " w" (Window.Width-192)-14 " h" 32 " +0x200 vPageTitle", % ""
Gui, Font ; Reset font options

Gui, Add, Picture, % "x" 192 " y" 50 " w" (Window.Width-192)-14 " h" 1 " +0x4E +HWNDhDividerLine",

Gui, Add, Button, % "x" (Window.Width-170)-10 " y" (Window.Height-24)-10 " w" 80 " h" 24 " vButtonOK", % "OK"
Gui, Add, Button, % "x" (Window.Width-80)-10 " y" (Window.Height-24)-10 " w" 80 " h" 24 " vButtonCancel", % "Cancel"

Gui, Tab, 1 ; Future controls are owned by the specified tab
Gui, Add, Checkbox, % "x" 192 " y" 66 " w" (Window.Width-192)-14, % "Checkbox Example"

Gui, Tab, 2 ; Future controls are owned by the specified tab
Gui, Add, ListView, % "x" 192 " y" 66 " w" (Window.Width-192)-14, % "Col1|Col2"
LV_Add("", "ListView", "Example")
LV_ModifyCol()

Gui, Tab, 3 ; Future controls are owned by the specified tab
Gui, Add, MonthCal, % "x" 192 " y" 66

Gui, Tab, 4 ; Future controls are owned by the specified tab
Gui, Add, DateTime, % "x" 192 " y" 66, LongDate

Gui, Tab, 5 ; Future controls are owned by the specified tab
; Skipped

Gui, Tab, 6 ; Future controls are owned by the specified tab
Gui, Add, GroupBox, % "x" 192 " y" 66 " w" (Window.Width-192)-14, % "GroupBox"

Gui, Tab, 7 ; Future controls are owned by the specified tab
Gui, Add, DateTime, % "x" 192 " y" 66, LongDate

Gui, Show, % " w" Window.Width " h" Window.Height, % Window.Title

GoSub, OnLoad
return ; End automatic execution
; ==============================================================================

; Labels =======================================================================
OnLoad:
	SetPixelColor("CCEEFF", hMenuHover)
	SetPixelColor("3399FF", hMenuSelect)
	SetPixelColor("D8D8D8", hDividerLine)
	SelectMenu("MenuItem1")
	OnMessage(0x200, "WM_MOUSEMOVE")
return

MenuClick:
	SelectMenu(A_GuiControl)
return

GuiEscape:
GuiClose:
ButtonOK:
ButtonCancel:
ExitSub:
	ExitApp ; Terminate the script unconditionally
return
; ==============================================================================

; Functions ====================================================================
SelectMenu(Control) {
	Global

	CurrentMenu := Control

	Loop, % Navigation.Label.Length() {
		SetControlColor("808080", Navigation.Label[A_Index])
	}

	SetControlColor("000000", Control)
	GuiControl, Move, pMenuSelect, % "x" 0 " y" (32*SubStr(Control, 9, 2))-14 " w" 4 " h" 32
	GuiControl, Choose, TabControl, % SubStr(Control, 9, 2)
	GuiControl,, PageTitle, % Navigation.Label[SubStr(Control, 9, 2)]
}

WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
	Global

	If (InStr(A_GuiControl, "MenuItem") = true && A_GuiControl != CurrentMenu) {
		GuiControl, Move, pMenuHover, % "x" 0 " y" (32*SubStr(A_GuiControl, 9, 2))-14 " w" 4 " h" 32
	} Else If (InStr(A_GuiControl, "MenuItem") = false || A_GuiControl = CurrentMenu) {
		GuiControl, Move, pMenuHover, % "x" -999999 " y" -999999 " w" 4 " h" 32
	}
}

SetControlColor(Color, Control) {
	Global

	GuiControl, % "+c" Color, % Control

	; Required due to redrawing issue with Tab2 control
	GuiControlGet, ControlText,, % Control
	GuiControlGet, ControlHandle, Hwnd, % Control
	DllCall("SetWindowText", "Ptr", ControlHandle, "Str", ControlText)
}

SetPixelColor(Color, Handle) {
	VarSetCapacity(BMBITS, 4, 0), Numput("0x" . Color, &BMBITS, 0, "UInt")
	hBM := DllCall("Gdi32.dll\CreateBitmap", Int, 1, Int, 1, UInt, 1, UInt, 24, Ptr, 0)
	hBM := DllCall("User32.dll\CopyImage", Ptr, hBM, UInt, 0, Int, 0, Int, 0, UInt, 0x2008)
	DllCall("Gdi32.dll\SetBitmapBits", Ptr, hBM, UInt, 3, Ptr, &BMBITS)
	return DllCall("User32.dll\SendMessage", Ptr, Handle, UInt, 0x172, Ptr, 0, Ptr, hBM)
}
; ==============================================================================
; Tooltip Window Spy
; Toggle with CapsLock
;

#NoEnv
; #NoTrayIcon
; #SingleInstance Ignore
	#SingleInstance Force
; #Include, Toolblox.ahk
Menu, Tray, Icon, toolbox1.ico
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
CoordMode, Pixel, Screen

Status = 1
Gui, +Owner +Border +LastFound -Caption +AlwaysOnTop hwndhGui ; Resize 
Gui, Margin, 2, 2
Gui, Color, 2B2B2C, 444444
Gui +LastFound
Gui, Font, s7 q4, Arial
Gui, Add, Edit, w30 r3 Background444444 -E0x200 cFCFCFC ReadOnly -Wrap vCtrl_Title
Gui, Add, Edit, w314 r4 Background444444 -E0x200 cFCFCFC ReadOnly vCtrl_MousePos
Gui, Add, Edit, w318 r4 Background444444 -E0x200 cFCFCFC ReadOnly vCtrl_Ctrl
GetClientSize(hGui, temp)
horzMargin := temp*96//A_ScreenDPI - 320
Gui, Show, Hide w220 h150
return


CapsLock::						
	If !GetKeyState("CapsLock","T") {
		SetCapsLockState, On
		SetTimer, Update, 250
		SetTimer, MouseUpdate, 20
	} Else {			
		SetCapsLockState, Off
		SetTimer, Update, Off
		SetTimer, MouseUpdate, Off
		Gui, Show, Hide
	}
Return



MouseUpdate:
CoordMode, Mouse, Screen
MouseGetPos, msX, msY, msWin, msCtrl
msX2 := msX + 18,  msY2 := msY + 18
; If (Status = 1) {
	If ((msY > 1200) && (msX < 2200)) {
		msY2 := msY - 240
	} Else If ((msX > 2200) && (msY < 1200)) {
		msX2 := msX - 340
	} Else If ((msX > 2200) && (msY > 1200)) {
		msX2 := msX - 340
		msY2 := msY - 240
	}
Gui, Show, x%msX2% y%msY2% NoActivate
; }

Return


GuiSize:
Gui %hGui%:Default
if !horzMargin
	return
SetTimer, Update, % A_EventInfo=1 ? "Off" : "On" ; Suspend on minimize
ctrlW := A_GuiWidth - horzMargin
list = Title,MousePos,MouseCur,Pos,SBText,VisText,AllText,Freeze
Loop, Parse, list, `,
	GuiControl, Move, Ctrl_%A_LoopField%, w%ctrlW%
return

Update:
Gui %hGui%:Default
GuiControlGet, Ctrl_FollowMouse
actWin := WinExist("A")
curWin := msWin
curCtrl := msCtrl
WinExist("ahk_id " curWin)
WinGetTitle, t1
WinGetClass, t2
WinGet, t3, ProcessName
GuiControl,, Ctrl_Title, % t1 "`nahk_class " t2 "`nahk_exe " t3
CoordMode, Mouse, Relative
MouseGetPos, mrX, mrY
CoordMode, Mouse, Client
MouseGetPos, mcX, mcY
PixelGetColor, mClr, %msX%, %msY%, RGB
mClr := SubStr(mClr, 3)
GuiControl,, Ctrl_MousePos, % "Screen:`t" msX ", " msY " `nWindow:`t" mrX ", " mrY " `nClient:`t" mcX ", " mcY " "
	. "`nColor:`t" mClr " (Red=" SubStr(mClr, 1, 2) " Green=" SubStr(mClr, 3, 2) " Blue=" SubStr(mClr, 5) ")"
GuiControl,, Ctrl_CtrlLabel, % (Ctrl_FollowMouse ? txtMouseCtrl : txtFocusCtrl) ":"
if (curCtrl)
{
	ControlGetText, ctrlTxt, %curCtrl%
	cText := "ClassNN:`t" curCtrl "`nText:`t" textMangle(ctrlTxt)
    ControlGetPos cX, cY, cW, cH, %curCtrl%
    cText .= "`n`tx: " cX "`ty: " cY "`tw: " cW "`th: " cH
    WinToClient(curWin, cX, cY)
	ControlGet, curCtrlHwnd, Hwnd,, % curCtrl
    GetClientSize(curCtrlHwnd, cW, cH)
    cText .= "`nClient:`tx: " cX "`ty: " cY "`tw: " cW "`th: " cH
}
else
	cText := ""
GuiControl,, Ctrl_Ctrl, % cText
WinGetPos, wX, wY, wW, wH
GetClientSize(curWin, wcW, wcH)
GuiControl,, Ctrl_Pos, % "`tx: " wX "`ty: " wY "`tw: " wW "`th: " wH "`nClient:`t`t`tw: " wcW "`th: " wcH
return

GuiClose:
ExitApp


GetClientSize(hWnd, ByRef w := "", ByRef h := "")
{
	VarSetCapacity(rect, 16)
	DllCall("GetClientRect", "ptr", hWnd, "ptr", &rect)
	w := NumGet(rect, 8, "int")
	h := NumGet(rect, 12, "int")
}

WinToClient(hWnd, ByRef x, ByRef y)
{
    WinGetPos wX, wY,,, ahk_id %hWnd%
    x += wX, y += wY
    VarSetCapacity(pt, 8), NumPut(y, NumPut(x, pt, "int"), "int")
    if !DllCall("ScreenToClient", "ptr", hWnd, "ptr", &pt)
        return false
    x := NumGet(pt, 0, "int"), y := NumGet(pt, 4, "int")
    return true
}

textMangle(x)
{
	if pos := InStr(x, "`n")
		x := SubStr(x, 1, pos-1), elli := true
	if StrLen(x) > 40
	{
		StringLeft, x, x, 40
		elli := true
	}
	if elli
		x .= " (...)"
	return x
}

~*Ctrl::
~*Shift::
SetTimer, Update, Off
; GuiControl, %hGui%:, Ctrl_Freeze, % txtFrozen
return

~*Ctrl up::
~*Shift up::
SetTimer, Update, On
return

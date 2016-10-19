;;; VSC-ctrl-drag-copy.ahk

/*
#*------v NOTES v------
.SYNOPSIS
VSC-ctrl-drag-copy.ahk - Ctrl+LMouse-click drag copy support for Visual Studio Code.
.NOTES
Written By: Todd Kadrie
Website:	http://tinstoys.blogspot.com
Twitter:	http://twitter.com/tostka

Change Log
;;; 10:33 AM 10/19/2016 pretty buggy - sometimes it works fine, sometimes not. Definitaly a work in progress.
;;; 8:52 AM 10/18/2016 added hs VSC-ctrl-drag: ctrl+lmouse drag copy for Visual Studio Code (leverages getselectedtext())

.DESCRIPTION
Goal: As of this time (10/18/2016) VSC doesn't support copying selected text, by 
holding down the Ctrl key and dragging the cursor to a 'paste' location. 
In a vast number of apps (PowershellISE, WinWord, notepad++, notepad2 etc), this is a standard mouse shortcut. 
I don't doubt there's a native VisualStudioCode keybinding etc, or extension to do this, but I wanted something quickly today.
So I quickly slapped this together. Not a lot of testing, but it seems to work for me in VSC v1.6.1.
*----------^ #*/

;;; #*------v hs VSC-ctrl-drag v------
;;; 8:35 AM 10/18/2016 take a stab at adding ctrl-lmouse-drag text copy to vsc
;;; sometimes it works, sometimes not, flakey at best. 
;;;ahk_class Chrome_WidgetWin_1
#IfWinActive ahk_class Chrome_WidgetWin_1
LCtrl & LButton UP::
	ToolTip, VSC Ctrl+Drag Copy
	SetTimer, RemoveToolTip, 2000
	;;; not working consist, prepurge cb
	Clipboard := "" ;
	selection := GetSelectedText()
	MouseClick, left ;;click at the current mouse pos:
	;;MsgBox, CB contains: %selection%
	;; paste cb
	;;SendInput, ^v
	;;; send the cb vari seems to work more consistently
	;;Send %selection%
	;;; above problematic even swaps wins and starts dumping wrong wins
	SendInput ^{Insert} ; 
	;;; try the slow char-by-char approach
	/*SetKeyDelay, 50, 50 ; Adjust the speed of character sending here. 30, 30 is faster than 50, 50, but is also less reliable since the window may not respond to faster keystrokes. The number is in milliseconds (1/1000 of a second).
	Loop, Read, Selection 
	{
		Send {RAW}%A_LoopReadLine% ; This will send the current line contents one character at a time.
		Send `r`n ; This will send the "enter" keypress after each line.
	} */
return
#IfWinActive ;;;ahk_class Chrome_WidgetWin_1
;;; #*------^ END VSC-ctrl-drag ^------

;;; supporting function:
;;;#*------v Function GetSelectedText() v------
;;; 9:07 PM 6/19/2014 generic selection->CB grabber
;;; I haven't found original author attrib, found in thread here: https://autohotkey.com/board/topic/83230-get-selected-text-without-changing-the-clipboard-owner/
;;; example use: 
;;; Win+g = run a search : #g:: Run % "http://www.google.com/search?q=" . GetSelectedText()
;;; Win+O= Run selected text: #o:: Run % GetSelectedText()
GetSelectedText() {
	tmp := ClipboardAll ; save clipboard
	Clipboard := "" ; clear clipboard
	Send, ^c ; simulate Ctrl+C (=selection in clipboard)
	ClipWait, 1 ; wait until clipboard contains data
	selection := Clipboard ; save the content of the clipboard
	Clipboard := tmp ; restore old content of the clipboard
	return (selection = "" ? Clipboard : selection)
}
;;;#*------^ END Function GetSelectedText() ^------








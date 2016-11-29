;;; Ecco-Formatting.ahk

/*
#*------v NOTES v------
.SYNOPSIS
Ecco-Formatting.ahk - Autohotkey hotkeys for 'styling' the old Ecco Pro outliner. 
.NOTES
Written By: Todd Kadrie
Website:	http://tinstoys.blogspot.com
Twitter:	http://twitter.com/tostka

Change Log
;;; 1:13 PM 11/29/2016 added: EccoHKeys: styles Ctrl+#, Ctrl+@, Ctrl+$, and sizes: Caps+2, Caps+0, Caps+8

.DESCRIPTION
I'm a heavy user of the old 'Netmanage' Ecco Pro outliner product, which dates back from between the late 90s to the early 2000's. 
At this point, it's still one of the best outliners available. 
But it completely lacks in any modern interface or hotkey support. 
So, it's Autohotkey to the rescue!
These are some quickly slapped hotkey sets targeting mainly the 
Ecco Format/Font & Format/Size menus.
I considered using the Pallette buttons (which I routinely use with a mouse), but found that
Ecco has everything classed together as 'ClassNN:	MauiPowerPal1', with no btn text or other
identifying features to leveage ControlClick. 
The button positions also scale & center as the window expands, providing no static targets for clicks

So, this goes the old slow ugly approach: run the menus!
Not a lot of testing, but it seems to work for me with Ecco Pro 4.0.1(32-bit)
*----------^ #*/

;;; #*------v Function EccoHKeys v------
/*Ecco
ahk_class MauiFrame
ahk_exe ecco32.exe
*/
#IfWinActive ahk_class MauiFrame 
	;; emulate the hotkeys I use for Styles in Word, for formatting
	;; Ctrl+# (Ctrl+shift+3) = Code/Courier New 12
	^#::
		;;; winspy shows all palatte btns are same name/class, go to keystrokes:
		;; FoRmat, Font, Courier : Alt+r, f, c
		Send {lalt down}r f {lalt up} c ;;; set Courier Font
		;;; then set size 12 : foRmat, siZe, 1,1 (skips 10 , then to 12)
		Send {lalt down}r z {lalt up} 1 1 {ENTER} ;;; set 12point
	return
	
	;; Ctrl+@ ((Ctrl+shift+2) = Heading 2/Arial 12 Bold
	^@::
		;; MsgBox, "HEADING2!" ; 
		;; FoRmat, Font, Arial : Alt+r, f, a
		Send {lalt down}r f {lalt up} a ;;; set Arial Font
		;;; then set size 12 : foRmat, siZe, 1,1 (skips 10 , then to 12)
		Send {lalt down}r z {lalt up} 1 1 {ENTER} ;;; set 12point
		;;Send ^b ;;; set bold
		Send {lalt down}r s {lalt up} b ;;; set bold 
	return
	
	;; Ctrl+$ ((Ctrl+shift+4) = Normal/Arial 12 Non-bold
	^$::
		;;  FoRmat, Font, Arial : Alt+r, f, a
		Send {lalt down}r f {lalt up} a ;;; set Arial Font
		;;; then set size 12 : foRmat, siZe, 1,1 (skips 10 , then to 12)
		Send {lalt down}r z {lalt up} 1 1 {ENTER} ;;; set Courier Font
		Send {lalt down}r s {lalt up} p  ;;; set plain: foRmat, Style, Plain ; Alt+r, s,p
	return
	
	;;; should also do font sizes too: 12, 10, 8
	;;; using Capslock & 2, 0 & 8 for 12pt, 10pt & 8pt font
	EcoSz12:
	capslock & 2::	;;; font size 12
		;;; then set size 12 : foRmat, siZe, 1,1 (skips 10 , then to 12)
		Send {lalt down}r z {lalt up} 1 1 {ENTER} ;;; set Courier Font
	return
	EcoSz10:
	capslock & 0::	;;; font size 10
		;;; then set size 10 : foRmat, siZe, 1 
		Send {lalt down}r z {lalt up} 1 {ENTER} ;;; set Courier Font
	return
	capslock & 8::	;;; font size 8
		;;; then set size 8 : foRmat, siZe, 8
		Send {lalt down}r z {lalt up} 8 ;;; set Courier Font
	return
	
#IfWinActive ;;;ahk_class MauiFrame 
;;; #*------^ END Function EccoHKeys ^------








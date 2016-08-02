;;; DocWin.ahk
;;; Variant based on DockWin v0.3 - Save and Restore window positions when docking/undocking (using hotkeys)
;;; Paul Troiano, 6/2014 https://autohotkey.com/board/topic/112113-dockwin-storerecall-window-positions/page-3
;;; updated revision by Todd Kadrie (https://github.com/tostka/Autohotkey)

;;; I've made daily use of my reworked variant of Paul's script for maintaining and autorestoring my multi-monitor desktop layout, and transitioning smoothly between a 3-monitor and laptop-screen-only use (and de-hibernation). The original autohotkey.com forum has been locked, and I have yet to locate an updated thread in which to post this, so I'm posting a copy of my updated version on my GitHub repository.

;;; CORE CHANGES TO PAUL'S ORIGINAL CODE:
;;; * The biggy is to set filtering & matching in the cfg file to include CLASSNAMES - does a much better job of ensuring the correct window is in the correct posistion. 
;;; * Detects state of each window and ensures they end up in 'restore' mode (vs Min or Max) 
;;; * config file is auto-constructed from the local ComputerName, and autocreated within the %A_WorkingDir% (autohotkey script-hosted) dir
;;; * very minor tweak: I use a custom icon spec for it's systray icon.
;;; * and this version includes a trailing MsgBox, to confirm the restore process has completed window rearrangement. 
;;; * Also, the cfg file is automatically loaded after creation/update, for manual editing & review: my version loads with Notepad2.exe, but variant sample is listed for opening via notepad.exe

/* USE:
 A. load the script (DocWin.ahk), via association with the autohotkey.exe (e.g. I run it from a start menu Startup folder shortcut)
 B. Shift+Win+0 (#+0) will prompt to save the current window layout to the "DocWin-[computername].cfg" within the same dir as the DocWin.ahk file.

	 CFG editing notes: 
	 1) You can edit the .cfg file, and use wildcards '*' to specify flexible title string filters:
			Title="Task Coach - C:\usr\home\db\taskcoach-*",x=637,y=449,width=963,height=421,wclass=wxWindowClassNR
	 	Title="* input.txt - Notepad2 (Administrator)",x=918,y=78,width=682,height=792,wclass=Notepad2U
	 2) the z-order (foreground to background desktop 'depth') of the windows is determined by their order in appropriate 'SECTION:' block: Windows listed toward the top of the section will go to the 'back' of the z-order, and those at the bottom of the section will be toward the foreground. E.g. Manage and arrange the order of the window entries in the cfg file to control which windows will be on top. 

 C. Once the cfg file is configured for each variant monitor configuration and Desktop size variant with it's own Section:
		SECTION: Monitors=1,MonitorPrimary=1; Desktop size:0,0,1600,900
 ... the Shift+0 (#0) hotkey will rearrange the current matching windows to the desktop locations and sizes specified in the .cfg file.
*/

;;; revisions; 
;;; 1:36 PM 8/2/2016 cleanedup comments, and added some help info, for public posting
;;; 7:26 AM 5/24/2016: ren sCfgFilePath=>sCfgFilePath
;;; 10:06 AM 2/3/2016: Win+0 (#0::): & Win+Shift+0 (#+0::): Added classname support to .cfg & window identification code - forces 100% matches (avoids matching issues with short-title apps like "Lync" client)
;;; 7:54 AM 2/3/2016 Win&0 (#0::):added win-state restore code to address each possible winstate (instead of blanket restore-all)
;;; Shift+Win+0 (#+0::) 8:04 AM 1/12/2015 add open of the new cfg file in notepad, for hand-editing/tweaking win-match info (add wildcards, trim off items you don't care about etc)
;;; 8:09 AM 10/29/2014 #0::: added  a force to 'Restore' state, to avoid resized maxed window weirdness, replaces forced restore orig code
;;; 8:49 AM 10/29/2014 #+0::added in un-maxing windows before save, to see if they'll store a proper origin, for cmd-window max
;;; 6:55 AM 8/6/2014 add a trailing confirm MsgBox (know it's done)
;;; 6:49 AM 7/31/2014 change cfg file name to match .ahk filename & Computername
;;; 7:57 AM 7/23/2014 tweaked data file to locate at %A_WorkingDir%\DocWin-%pComputerName%.cfg
;;; 7:24 AM 7/14/2014 added icon
;;; 11:23 AM 7/11/2014 tsk initial working version

;#InstallKeybdHook
#SingleInstance, Force
;; 1:must start with
SetTitleMatchMode, 1		
/* SetTitleMatchMode options: 
1: A window's title must start with the specified WinTitle to be a match.
2: A window's title can contain WinTitle anywhere inside it to be a match.
3: A window's title must exactly match WinTitle to be a match.
Regex: uses Regex syntax for all matches (SetTitleMatchMode, RegEx )
*/
SetTitleMatchMode, Fast		;Fast is default
DetectHiddenWindows, off	;Off is default
;;; 4:33 PM 7/22/2014 tsk: custom icon & NoEnv spec
Menu, Tray, Icon, %A_WorkingDir%\ahk-flame-red.ico, 1 
;;MsgBox, A_WorkingDir:%A_WorkingDir%
#NoEnv ; Recommended for performance and compatibility - suppresses retr of E-varis (requires the #)
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CrLf=`r`n
;;; 4:34 PM 7/22/2014 dynamic filename on COMPUTERNAME evari
EnvGet pComputerName,COMPUTERNAME	;;; COMPUTERNAME=LYN-3V6KSY1

;;FileName = c:\usr\home\db\DocWin-%pComputerName%.cfg
sCfgFilePath = %A_WorkingDir%\DocWin-%pComputerName%.cfg
;;; 7:26 AM 5/24/2016: ren sCfgFilePath=>sCfgFilePath

IfNotExist, %sCfgFilePath%
{
	MsgBox, Missing sCfgFilePath!:%sCfgFilePath%
}


;;;#*----------------v Function Win-0 (Restore windows) v----------------
;Win-0 (Restore window positions from file)
#0::
	WinGetActiveTitle, SavedActiveWindow
	ParmVals:="Title x y height width wclass"
	SectionToFind:= SectionHeader()
	SectionFound:= 0

	Loop, Read, %sCfgFilePath%
	{
		if (!SectionFound) 
		{
			;Read through file until correct section found
			If (A_LoopReadLine<>SectionToFind) {
				Continue
			}
		}	  

		;Exit if another section reached
		If ( SectionFound and SubStr(A_LoopReadLine,1,8)="SECTION:") 
		{
			Break
		}

		SectionFound:=1
		;;Win_Title:="", Win_x:=0, Win_y:=0, Win_width:=0, Win_height:=0
		;;; 8:59 AM 2/3/2016 splice in wclass
		Win_Title:="", Win_x:=0, Win_y:=0, Win_width:=0, Win_height:=0, Win_wclass:=0

		Loop, Parse, A_LoopReadLine, CSV 
		{
			EqualPos:=InStr(A_LoopField,"=")
			Var:=SubStr(A_LoopField,1,EqualPos-1)
			Val:=SubStr(A_LoopField,EqualPos+1)
			IfInString, ParmVals, %Var% 
			{
				;Remove any surrounding double quotes (")
				If (SubStr(Val,1,1)=Chr(34)) 
				{
					StringMid, Val, Val, 2, StrLen(Val)-2
				}
				;;; 7:46 AM 2/3/2016 building/stocking Win_Title here
				Win_%Var%:=Val  
			}
		}
		
		;;MsgBox, A_LoopReadLine:%A_LoopReadLine% `n Win_Title:%Win_Title%`n Win_x:%Win_x%`n Win_y:%Win_y%`n Win_width:%Win_width%`n Win_height:%Win_height%`n Win_wclass:%Win_wclass%
		
		;;; this checks for non-zero title from file, and finds existing app win, on Win_Title
		;;If ( (StrLen(Win_Title) > 0) and WinExist(Win_Title) )
		;;; update to find on title & class-match
		If ( (StrLen(Win_Title) > 0) AND (WinExist(Win_Title . "ahk_class" . Win_wclass)) )
		{	

			WinActivate  ; Uses the last found window.

			;;; 7:42 AM 2/3/2016 add code to addr any possible winstate - to avoid windows that 'pop to half max' as soon as you try to drag them.			
			WinGet, iWinState, MinMax, %Win_Title%			
			If (iWinState=1) 
			{
				;;; maximized, restore it
				WinRestore, %Win_Title%
			} 
			else if (iWinState=-1) 
			{
				;;; minimized, restore it
				WinRestore, %Win_Title%
			} 
			else 
			{
				;;; 0='restored', half sized
				;;; already what we need for a resize op
			} ; 
			WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
		} 
		else 
		{
			;;MsgBox, Failed to Match Win_Title:%Win_Title% & Win_wclass:%Win_wclass%
		}

	}

	if (!SectionFound)
	{
		msgbox,,Dock Windows, Section does not exist in %sCfgFilePath% `nLooking for: %SectionToFind%`n`nTo save a new section, use Win-Shift-0 (zero key above letter P on keyboard)
	}

	;Restore window that was active at beginning of script
	WinActivate, %SavedActiveWindow%
	;;; 6:55 AM 8/6/2014 add a trailing confirm (know it's finished)
	MsgBox, ,WinDock.ahk,Windows Restored
RETURN
;;;#*----------------^ END Function Win-0 (Restore windows) ^----------------

;;;#*----------------v Function Win-Shift-0 (Save current windows) v----------------
;Win-Shift-0 (Save current windows to file)
#+0::
	MsgBox, 4,Dock Windows,Save window positions?
	IfMsgBox, NO, Return

	WinGetActiveTitle, SavedActiveWindow

	file := FileOpen(sCfgFilePath, "a")
	if (!IsObject(file))
	{
		MsgBox, Can't open "%sCfgFilePath%" for writing.
		Return
	}

	line:= SectionHeader() . CrLf
	file.Write(line)

	; Loop through all windows on the entire system
	WinGet, id, list,,, Program Manager
	Loop, %id%
	{
		this_id := id%A_Index%
		WinActivate, ahk_id %this_id%
		;;; 8:49 AM 10/29/2014 un-maxing windows before save, to see if they'll store a proper origin, for cmd-window max
		WinGet, maximized, MinMax, 
		if (maximized)
		{
			WinRestore, 
		}
		WinGetPos, x, y, Width, Height, A ;Wintitle
		WinGetClass, this_class, ahk_id %this_id%
		WinGetTitle, this_title, ahk_id %this_id%

		if ( (StrLen(this_title)>0) and (this_title<>"Start") )
		{
			;;line=Title="%this_title%"`,x=%x%`,y=%y%`,width=%width%`,height=%height%`r`n
			;;; 8:44 AM 2/3/2016 splice in class ref as well (better matches)
			line=Title="%this_title%"`,x=%x%`,y=%y%`,width=%width%`,height=%height%,wclass=%this_class%`r`n
			file.Write(line)
		}
	}

	file.write(CrLf)  ;Add blank line after section
	file.Close()

	;;MsgBox, Completed file: %file%
	MsgBox, Completed file: %sCfgFilePath%
	;Restore active window
	WinActivate, %SavedActiveWindow%
	;;; 8:04 AM 1/12/2015 add open of the new cfg file in notepad2

	run, Notepad2.exe %sCfgFilePath%, %A_WorkingDir%, ,notePadPID
	;;run, Notepad.exe %sCfgFilePath%, "%A_WorkingDir%", ,notePadPID
	WinActivate %notePadPID%
RETURN
;;;#*----------------^ END Function Win-Shift-0 (Save current windows ^----------------

;;;#*----------------v Function SectionHeader v----------------
;Create standardized section header for later retrieval
SectionHeader()
{
	SysGet, MonitorCount, MonitorCount
	SysGet, MonitorPrimary, MonitorPrimary
	line=SECTION: Monitors=%MonitorCount%,MonitorPrimary=%MonitorPrimary%

        WinGetPos, x, y, Width, Height, Program Manager
	line:= line . "; Desktop size:" . x . "," . y . "," . width . "," . height

	Return %line%
}
;;;#*----------------^ END Function SectionHeader ^----------------

;<EOF>
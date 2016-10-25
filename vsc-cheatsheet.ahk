;;; vsc-cheatsheet.ahk

/*
#*------v NOTES v------
.SYNOPSIS
vsc-cheatsheet.ahk - Quick`nDirty Autohotkey-based popup reference menu for Visual Studio Code keyboard shortcuts
.NOTES
Written By: Todd Kadrie
Website:	http://tinstoys.blogspot.com
Twitter:	http://twitter.com/tostka

Change Log
;;; 8:28 AM 10/25/2016

.DESCRIPTION
vsc-cheatsheet.ahk - Quick`nDirty Autohotkey-based popup reference menu for Visual Studio Code keyboard shortcuts
configurating AHK is beyond the scope of this script. See https://autohotkey.com/docs/Tutorial.htm for more information
This script leverages an Excel (or other spreadsheet app) exported 'Formatted Text (Space delimited) .PRN file. 
I know you can build fancier dialogs with AHK, but for my purposes, a space-delimted PRN using the Lucida Console
font, gives me a simple way to alighn columns, without wrestling with fancier nested tables & other controls
from AHK. 
To use the script: 
1) Add the functions below to your normal .ahk script. And update the sAHKSdir entry to point to 
    the directory where you store your AHK scripts. 
2) Copy the .csv file to your AHK script dir 
3) Open the included csv file in Excel (or your spreadsheet of choice): 
    a. Select all of the columns and dbl-click on vertical line on the header row, between Col A and Col B. 
        This has the effect of auto-sizing all of the selected columns, fully & neatly displaying the cell contents
    b. Play with he column widths to approximate the layout you want. At the current time, the csv 
        Contains the VSC/Code keyboard shortcuts I want to see. Pretty straight forward stuff
    c. Save-As the spreadsheet, and select 'Formatted Text (Space delimited) (*.prn), give it the name 
        'vsc-cheatsheet.prn'
    d. Then Save-As the spreadsheet again in .xlsx format (or your spreadsheets native format), for future
        editing & changes to your 'menu'
4) Restart your primary autohotkey script. 
5) As written below, the popup dialog is bound to the Capslock & F1 key (CAPS+F1). 
    The dialog can be dismissed by clicking on the Close window.
*----------^ #*/

;;;            ======
;;;#*======^ VSC-RELATED ^======
sAHKSdir :="C:\sc\ahk\ahkscripts\"
;;;*------v hs-vsc-cheatsheet (QuickRef) v------
:!:7VSCm::
capslock & F1::
	tBPFname :=sAHKSdir . "vsc-cheatsheet.prn"
	IfNotExist, %tBPFname%
	{
		MsgBox, Error! missing %tBPFname%!.`n aborting.
	} else {
		FileRead, MyText, %tBPFname%
		;;; create GUI object with Font assigned
		Gui Font,, Lucida Console
		;;Gui Add, Text, HwndhwndStatic, % myText
		Gui Add, Text,, % myText
		;;; 8:31 AM 12/1/2014 plice in a close btn
		Gui, Add, Button, Default, Close
		CoordMode, Mouse, Relative
		Gui, Show
		;;hwnd:=WinExist("ahk_class ^AutoHotkeyGUI$") ;;; 7:46 AM 7/3/2014 click-close is broken, don't use regex even with regex matching...
		hwnd := WinExist("ahk_class AutoHotkeyGUI") ;;; 7:46 AM 7/3/2014 click-close is broken, switch out of regex, works
	}
return
;;;*------^ END hs-vsc-cheatsheet (QuickRef) ^------
;;;#*======^ END VSC-RELATED ^======
;;;            ======
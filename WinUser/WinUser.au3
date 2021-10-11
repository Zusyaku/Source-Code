#cs

WinUser - A portable command line utility for Microsoft Windows
License: BSD-3
Date: 07 March 2021
Copyright (C) 2018-2021 Sofia

#ce


; Define version information.

#pragma compile(FileDescription, WinUser - A command line utility for performing some tasks.)
#pragma compile(ProductName, WinUser)
#pragma compile(ProductVersion, 1.0)
#pragma compile(FileVersion, 1.0.0.0) ; The last parameter is optional.
#pragma compile(LegalCopyright, Copyright © 2018-2021 Sofia (Aka MathInDOS / DimCmd))
#pragma compile(CompanyName, WaifuHype Software (Sofia))

#NoTrayIcon
#pragma compile(Console, True)

; Include basic header files.

#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <TrayConstants.au3>
#include "Include/Console.au3"  	; Console stdout with many other functions
#include "Include/Notify.au3"   	; Notify user using default Windows API and some more functions.
#cs
This two header files work I will think in future.
; #include "Include/Toast.au3"		; Toast like almost same as Notify but it's different position and some more works.
; #include "Include/Bass.au3"			; BASS is a small no more dependencies amazing sound library for quickly playing different sound formats. Note that BASS.dll isn't free for commercial use, it's free for Open Source and Private use.
#ce
#include "Include/Code128Auto.au3"	; Code128Auto is a fine bar code creator library with default Windows dependencies.

Global $Version 	= "1.0"
Global $Nil 		= 0

; This codes start with uint8_t
 
Global $DOS_BLUE	= 0x1
Global $DOS_GREEN	= 0x2
Global $DOS_AQUA	= 0x3
Global $DOS_RED		= 0x4
Global $DOS_PURPLE 	= 0x5
Global $DOS_YELLOW	= 0x6
Global $DOS_WHITE	= 0x7
Global $DOS_DEFAULT = $DOS_WHITE
Global $DOS_GRAY 	= 0x8

; End of DOS colors.

; Light colors using uint8_t so we can put C style "0x" to using hexadecimal.

Global $LIGHT_BLUE 	 = 0x9
Global $LIGHT_GREEN	 = 0x0a
Global $LIGHT_AQUA 	 = 0x0b
Global $LIGHT_RED	 = 0x0c
Global $LIGHT_PURPLE = 0x0d
Global $LIGHT_YELLOW = 0x0e
Global $LIGHT_WHITE	 = 0x0f

; End of LIGHT colors.

; Start the entry point of this program.

Main()

Func Main()
; Let's call cmdline using same NULL pointer as C language gives us.

For $i = 1 To $CmdLine[$Nil]
	Select
		; Ascii Charecters function
		
		Case $CmdLine[$i] == "ascii"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(Chr($CmdLine[$n]))
				Exit
			Next
			
		; Beep function
		
		Case $CmdLine[$i] == "beep"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					Beep($CmdLine[$n], $CmdLine[$p])
					Exit
				Next
			Next
			
			; Binary length function
			
		Case $CmdLine[$i] == "binlen"
			For $n = $i+1 To $CmdLine[$Nil]
				Local $Binary = Binary($CmdLine[$n])
				Print(BinaryLen($Binary))
				Exit
			Next
		
			; Binary To String function 
			
		Case $CmdLine[$i] == "bintostr"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(BinaryToString($CmdLine[$n], $SB_UTF8)) ; UTF-8 supported by cmd, most of UTF-16 is unsupport and if we use it the only "?" question mark come.
				Exit
			Next
				
		; CDTray function (to open and close)
		
		Case $CmdLine[$i] == "cdtray"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					If($CmdLine[$n] == "open") Then
						Local $Drive = DriveGetDrive($DT_CDROM)
						If(@error) Then Print("ERROR: CD device not found.") Exit EndIf
						CDTray($Drive[$p], $CDTRAY_OPEN)
						Exit
					ElseIf($CmdLine[$n] == "close") Then
						For $n = $i+1 To $CmdLine[$Nil]
							Local $Drive = DriveGetDrive($DT_CDROM)
							If(@error) Then Print("ERROR: CD device not found.") Exit EndIf
							CDTray($Drive[$n], $CDTRAY_CLOSED)
							Exit
						Next
					EndIf
				Next
			Next
		
		; Clipget function to print clipboard data on cmd.
			
		Case $CmdLine[$i] == "clipget"
			Print(ClipGet())
			Exit
			
			
		; Color function to set color of every words.
		
		Case $CmdLine[$i] == "color"
			For $n = $i+1 To $CmdLine[$Nil]
				Cout($CmdLine[$n+1], $CmdLine[$n])
				Exit
			Next
		
		; Colortext function is same as DOS color functions.
		
		Case $CmdLine[$i] == "colortext"
			For $n = $i+1 To $Cmdline[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					Switch($CmdLine[$n])
						Case "dosblue"
							Cout($CmdLine[$p], $DOS_BLUE)	; DOSBlue
							Exit
						Case "dosgreen"
							Cout($CmdLine[$p], $DOS_GREEN)	; DOSGreen
							Exit
						Case "dosaqua"
							Cout($CmdLine[$p], $DOS_AQUA)	; DOSAqua
							Exit
						Case "dosred"
							Cout($CmdLine[$p], $DOS_RED)	; DOSRed
							Exit
						Case "dospurple"
							Cout($CmdLine[$p], $DOS_PURPLE)	; DOSPurple
							Exit
						Case "dosyellow"
							Cout($CmdLine[$p], $DOS_YELLOW)	; DOSYellow
							Exit
						Case "doswhite"
							Cout($CmdLine[$p], $DOS_WHITE)	; DOSWhite
							Exit
						Case "dosgray"
							Cout($CmdLine[$p], $DOS_GRAY)	; DOSGray
							Exit
						Case "light-blue"
							Cout($CmdLine[$p], $LIGHT_BLUE)	; Light-blue
							Exit
						Case "light-green"
							Cout($CmdLine[$p], $LIGHT_GREEN); Light-green
							Exit
						Case "light-aqua"
							Cout($CmdLine[$p], $LIGHT_AQUA)	; Light-aqua
							Exit
						Case "light-red"
							Cout($CmdLine[$p], $LIGHT_RED)	; Light-red
							Exit
						Case "light-purple"
							Cout($CmdLine[$p], $LIGHT_PURPLE) ; Light-purple
							Exit
						Case "light-yellow"
							Cout($CmdLine[$p], $LIGHT_YELLOW) ; Light-yellow
							Exit
						Case "light-white"
							Cout($CmdLine[$p], $LIGHT_WHITE)  ; Light-white
							Exit						
					EndSwitch
				Next
			Next
			
		; Clone function same as copy.
		
		Case $CmdLine[$i] == "clone"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					If FileExists($CmdLine[$p]) Then 
						Print("Warning: File already exists. It will overwrite. Press a key to continue...")
						system("pause>nul") ; Huh!! Yes, Batch in here!!!
						FileCopy($CmdLine[$n], $CmdLine[$p], $FC_OVERWRITE+$FC_CREATEPATH)
						Exit
					Else
						FileCopy($CmdLine[$n], $CmdLine[$p], $FC_OVERWRITE+$FC_CREATEPATH)
						Exit
					EndIf
				Next
			Next
		
		; Cosine function to get cosine value.
		
		Case $CmdLine[$i] == "cos"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(Cos($CmdLine[$n]))
				Exit
			Next
		
		; Decimal function to get decimal value.
		
		Case $CmdLine[$i] == "dec"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(Dec($CmdLine[$n]))
				Exit
			Next
			
		; Dircopy function to copy directory from here to there.
		
		Case $CmdLine[$i] == "dircopy"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					If FileExists($CmdLine[$p]) Then
						Print("Warning: Directory exists. Overwrite? Press a key to proceed.")
						system("pause>nul")
						DirCopy($CmdLine[$n], $CmdLine[$p], $FC_OVERWRITE) ; Let's move onn...
						Exit
					Else
						DirCopy($CmdLine[$n], $CmdLine[$p], $FC_OVERWRITE) ; Let's move onn..
						Exit
					EndIf
				Next
			Next
		
		; Dircreate function to create directory.
		
		Case $CmdLine[$i] == "dircreate"
			For $n = $i+1 To $CmdLine[$Nil]
				DirCreate($CmdLine[$n])
				Exit
			Next
			
		; This function is under devolopment.
		
		; Case $CmdLine[$i] == "dirgetsize"
			; For $n = $i+1 To $CmdLine[$Nil]
				; Local $DirSize = Round(DirGetSize($CmdLine[$n], $DIR_EXTENDED)/1024/1024)
				; Print($DirSize)
				; Exit
			; Next
		
		; Dirmove function to move a directory from here to there.
		
		Case $CmdLine[$i] == "dirmove"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					DirMove($CmdLine[$n], $CmdLine[$p], $FC_CREATE+$FC_OVERWRITE)
					Exit
				Next
			Next
		
		; Dirremove function to remove a directory.
		
		Case $CmdLine[$i] == "dirremove"
			For $n = $i+1 To $CmdLine[$Nil]
				DirRemove($CmdLine[$n], $DIR_REMOVE)
				Exit
			Next
		
		; Date function to get exact date.
		
		Case $CmdLine[$i] == "date"
			Print(@MDay & ':' & @Mon & ':' & @Year)
			Exit
		
		; Dalete function to delete file.
		
		Case $CmdLine[$i] == "delete"
			For $n = $i+1 To $CmdLine[$Nil]
				FileDelete($CmdLine[$n])
				Exit
			Next
		
		; Drivefilesys function to get file system type of a specific drive.
		
		Case $CmdLine[$i] == "drivefilesys"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(DriveGetFileSystem($CmdLine[$n]))
				Exit
			Next
		
		; DriveSerial function to get serial value of a drive.
		
		Case $CmdLine[$i] == "driveserial"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(DriveGetSerial($CmdLine[$n]))
				Exit
			Next
		
		; DriveGetType function to get drive type (such as NTFS, FAT32)
		
		Case $CmdLine[$i] == "drivegettype"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(DriveGetType($CmdLine[$n]))
				Exit
			Next
		
		; DriveStat function to get status of a drive.
		
		Case $CmdLine[$i] == "drivestat"
			For $n = $i+1 To $CmdLine[$Nil] ; me again use oh nooo lol
				Print(DriveStatus($CmdLine[$n]))
				Exit
			Next
		
		; DriveSpaceFree function shows you how much free space aviable on a drive. // Wrong MISTAKE
		
		Case $CmdLine[$i] == "drivespacefree"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(DriveSpaceFree($CmdLine[$n]) & " MiB" & @LF)
				Print(DriveSpaceFree($CmdLine[$n])/1024 & " GiB")
				Exit
			Next
			
		; DriveSpaceTotal function to get total space of a drive.
		
		Case $CmdLine[$i] == "drivespacetotal"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(DriveSpaceTotal($CmdLine[$n]) & " MiB" & @LF)
				Print(DriveSpaceTotal($CmdLine[$n])/1024 & " GiB")
				Exit
			Next
		
		; EnvGet function to get info about a enviornment variable information.
		
		Case $CmdLine[$i] == "envget"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(EnvGet($CmdLine[$n]))
				Exit
			Next
			
		; EnvSet function to set environment variable. 
			
		Case $CmdLine[$i] == "envset"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					EnvSet($CmdLine[$n], $CmdLine[$p])
					Exit
				Next
			Next
			
		; EnvUpdate function to refresh enviornment variables.
			
		Case $CmdLine[$i] == "envupdate"
			EnvUpdate()
			Exit
			
		; Execute function to execute a program.
			
		Case $CmdLine[$i] == "execute"
			For $n = $i+1 To $CmdLine[$Nil]
				Run($CmdLine[$n])
				Exit
			Next
			
		; Exp function to calculate exp of a value.
			
		Case $CmdLine[$i] == "exp"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(Exp($CmdLine[$n]))
				Exit
			Next
			
		; FileAttrib to get file attribution info.
		
		Case $CmdLine[$i] == "fileattrib"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(FileGetAttrib($CmdLine[$n]))
				Exit
			Next
			
		; FileSize function to get filesize information.
		
		Case $CmdLine[$i] == "filesize"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(ByteSuffix(FileGetSize($CmdLine[$n])))
				Exit
			Next
			
		; FileMove function to move a file from here to there.
			
		Case $CmdLine[$i] == "filemove"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					FileMove($CmdLine[$n], $CmdLine[$p], $FC_CREATE+$FC_OVERWRITEE)
					Exit
				Next
			Next
			
		; FileRead function to read a file and print stdout on cmd.
		
		Case $CmdLine[$i] == "fileread"
			For $n = $i+1 To $CmdLine[$Nil]
				Local $Open = FileOpen($CmdLine[$n], $FO_READ)
				Print(FileRead($Open))
				FileClose($Open)
				Exit
			Next
		
		; FileReadL function enables you to read a specific line in a file.
		
		Case $CmdLine[$i] == "filereadl"													; So what happens Maruf :P love u too!!
			For	$n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					Local $Open = FileOpen($CmdLine[$n], $FO_READ)
					Print(FileReadLine($CmdLine[$n], $CmdLine[$p]))
					FileClose($CmdLine[$n])
					Exit
				Next
			Next
		
		; FileRecycle to recycle a file.
		
		Case $CmdLine[$i] == "filerecycle"
			For $n = $i+1 To $CmdLine[$Nil]
				FileRecycle($CmdLine[$n])
				Exit
			Next
		
		; FileRecEmt function empty whole recycle bin.
		
		Case $CmdLine[$i] == "filerecemt"
			FileRecycleEmpty(@HomeDrive)
			Exit
			
		; FileSetAttrib function set attbution of a file. (Same as attrib)
		
		Case $CmdLine[$i] == "filesetattrib"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					FileSetAttrib($CmdLine[$n], $CmdLine[$p])
					Exit
				Next
			Next
			
		
		; InfoBox function to print information quickly.
		
		Case $CmdLine[$i] == "infobox"
			For $n = $i+1 To $CmdLine[$Nil]
				For $p = $n+1 To $CmdLine[$Nil]
					MsgBox(64, $CmdLine[$n], $CmdLine[$p])
					Exit
				Next
			Next
		
		; KillProcess function kill a process with force.
		
		Case $CmdLine[$i] == "killprocess"
			For $n = $i+1 To $CmdLine[$Nil]
				If not ProcessExists($Cmdline[$n]) Then
					Print("ERROR: Process not found.")
					Exit
				Else
					While(1)
						If(ProcessExists($CmdLine[$n])) Then
							ProcessClose($CmdLine[$n])
						Else
							Exit
						EndIf
					WEnd
				EndIf
			Next
		
		; LockWS function lock workstation.
		
		Case $CmdLine[$i] == "lockws"
			DllCall("user32.dll", "int", "LockWorkStation")
			Exit
		
		; Log function to calculate log of a value.
		
		Case $CmdLine[$i] == "log"
			For $n = $i+1 To $CmdLine[$Nil]
				Print(Log($CmdLine[$n]))
				Exit
			Next
		
		; MediaPlay function to play music via cmd. (Default supported formats: *.wav, *.mp3) (Based on WinAPI)
		
		Case $CmdLine[$i] == "mediaplay"
			For $n = $i+1 To $CmdLine[$Nil]
				If FileExists($CmdLine[$n]) Then
					Print("Now playing: " & $CmdLine[$n])
					SoundPlay($CmdLine[$n], $Nil+1)
					Exit
				Else
					Print("ERROR: Music not found.")
					Exit
				EndIf
			Next
			
		; MouseGetPos function shows you current position of mouse.
		
		Case $CmdLine[$i] == "mousegetpos"
			Local $position = MouseGetPos()
			Print("X:" & $position[0] & "Y:" & $position[1])
			Exit
		
		; MouseMove function move mouse X and Y coord on screen.
		
		Case $CmdLine[$i] == "mousemove"
			For $x = $i+1 To $CmdLine[$Nil]
				For $y = $x+1 To $CmdLine[$Nil]
					For $n = $y+1 To $CmdLine[$Nil]
						MouseMove($CmdLine[$x], $CmdLine[$y], $CmdLine[$n])
						Exit
					Next
				Next
			Next
		
		; MouseWheelUp function wheel up of mouse without touching mouse wheel.
		
		Case $CmdLine[$i] == "mousewheelup"
			For $speed = $i+1 To $CmdLine[$Nil]
				MouseWheel($MOUSE_WHEEL_UP, $CmdLine[$speed])
				Exit
			Next
			
		; MouseWheelDown function wheel down of mouse without touching mouse wheel.
			
		Case $CmdLine[$i] == "mousewheeldown"
			For $speed = $i+1 To $CmdLine[$Nil]
				MouseWheel($MOUSE_WHEEL_DOWN, $CmdLine[$speed])
				Exit
			Next
			
		; MsgBox function gives a msgbox content via cmd.
		
		Case $CmdLine[$i] == "msgbox"
			For $flag = $i+1 To $CmdLine[$Nil]
				For $title = $flag+1 To $CmdLine[$Nil]
					For $body = $title+1 To $CmdLine[$Nil]
						MsgBox($CmdLine[$flag], $CmdLine[$title], $CmdLine[$body])
						Exit
					Next
				Next
			Next
		
		; Ping function ping a specific [http/https] address until get responce. (Same as ping)
		
		Case $CmdLine[$i] == "ping"
			For $site = $i+1 To $CmdLine[$Nil]
				For $ms = $site+1 To $CmdLine[$Nil]
					Local $pingAdd = Ping($CmdLine[$site], $CmdLine[$ms])
					If($pingAdd) Then
						Print($CmdLine[$site] & " respond in " & $CmdLine[$ms] & " ms")
						Exit
					Else
						Print("An error occured during ping " & $CmdLine[$site] & @LF)
						Exit
					EndIf
				Next
			Next
		
		; ProcessChk function check process whether is stay or not.
		
		Case $CmdLine[$i] == "processchk"
			For $process = $i+1 To $Cmdline[$Nil]
				If(ProcessExists($process)) Then
					Print("EXIST: Process exists.")
					Exit
				Else
					Print("ERROR: Process doesn't exist.")
					Exit
				EndIf
			Next
		
		; ProcessSetPrio function set priority of a process.
		
		Case $CmdLine[$i] == "processsetprio"
			For $process = $i+1 To $CmdLine[$Nil]
				For $prority = $process+1 To $CmdLine[$Nil]
					ProcessSetPriority($CmdLine[$process], $CmdLine[$prority])
					Exit
				Next
			Next
		
		; Random function gives a random value unsigned integer.
		
		Case $CmdLine[$i] == "random"
			For $p = $i+1 To $CmdLine[$Nil]
				For $n = $p+1 To $CmdLine[$Nil]
					Print(Random($CmdLine[$p], $CmdLine[$n], 1))
					Exit
				Next
			Next
		
		; Reboot function to reboot your computer with force.
		
		Case $CmdLine[$i] == "reboot"
			ShutDown(6)
			Exit
			
		; RegAdd function add registry key, calue via cmd. (Same as Reg)
		
		Case $CmdLine[$i] == "regadd"
			For $key = $i+1 To $CmdLine[$Nil]
				For $value = $key+1 To $CmdLine[$Nil]
					For $type = $value+1 To $CmdLine[$Nil]
						For $valueCode = $type+1 To $CmdLine[$Nil]
							RegWrite($CmdLine[$key], $CmdLine[$value], $CmdLine[$type], $Cmdline[$valueCode])
							Exit
						Next
					Next
				Next
			Next
			
		; RegDel function delete registry key, value via cmd. (Same as Reg)
		
		Case $CmdLine[$i] == "regdel"
			For $key = $i+1 To $CmdLine[$Nil]
				For $value = $key+1 To $CmdLine[$Nil]
					RegDelete($CmdLine[$key], $CmdLine[$value])
					Exit
				Next
			Next
		
		; RegRead function read a specific key or value via cmd. (Same as Reg)
		
		Case $CmdLine[$i] == "regread"
			For $key = $i+1 To $CmdLine[$Nil]
				For $value = $key+1 To $CmdLine[$Nil]
					RegRead($CmdLine[$key], $CmdLine[$value])
					Exit
				Next
			Next
			
		; Round function to get round value.
		
		Case $CmdLine[$i] == "round"
			For $p = $i+1 To $CmdLine[$Nil]
				For $n = $p+1 To $CmdLine[$Nil]
					Print(Round($CmdLine[$p], $CmdLine[$n]))
					Exit
				Next
			Next
		
		; Run function is same as execute.
		
		Case $CmdLine[$i] == "run"
			For $program = $i+1 To $CmdLine[$Nil]
				Run($CmdLine[$program])
				Exit
			Next
		
		; Send function to send data on text based aera and automate text typing.
		
		Case $CmdLine[$i] == "send"
			For $text = $i+1 To $CmdLine[$Nil]
				Send($CmdLine[$text])
				Exit
			Next
		
		; SendActive function sendactive of desktop app using class name. (Will remove in next version)
		
		Case $CmdLine[$i] == "sendactive"
			For $class = $i+1 To $CmdLine[$Nil]
				SendKeepActive("[CLASS:" & $CmdLine[$class] & "]")
				Exit
			Next
		
		; ShellExe function same as execute or run.
		
		Case $CmdLine[$i] == "shellexe"
			For $program = $i+1 To $CmdLine[$Nil]
				ShellExecute($CmdLine[$program])
				Exit
			Next
		
		; ShellExeWait function execute a program and wait ultil it close.
		
		Case $CmdLine[$i] == "shellexewait"
			For $program = $i+1 To $CmdLine[$Nil]
				ShellExecuteWait($CmdLine[$program])
				Exit
			Next
		
		; Shutdown function to shutdown computer with force.
		
		Case $CmdLine[$i] == "shutdown"
			ShutDown(1)
			Exit
		
		; Sin function to get sine value.
		
		Case $CmdLine[$i] == "sin"
			For $p = $i+1 To $CmdLine[$Nil]
				Print(Sin($CmdLine[$p]))
				Exit
			Next
		
		; Sleep function to wait as milliseconds.
		
		Case $CmdLine[$i] == "sleep"
			For $p = $i+1 To $CmdLine[$Nil]
				Sleep($CmdLine[$p])
				Exit
			Next
		
		; SoundPlay function same as mediaplay.
		
		Case $CmdLine[$i] == "soundplay"
			For $p = $i+1 To $CmdLine[$Nil]
				SoundPlay($Cmdline[$p], 1)
				Exit
			Next
		
		; Splash function to splash a image in GUI window via cmd.
		
		Case $CmdLine[$i] == "splash"
			For $title = $u+1 To $CmdLine[$Nil]
				For $imagename = $title+1 To $CmdLine[$Nil]
					For $x = $imagename+1 To $CmdLine[$Nil]
						For $y = $x+1 To $CmdLine[$Nil]
							SplashImageOn($CmdLine[$title], $Cmdline[$imagename], $CmdLine[$x], $CmdLine[$y])
							Exit
						Next
					Next
				Next
			Next
		
		; Sqrt function to get Sqrt value.
		
		Case $Cmdline[$i] == "sqrt"
			For $p = $i+1 To $CmdLine[$Nil]
				Print(Sqrt($Cmdline[$p]))
				Exit
			Next
		
		; StrLeft function to left string.
		
		Case $CmdLine[$i] == "strleft"
			For $str = $i+1 To $CmdLine[$Nil]
				For $num = $str+1 To $CmdLine[$Nil]
					Local $string = StringLeft($str, $num)
					Print($CmdLine[$string])
					Exit
				Next
			Next
		
		; StrLen function to get length of a string.
		
		Case $CmdLine[$i] == "strlen"
			For $str = $i+1 To $CmdLine[$Nil]
				Print(StringLen($CmdLine[$str]))
				Exit
			Next
		
		; StrLow function set uppercase to lowercase.
		
		Case $CmdLine[$i] == "strlow"
			For $str = $i+1 To $CmdLine[$Nil]
				Print(StringLower($CmdLine[$str]))
				Exit
			Next
		
		; StrMid function to extract middle string and print on cmd.
		
		Case $CmdLine[$i] == "strmid"
			For $str = $i+1 To $CmdLine[$Nil]
				For $char = $str+1 To $CmdLine[$Nil]
					For $pos = $char+1 To $CmdLine[$Nil]
						Print(StringMid($Cmdline[$str], $CmdLine[$pos], $CmdLine[$char]))
						Exit
					Next
				Next
			Next
		
		; StrRep function to replace string.
		
		Case $CmdLine[$i] == "strrep"
			For $str = $i+1 To $CmdLine[$Nil]
				For $char = $str+1 To $CmdLine[$Nil]
					For $replace = $char+1 To $CmdLine[$Nil]
						Print(StringReplace($CmdLine[$str], $Cmdline[$char], $CmdLine[$replace]))
						Exit
					Next
				Next
			Next
		
		; StrRev function to reverse a string.
		
		Case $CmdLine[$i] == "strrev"
			For $str = $i+1 To $CmdLine[$Nil]
				Print(StringReverse($CmdLine[$str]))
				Exit
			Next
			
		; StrRight function to right string.
		
		Case $CmdLine[$i] == "strright"
			For $str = $i+1 To $CmdLine[$Nil]
				For $char = $str+1 To $CmdLine[$Nil]
					Print(StringRight($CmdLine[$str], $CmdLine[$char]))
					Exit
				Next
			Next
		
		; StrUpr function to give it StringUpperCase.
		
		Case $CmdLine[$i] == "strupr"
			For $str = $i+1 To $CmdLine[$Nil]
				Print(StringUpper($CmdLine[$str]))
				Exit
			Next
			
		Case $CmdLine[$i] == "tan"
			For $p = $i+1 To $CmdLine[$Nil]
				Print(Tan($CmdLine[$p]))
				Exit
			Next
			
		Case $CmdLine[$i] == "tooltip"
			For $body = $i+1 To $CmdLine[$Nil]
				For $title = $body+1 To $CmdLine[$Nil]
					For $x = $title+1 To $CmdLine[$Nil]
						For $y = $x+1 To $CmdLine[$Nil]
							For $sleep = $y+1 To $CmdLine[$Nil]
								ToolTip($CmdLine[$body], $CmdLine[$title], $Cmdline[$x], $CmdLine[$y])
								Sleep($CmdLine[$sleep]) ; Multiply to 1000 to seconds
								Exit
							Next
						Next
					Next
				Next
			Next
						
		Case $CmdLine[$i] == "winminall"
			WinMinimizeAll()
			Exit
			
		
		Case $CmdLine[$i] == "winmaxall"
			WinMinimizeAllUndo()
			Exit
			
			
		; Create bar Code
		Case $CmdLine[$i] == "barcode"
			For $p = $i+1 To $CmdLine[$Nil]
				For $n = $p+1 To $CmdLine[$Nil]
					_Bcode128_GenCode($CmdLine[$p], $CmdLine[$n])
					Exit
				Next
			Next
			
		
		; Notify
		Case $CmdLine[$i] == "notify"
			For $image = $i+1 To $CmdLine[$Nil]
				For $title = $image+1 To $CmdLine[$Nil]
					For $body = $title+1 To $CmdLine[$Nil]
						For $sleep = $body+1 To $CmdLine[$Nil]
							_Notify_Set(Default)
							_Notify_Show($CmdLine[$image], $CmdLine[$title], $CmdLine[$body])
							Sleep($CmdLine[$sleep])
							Exit
						Next
					Next
				Next
			Next
			
		Case $CmdLine[$i] == "speak"
			For $text = $i+1 To $CmdLine[$Nil]
				Dim $obj = ObjCreate("SAPI.SpVoice")
				For $tok in $obj.GetVoices('', '')
					$obj.Speak($CmdLine[$text])
					Exit
				Next
			Next
			
			
		Case $CmdLine[$i] == "--help" Or "/?"
			Print("WinUser - Portable, Multitasking tool for Windows" & @LF & @LF)
			Print("WinUser Version-" & $Version & @LF & "License: BSD-3 Clause" & @LF & "Copyright (C) 2018-2021 Sofia (Aka MathInDOS)" & @LF & @LF)
			Print("Uses" & @LF & @LF)
			Print("ascii [code] - function to print ascii charecters on cmd." & @LF)
			Print("beep [frequency] [duration] - function to enable beep.sys driver to beep." & @LF)
			Print("binlen [binary] - function to get binary length." & @LF)
			Print("bintostr [binary] - function to get binary to string." & @LF)
			Print("cdtray [open|close] - function to open cdtray." & @LF)
			Print("clipget - function to get clipboard data on cmd." & @LF)
			Print("color - function to set color for cmd. (My favorite function ;3)" & @LF)
			Print("colortext - function as same as color but it uses doscolor to print." & @LF)
			Print("clone - function to clone a file from here to there." & @LF)
			Print("cos - function to get cosine value." & @LF)
			Print("dec - function to get decimal value." & @LF)
			Print("dircopy - function to copy directory from here to there." & @LF)
			Print("dircreate - function to create directory." & @LF)
			Print("dirmove - function to move directory from here to there." & @LF)
			Print("dirremove - function to remove a directory." & @LF)
			Print("date - function to get date." & @LF)
			Print("delete - function to delete a file." & @LF)
			Print("drivefilesys - function to get file system." & @LF)
			Print("driveserial - function to get serial of a drive." & @LF) 
			Print("drivespacefree - function to get info about how much free space left." & @LF)
			Print("drivespacetotal - function to get total space of a drive." & @LF)
			Print("envget - function to get info about preset enviornment variable." & @LF)
			Print("envset - function to set enviornment variable." & @LF)
			Print("envupdate - function to refresh enviornment variables." & @LF)
			Print("execute - function to execute file." & @LF)
			Print("exp - function to calculate expression." & @LF)
			Print("fileattrib - function to get file attribute." & @LF)
			Print("filesize - function to get file size as byte suffix." & @LF)
			Print("filemove - function to move file from here to there." & @LF)
			Print("fileread - function to read file data and print them on cmd." & @LF)
			Print("filereadl - function to read specific file line." & @LF)
			Print("filerecycle - function to recycle a file." & @LF)
			Print("filerecemt - function to empty recycle bin." & @LF)
			Print("filesetattrib - function to set attribute to a file." & @LF)
			Print("infobox - function to quickly throw a info box." & @LF)
			Print("killprocess - function to kill a process with force." & @LF)
			Print("lockws - function to lock workstation." & @LF)
			Print("log - function to get log value." & @LF)
			Print("mediaplay - function to play .wav and .mp3 files." & @LF)
			Print("mousegetpos - function to get position of mouse." & @LF)
			Print("mousemove - function to move mouse in X and Y coord." & @LF)
			Print("mousewheelup - function to wheel up mouse without using mouse wheel. ;p" & @LF)
			Print("mousewheeldown - function to wheel down mouse without using mouse wheel." & @LF)
			Print("msgbox - function to throw messagebox from cmd." & @LF)
			Print("ping - function to ping a web address to get data." & @LF)
			Print("processchk - function to check whether process exist or not." & @LF)
			Print("processsetprio - function to set up priority of a specific process." & @LF)
			Print("random - function to get random value." & @LF)
			Print("reboot - function to reboot computer with force." & @LF)
			Print("regadd - function to add regitry value." & @LF)
			Print("regdel - function to delete registry value." & @LF)
			Print("regread - function to read registry value." & @LF)
			Print("round - function to get round value." & @LF)
			Print("run - function to run a program." & @LF)
			Print("send - function to automate keywords typing." & @LF)
			Print("sendactive - function to keep active a program." & @LF)
			Print("shellexe - function as same as run to execute a program using shell." & @LF)
			Print("shellexewait - function to execute and wait until program close." & @LF)
			Print("shutdown - function to shutdown computer with force." & @LF)
			Print("sin - function to get sine value." & @LF)
			Print("sleep - function to sleep timer as milliseconds." & @LF)
			Print("soundplay - function as same mediaplay to play audio (*.wav and *.mp3) sounds." & @LF)
			Print("splash - function to splash a image on a single GUI window via cmd." & @LF)
			Print("sqrt - function to get sqrt value." & @LF)
			Print("strleft - function to string left." & @LF)
			Print("strlen - function to get string length." & @LF)
			Print("strlow - function to set upper case to lower case." & @LF)
			Print("strmid - function to extract number of middle point." & @LF)
			Print("strrep - function to replace one string by another String." & @LF)
			Print("strrev - function to reverse a string." & @LF)
			Print("strright - function to string right." & @LF)
			Print("strupr - function to set lower case to upper case." & @LF)
			Print("tan - function to get tangent value." & @LF)
			Print("tooltip - function to set tooltip on runtime." & @LF)
			Print("winminall - function to minimize all windows." & @LF)
			Print("winmaxall - function to maximize all windows." & @LF)
			Print("barcode - function to generate barcode via cmd." & @LF)
			Print("notify - function to notify user with custom message." & @LF)
			Print("speak - function to speak from cmd." & @LF & @LF)
			Print("Note that WinUser contains a lot of bugs, please feel free to issued them at here." & @LF & "Hope a good day!" & @LF & @LF)
			Exit
						; Switch(
	EndSelect
Next

EndFunc

; Quickly add Print function here.

Func Print($Data)
	Return ConsoleWrite($Data)
EndFunc

; ByteSuffix of data.

Func ByteSuffix($iBytes)
	Local $iIndex = 0, $aArray = [' bytes', ' KiB', ' MiB', ' GiB', ' TiB', ' PiB', ' EiB', ' ZiB', ' YiB']
	While $iBytes > 1023
		$iIndex += 1
		$iBytes /= 1024
	WEnd
	Return Round($iBytes) & $aArray[$iIndex]
EndFunc

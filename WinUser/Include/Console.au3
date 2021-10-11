; #INDEX# =======================================================================================================================
; Title .........: Console
; AutoIt Version : 3.3.8.1+
; Language ......: English
; Description ...: Functions that assist with native consoles.
; Author(s) .....: Janus Thorborg (Shaggi)
; ===============================================================================================================================
#include-once
#include <WinApiError.au3>
#OnAutoItStartRegister "__Console__StartUp"

; #CURRENT# =====================================================================================================================
;Cout
;Cin
;Cerr
;Getch
;system
;RegisterConsoleEvent
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__Console__CreateConsole
;__Console__KillConsole
;__Console__StartUp
;__Console__ShutDown
;__Console__GetStdHandle
;__Console__HandlerRoutine
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
;	Don't touch these.
Global $__Dll_Kernel32, $__Amount__Startup_Console
Global $__Console__hCtrlHandler = 0
Global $_Included_Console = True
; $_bConsole__PrintToStdStreams will cause the output functions to write to autoit's own streams, too.
Global $_bConsole__PrintToStdStreams = False
; ===============================================================================================================================
; #ENUMS# =======================================================================================================================
Global Enum $sigCtrlC = 0, $sigCtrlBreak, $sigCtrlClose, $sigCtrlLogOff = 5, $sigCtrlShutDown = 6
Global Enum $_eWrite = 0, $_eRead, $_eSetCT, $_eGetCM, $_eSetCM
Global Enum $_cOut, $_cIn, $_cErr
; ===============================================================================================================================
; #TABLES# ======================================================================================================================
;   These tables, on startup, get initialized to a table with function pointers and handles.
Global Const $_sfTable[5] = ["WriteConsoleW","ReadConsoleW", "SetConsoleTextAttribute", "GetConsoleMode", "SetConsoleMode"]
Global $_pfTable[5]
Global $__Console__Handlers[2][2]
Global $__CStreams[3]
; ===============================================================================================================================
; #CONSTANTS# ===================================================================================================================
;	Thanks to Matt Diesel (Mat) for writing these down.
; Attributes flags (colors)
; WinCon.h (153 - 160)
Global Const $FOREGROUND_BLUE = 0x0001 ; text color contains blue.
Global Const $FOREGROUND_GREEN = 0x0002 ; text color contains green.
Global Const $FOREGROUND_RED = 0x0004 ; text color contains red.
Global Const $FOREGROUND_INTENSITY = 0x0008 ; text color is intensified.
Global Const $BACKGROUND_BLUE = 0x0010 ; background color contains blue.
Global Const $BACKGROUND_GREEN = 0x0020 ; background color contains green.
Global Const $BACKGROUND_RED = 0x0040 ; background color contains red.
Global Const $BACKGROUND_INTENSITY = 0x0080 ; background color is intensified.
; Attributes flags
; WinCon.h (161 - 169)
Global Const $COMMON_LVB_LEADING_BYTE = 0x0100 ; Leading Byte of DBCS
Global Const $COMMON_LVB_TRAILING_BYTE = 0x0200 ; Trailing Byte of DBCS
Global Const $COMMON_LVB_GRID_HORIZONTAL = 0x0400 ; DBCS: Grid attribute: top horizontal.
Global Const $COMMON_LVB_GRID_LVERTICAL = 0x0800 ; DBCS: Grid attribute: left vertical.
Global Const $COMMON_LVB_GRID_RVERTICAL = 0x1000 ; DBCS: Grid attribute: right vertical.
Global Const $COMMON_LVB_REVERSE_VIDEO = 0x4000 ; DBCS: Reverse fore/back ground attribute.
Global Const $COMMON_LVB_UNDERSCORE = 0x8000 ; DBCS: Underscore.
Global Const $COMMON_LVB_SBCSDBCS = 0x0300 ; SBCS or DBCS flag.
; ===============================================================================================================================
; #STRUCTURES# ==================================================================================================================
; $tag_CONSOLE_SCREEN_BUFFER_INFO
; $tagCHAR_INFO_W
; $tagPSMALL_RECT
; ===============================================================================================================================
;	These are merely provided for convinience, they aren't used (yet)
Global Const $tag_CONSOLE_SCREEN_BUFFER_INFO = "short dwSizeX; short dwSizeY; short dwCursorPositionX;short dwCursorPositionY; word wAttributes;" & _
		"SHORT srWindowLeft; SHORT srWindowRight; SHORT srWindowLeft; SHORT srWindowBottom;" & _
		"short dwMaximumWindowSizeX; short dwMaximumWindowSizeY"
Global Const $tagCHAR_INFO_W = "WCHAR UnicodeChar; WORD Attributes"
Global Const $tagPSMALL_RECT = "SHORT Left; SHORT Right; SHORT Left; SHORT Bottom;"
; ===============================================================================================================================
; #FUNCTION# ====================================================================================================================
; Name...........: system
; Description ...: Invokes the command processor to execute a command. Once the command execution has terminated, the processor
;				   gives the control back to the program, returning an int value, whose interpretation is system-dependent.
; Syntax.........: system($szCommand)
; Parameters ....: $szString      		- A string containing a system command to be executed.
; Return values .: Success              - Depends on command given.
;                  Failure              - Depends on command given.
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 06/08/2012
; Remarks .......: Common use is system("pause") or system("cls").
; Related .......: RunWait
; Link ..........: http://www.cplusplus.com/reference/clibrary/cstdlib/system/
; Example .......: No
; ===============================================================================================================================
Func system($szCommand)
	If $szCommand Then
		If Not $__Amount__Startup_Console Then
			__Console__CreateConsole()
			$__Amount__Startup_Console += 1
		EndIf
		Return RunWait(@ComSpec & " /c " & $szCommand, @ScriptDir, Default, 0x10)
	EndIf
	Return False
EndFunc   ;==>system
; #FUNCTION# ====================================================================================================================
; Name...........: Cout
; Description ...: Writes a UNICODE string to the Standard Output Stream, with optional attributes. Similar to std::cout in C++ and
;					ConsoleWrite().
; Syntax.........: Cout($szString [, $iAttr = -1])
; Parameters ....: $szString      		- A string to write to the Standard Output Stream.
;                  $iAttr             	- If supplied, the function sets the current text attributes to this before writing,
;										  and resets it back to normal after writing. Attributes (Thanks to Matt Diesel (Mat)):
;                                       |FOREGROUND_BLUE - Text color contains blue.
;                                       |FOREGROUND_GREEN - Text color contains green.
;                                       |FOREGROUND_RED - Text color contains red.
;                                       |FOREGROUND_INTENSITY - Text color is intensified.
;                                       |BACKGROUND_BLUE - Background color contains blue.
;                                       |BACKGROUND_GREEN - Background color contains green.
;                                       |BACKGROUND_RED - Background color contains red.
;                                       |BACKGROUND_INTENSITY - Background color is intensified.
;                                         BitOR these together, if more than one attribute is used.
; Return values .: Success              - True
;                  Failure              - False - @error is set and DllCall() @error is kept in @extended.
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 09/07/2011
; Remarks .......:
; Related .......: Cerr
; Link ..........: http://msdn.microsoft.com/en-us/library/ms687401(VS.85).aspx
; Example .......: No
; ===============================================================================================================================
Func Cout($szString, $iAttr = -1)
	If Not $__Amount__Startup_Console Then
		__Console__CreateConsole()
		$__Amount__Startup_Console += 1
	EndIf
	Local $lpBuffer = DllStructCreate("wchar[" & StringLen($szString) + 1 & "]")
	DllStructSetData($lpBuffer, 1, $szString)
	Local $lpNumberOfCharsWritten = 0
	If $_bConsole__PrintToStdStreams Then ConsoleWrite($szString)
	Switch $iAttr
		Case -1
			Local $aResult = DllCallAddress("BOOL", $_pfTable[$_eWrite], _
											"handle", $__CStreams[$_cOut], _
											"ptr", DllStructGetPtr($lpBuffer), _
											"dword", StringLen($szString), _
											"dword*", $lpNumberOfCharsWritten, _
											"ptr", 0)
			Return $aResult[0]
		Case Else
			Local $aResult1 = DllCallAddress("BOOL", $_pfTable[$_eSetCT], _
											 "handle", $__CStreams[$_cOut], "word", $iAttr)

			Local $aResult2 = DllCallAddress("BOOL", $_pfTable[$_eWrite], _
											 "handle", $__CStreams[$_cOut], _
											 "ptr", DllStructGetPtr($lpBuffer), _
											 "dword", StringLen($szString), _
											 "dword*", $lpNumberOfCharsWritten, _
											 "ptr", 0)

			Local $aResult3 = DllCallAddress("BOOL", $_pfTable[$_eSetCT], _
											 "handle", $__CStreams[$_cOut], "word", 0x7)
			Switch $aResult2[0]
				Case 0
					Return SetError(1,@error,False)
				Case Else
					Return (($aResult1[0] <> 0) AND ($aResult3[0] <> 0))
			EndSwitch
	EndSwitch
	Return False
EndFunc   ;==>Cout
; #FUNCTION# ====================================================================================================================
; Name...........: Cerr
; Description ...: Writes a UNICODE string to the Standard Error Stream, with optional attributes. Similar to std::cerr in C++ and
;					ConsoleWriteError().
; Syntax.........: Cerr($szString [, $iAttr = -1])
; Parameters ....: $szString      		- A string to write to the Standard Error Stream.
;                  $iAttr             	- If supplied, the function sets the current text attributes to this before writing,
;										  and resets it back to normal after writing. Attributes (Thanks to Matt Diesel (Mat)):
;                                       |FOREGROUND_BLUE - Text color contains blue.
;                                       |FOREGROUND_GREEN - Text color contains green.
;                                       |FOREGROUND_RED - Text color contains red.
;                                       |FOREGROUND_INTENSITY - Text color is intensified.
;                                       |BACKGROUND_BLUE - Background color contains blue.
;                                       |BACKGROUND_GREEN - Background color contains green.
;                                       |BACKGROUND_RED - Background color contains red.
;                                       |BACKGROUND_INTENSITY - Background color is intensified.
;                                         BitOR these together, if more than one attribute is used.
; Return values .: Success              - True
;                  Failure              - False - @error is set - see @extended for DllCall() @error.
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 09/07/2011
; Remarks .......:
; Related .......: Cout
; Link ..........: http://msdn.microsoft.com/en-us/library/ms687401(VS.85).aspx
; Example .......: No
; ===============================================================================================================================
Func Cerr($szString, $iAttr = -1)
	If Not $__Amount__Startup_Console Then
		__Console__CreateConsole()
		$__Amount__Startup_Console += 1
	EndIf
	Local $lpBuffer = DllStructCreate("wchar[" & StringLen($szString) + 1 & "]")
	DllStructSetData($lpBuffer, 1, $szString)
	Local $lpNumberOfCharsWritten = 0
	If $_bConsole__PrintToStdStreams Then ConsoleWrite($szString)
	Switch $iAttr
		Case -1
			Local $aResult = DllCallAddress("BOOL", $_pfTable[$_eWrite], _
											"handle", $__CStreams[$_cErr], _
											"ptr", DllStructGetPtr($lpBuffer), _
											"dword", StringLen($szString), _
											"dword*", $lpNumberOfCharsWritten, _
											"ptr", 0)
			Return $aResult[0]
		Case Else
			Local $aResult1 = DllCallAddress("BOOL", $_pfTable[$_eSetCT], _
											 "handle", $__CStreams[$_cErr], "word", $iAttr)

			Local $aResult2 = DllCallAddress("BOOL", $_pfTable[$_eWrite], _
											 "handle", $__CStreams[$_cErr], _
											 "ptr", DllStructGetPtr($lpBuffer), _
											 "dword", StringLen($szString), _
											 "dword*", $lpNumberOfCharsWritten, _
											 "ptr", 0)

			Local $aResult3 = DllCallAddress("BOOL", $_pfTable[$_eSetCT], _
											 "handle", $__CStreams[$_cErr], "word", 0x7)
			Switch $aResult2[0]
				Case 0
					Return SetError(1,@error,False)
				Case Else
					Return (($aResult1[0] <> 0) AND ($aResult3[0] <> 0))
			EndSwitch
	EndSwitch
	Return False
EndFunc   ;==>Cerr
; #FUNCTION# ====================================================================================================================
; Name...........: Cin
; Description ...: Retrieves a UNICODE string from the Standard Input Stream, with optional size. Similar to std::cin in C++.
; Syntax.........: Cin(ByRef $szString [, $iSize = 128])
; Parameters ....: $szString      		- A string the content is copied to.
;                  $iSize            	- If supplied, the function sets the maximal size of the characters read to this.
; Return values .: Success              - Actual amount of characters read.
;                  Failure              - False - @error is set and @extended holds DllCall() @error
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 09/07/2011
; Remarks .......: Returns once something has been typed into console AND enter is pressed.
; Related .......: Getch
; Link ..........: http://msdn.microsoft.com/en-us/library/ms684958(VS.85).aspx
; Example .......: No
; ===============================================================================================================================
Func Cin(ByRef $szString, $iSize = 128)
	If Not $__Amount__Startup_Console Then
		__Console__CreateConsole()
		$__Amount__Startup_Console += 1
	EndIf
	Local $lpBuffer = DllStructCreate("wchar[" & $iSize + 3 & "]")
	Local $lpNumberOfCharsRead = 0
	Local $aResult = DllCallAddress("BOOL", $_pfTable[$_eRead], _
									"handle", $__CStreams[$_cIn], _
									"ptr", DllStructGetPtr($lpBuffer), _
									"dword", DllStructGetSize($lpBuffer), _
									"dword*", $lpNumberOfCharsRead, _
									"ptr", 0)
	Select
		Case Not $aResult[0]
			Return SetError(1,@error,False)
		Case Else
			$szString = StringTrimRight(DllStructGetData($lpBuffer, 1),2)
			Return $aResult[4]
	EndSelect
EndFunc   ;==>Cin
; #FUNCTION# ====================================================================================================================
; Name...........: Getch
; Description ...: Retrieves 1 unicode character from the input buffer. Blocks.
; Syntax.........: Getch()
; Parameters ....:
; Return values .: Success              - A single wide character.
;                  Failure              - False and @error is set - see @extended for DllCall() @error.
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 09/07/2011
; Remarks .......: Returns once something has been typed into console. Doesn't work with Esc, arrows or F1-12. Don't use it in
;				   callback events, it will halt the console!
; Related .......: Cin
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func Getch()
	If Not $__Amount__Startup_Console Then
		__Console__CreateConsole()
		$__Amount__Startup_Console += 1
	EndIf
	Local $mode, $Char, $Count, $lpNumberOfCharsRead
	Local $Ret = DllCallAddress("BOOL", $_pfTable[$_eGetCM], _
								"handle",$__CStreams[$_cIn],"dword*",$mode)
	If @Error OR NOT $Ret[0] Then Return SetError(1,@error,False)
	$Mode = $Ret[2]
	$Ret = DllCallAddress("BOOL", $_pfTable[$_eSetCM], _
						  "handle",$__CStreams[$_cIn],"dword",0)
	If @Error OR NOT $Ret[0] Then Return SetError(2,@error,False)
	Local $aResult = DllCallAddress("BOOL", $_pfTable[$_eRead], _
									"handle", $__CStreams[$_cIn], _
									"int*", $Char, _
									"dword", 2, _
									"int*", $lpNumberOfCharsRead, _
									"ptr", 0)
	If @Error OR NOT $aResult[0] Then Return SetError(3,@error,False)
	Local $Return = ChrW($aResult[2])
	$Ret = DllCallAddress("BOOL", $_pfTable[$_eSetCM], _
						  "handle",$__CStreams[$_cIn],"dword",$Mode)
	If @Error OR NOT $Ret[0] Then return SetError(4,@error,False)
	Return $Return
EndFunc ;==>Getch
; #FUNCTION# ====================================================================================================================
; Name...........: RegisterConsoleEvent
; Description ...: Registers a function to be called when a specified signal is emitted from the system.
; Syntax.........: RegisterConsoleEvent($fFunc [, $dwSig = $sigCtrlClose [, $bRegisterExit = True]])
; Parameters ....: $fFunc      			- Either a string with the function name, or a function (only applies to beta).
;                  $dwSig           	- The signal the function is associated with. Can be one of the following values:
;                                       |$sigCtrlC - A CTRL+C signal was received.
;                                       |$sigCtrlBreak - A CTRL+BREAK signal was received.
;                                       |$sigCtrlClose - A signal that the system sends to all processes attached to a console
;														when the user closes the console (either by clicking Close on the console
;														window's window menu, or by clicking the End Task button command
;														from Task Manager).
;                                       |$sigCtrlLogOff - A signal that the system sends to all console processes when a user
;														is logging off. This signal does not indicate which user is logging off,
;														so no assumptions can be made.
;														Note that this signal is received only by services. Interactive
;														applications are terminated at logoff, so they are not present
;														when the system sends this signal.
;                                       |$sigCtrlShutDown - A signal that the system sends when the system is shutting down.
;															Interactive applications are not present by the time the system sends
;															this signal, therefore it can be received only be services in this
;															situation. Services also have their own notification mechanism
;															for shutdown events.
;                  $bRegisterExit       - If true, registers the function to be called OnAutoItExit also.
; Return values .: Success              - True
;                  Failure              - False and @error is set - see @extended for DllCall() @error.
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 18/06/2012
; Remarks .......: Note that if only a function is passed, it is considered to be called on the close event, and the same function
;					is also registrered for normal AutoIt exit, so it gets called no matter what. Currently, there is no way to
;					terminate AutoIt normally (ie. call normal OnExit handlers) on close event, so this must be used in case of
;					something vital that has to be cleaned up on exit.
; Related .......: OnAutoItExitRegister
; Link ..........: http://msdn.microsoft.com/en-us/library/windows/desktop/ms683242(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func RegisterConsoleEvent($fFunc, $dwSig = $sigCtrlClose, $bRegisterExit = True)
	If Not $__Amount__Startup_Console Then
		__Console__CreateConsole()
		$__Amount__Startup_Console += 1
	EndIf
	#cs
		Check bounds in the function table, resize if needed
	#ce
	$nCap = UBound($__Console__Handlers) -1
	$nAmountNeeded = $__Console__Handlers[0][0] + 1
	If $nAmountNeeded > $nCap Then
		ReDim $__Console__Handlers[$nCap + 2][2]
	EndIf
	$__Console__Handlers[0][0] += 1

	#cs
		Has the handler been registrered yet? If not, do it. Else pass.
	#ce
	If NOT $__Console__hCtrlHandler Then
		$__Console__hCtrlHandler = DllCallBackRegister("__Console__HandlerRoutine","bool","dword")
		Local $pCtrlHandler = DllCallBackGetPtr($__Console__hCtrlHandler)
		$aRet = DllCall($__Dll_Kernel32,"bool","SetConsoleCtrlHandler","ptr",$pCtrlHandler,"bool",1)
		If @Error OR NOT $aRet[0] OR _WinApi_GetLastError() Then Return SetError(_WinApi_GetLastError(), @extended, False)
	EndIf

	#cs
		Register the event and the function
	#ce
	$__Console__Handlers[ $__Console__Handlers[0][0] ][0] = $dwSig
	$__Console__Handlers[ $__Console__Handlers[0][0] ][1] = $fFunc

	If $bRegisterExit AND $dwSig = $sigCtrlClose Then OnAutoItExitRegister($fFunc)
	Return True
EndFunc
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Console__HandlerRoutine
; Description ...: A callback called on system-generated signals. Calls any event handlers registrered using RegisterConsoleEvent.
; Syntax.........:  __Console__HandlerRoutine()
; Parameters ....: $dwSig - the generated signal.
; Return values .: None
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 18/06/2012
; ===============================================================================================================================
Func __Console__HandlerRoutine($dwSig)
	Local $fFunc
	For $i = 1 to UBound($__Console__Handlers) - 1
		If $dwSig = $__Console__Handlers[$i][0] AND $__Console__Handlers[$i][1] <> ""  Then
			If VarGetType($__Console__Handlers[$i][1]) = "string" Then ; string name passed
				Call($__Console__Handlers[$i][1])
			ElseIf VarGetType($__Console__Handlers[$i][1]) = "userfunction" Then ; function passed, applies to beta.
				$fFunc = $__Console__Handlers[$i][1]
				$fFunc()
			EndIf
		EndIf
	Next
	__Console__ShutDown()
	Exit
    Return False
EndFunc
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Console_StartUp()
; Description ...: Checks if running under SciTE, if, then executes the script via ShellExecute so own console can be opened.
;				   Exits with the errorcode the executed script did.
; Syntax.........: __Console_StartUp()
; Parameters ....: None
; Return values .: None
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 16/03/2011
; Remarks .......: This function is used internally. Called automatically on AutoIt startup.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Console__StartUp()
	Local $bIsRunningFromScite = StringInStr($CmdLineRaw, "/ErrorStdOut")
	Local $bIsRecursed = Execute(StringLeft($Cmdline[$Cmdline[0]],StringLen("/Console=")))
	If ($bIsRunningFromScite > 0) AND NOT $bIsRecursed Then
		Local $szCommandLine = '"' & @AutoItExe & '" "' & @ScriptFullPath & '" /Console=True'
		ConsoleWrite(@CRLF & "!<Console.au3>:" & @CRLF & @TAB & "Launching process on own..." & @CRLF & "+" & @TAB & "CmdLine:" & $szCommandLine & @CRLF)
		Local $iReturnCode = RunWait($szCommandline)
		ConsoleWrite(@CRLF & ">" & @TAB & @ScriptName & " returned " & $iReturnCode & " (0x" & Hex($iReturnCode, 8) & ")" & @CRLF)
		Exit $iReturnCode
	EndIf
	Global $__Dll_Kernel32 = DllOpen("kernel32.dll")
	OnAutoItExitRegister("__Console__ShutDown")
EndFunc   ;==>__Console_StartUp
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Console_ShutDown()
; Description ...: If a console is present, it detaches and closes any handles opened.
; Syntax.........: __Console_ShutDown()
; Parameters ....: None
; Return values .: None
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 15/03/2011
; Remarks .......: This function is used internally. Called automatically on AutoIt shutdown.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Console__ShutDown()
	If $__Amount__Startup_Console Then
		For $cStream in $__CStreams
			DllCall($__Dll_Kernel32,"BOOL","CloseHandle","handle",$CStream)
		Next
		__Console__KillConsole()
	EndIf
	DllClose($__Dll_Kernel32)
EndFunc   ;==>__Console_ShutDown
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Console_CreateConsole()
; Description ...: Allocates an console, and opens up handles for the three standard streams: Input, Output and Error.
; Syntax.........: __Console_CreateConsole()
; Parameters ....: None
; Return values .: Success              - True
;                  Failure              - False
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 18/06/2012
; Remarks .......: This function is used internally. Called automatically the first time any of the Cin, Cerr or Cout funcs is used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Console__CreateConsole()
	If Not $__Amount__Startup_Console Then
		$__Amount__Startup_Console += 1
		Local $aResult = DllCall($__Dll_Kernel32, "BOOL", "AllocConsole")
		Local $fpTemp, $mKernelHandle = DllCall($__Dll_Kernel32, _
												"HANDLE","GetModuleHandleW", _
												"wstr", "Kernel32.dll")
		If @Error Or NOT $mKernelHandle[0] Then
			Exit(0xF)
		EndIf
		For $i = 0 To 4
			$fpTemp = DllCall($__Dll_Kernel32, _
							  "ptr", "GetProcAddress", _
							  "HANDLE", $mKernelHandle[0], _
							  "str", $_sfTable[$i])
			If @Error Or NOT $fpTemp[0] Then
				Exit(0xF + $i)
			EndIf
			$_pfTable[$i] = $fpTemp[0]
		Next
		$__CStreams[$_cOut] = __Console__GetStdHandle()
		$__CStreams[$_cIn] = __Console__GetStdHandle(-10)
		$__CStreams[$_cErr] = __Console__GetStdHandle(-12)
		Return $aResult[0]
	EndIf
EndFunc   ;==>__Console__CreateConsole
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Console_ShutDown()
; Description ...: Frees the console from the process.
; Syntax.........: __Console_ShutDown()
; Parameters ....: None
; Return values .: None
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 15/03/2011
; Remarks .......: This function is used internally. Called automatically on AutoIt shutdown.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Console__KillConsole()
	Local $aResult = DllCall($__Dll_Kernel32, "BOOL", "FreeConsole")
	Return $aResult[0]
EndFunc   ;==>__Console__KillConsole
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Console_GetStdHandle()
; Description ...: Returns an handle to the desired standard stream.
; Syntax.........: __Console_GetStdHandle()
; Parameters ....: None
; Return values .: Success              - A handle to the stream.
;                  Failure              - 0
; Author ........: Janus Thorborg (Shaggi)
; Modified.......: 15/03/2011
; Remarks .......: This function is used internally. Called automatically the first time any of the Cin, Cerr or Cout funcs is used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Console__GetStdHandle($nStdHandle = -11)
	Local $aResult = DllCall($__Dll_Kernel32, "handle", "GetStdHandle", _
			"dword", $nStdHandle)
	Return $aResult[0]
EndFunc   ;==>__Console__GetStdHandle
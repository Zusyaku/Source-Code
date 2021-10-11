#include-once

; #INDEX# =======================================================================================================================
; Title .........: Code length optimized Code128A/B/C barcode generator
; AutoIt Version : 3.3.12.0
; Description ...: Create a Code128A/B/C optimized barcode from supplied data
; Author(s) .....: David Williams (willichan)
; Dll ...........:
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_Bcode128_GenCode
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__Bcode128_AddChecksum
;__Bcode128_BitmapSetResolution
;__Bcode128_CreateImage
;__Bcode128_DataInit
;__Bcode128_EncodeData
;__Bcode128_GetBars
;__Bcode128_GetBarsFromVal
;__Bcode128_GetNextType
;__Bcode128_GetValue
;__Bcode128_IsPrintable
;__Bcode128_WhichSet
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

#include <GDIPlus.au3>
#include "StringSize.au3"; by Melba23 - http://www.autoitscript.com/forum/topic/114034-stringsize-m23-new-version-16-aug-11/
#include <File.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _Bcode128_GenCode
; Description ...: Creates a Code128A/B/C optimized barcode from supplied data
; Syntax ........: _Bcode128_GenCode($sData[, $sOutFile = Default[, $iDPI = Default[, $fMinBar = Default[, $fBarHeight = Default[,
;                  $iPrintText = Default]]]]])
; Parameters ....: $sData               - A string value to encode into a Code128 barcode
;                  $sOutFile            - [optional] Where to write out the BMP file. Default is to create a random temp file
;                                         0 = Copy to the clipboard (planned, but not yet implemented)
;                                         1 = Create a randomly named temp file (Default)
;                                         String = Write to specified path\filename (assumes valid path and filename)
;                  $iDPI                - [optional] The dots-per-inch setting for the BMP file.  Default is 96
;                  $fMinBar             - [optional] Width of the narrowest bar, in inches (0.01 is the recommended standard for
;                                         most handheld scanners). Default is 0.01 inches
;                  $fBarHeight          - [optional] The height of the barcode, in inches (15% of the width or 0.5 inches
;                                         ,whichever is larger, is the standard according to the GS1-128 specification). Default
;                                         is to automatically calculate according to this standard.
;                  $iPrintText          - [optional] Whether to print the data string under the barcode. Default is True.
; Return values .: String containing the location and name of the BMP file created, or "" if copied to the clipboard.
; Author ........: David E Williams (willichan)
; Modified ......:
; Remarks .......: Invalid characters in $sData will be skipped rather than generating an error
;                  Copying to the clipboard is not yet implemented.  Random temp file will be made instead.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Bcode128_GenCode($sData, $sOutFile = Default, $iDPI = Default, $fMinBar = Default, $fBarHeight = Default, $iPrintText = Default)
	Local $vBarcodeObj[6], $t
	If IsNumber($sOutFile) Then $sOutFile = 1 ;;; *** treat any number like a temp file, in case the user messed up ***
	If ($sOutFile = Default) Or ($sOutFile = 1) Then $sOutFile = _TempFile(@TempDir, "~", ".bmp", 7)
	If $iPrintText = Default Then $iPrintText = True ;print text at bottom of barcode
	If $iDPI = Default Then $iDPI = 96 ;Dots Per Inch used for the image file
	If $fMinBar = Default Then $fMinBar = 0.01 ;Minimum bar width in Inches
	Local $iModWidth = Ceiling($iDPI * $fMinBar) ;Number of Dots per Minimum Bar
	$t = __Bcode128_EncodeData($sData)
	If $iPrintText Then
		$vBarcodeObj[0] = $t[1] ;encoded text
	Else
		$vBarcodeObj[0] = ""
	EndIf
	$vBarcodeObj[5] = $t[0] ;bar encoding
	$vBarcodeObj[1] = $iModWidth
	$vBarcodeObj[2] = $sOutFile
	$vBarcodeObj[3] = $iDPI
	If $fBarHeight = Default Then
		$fBarHeight = ((StringLen($vBarcodeObj[5]) * $iModWidth) / $iDPI) * 0.15
		If $fBarHeight < 0.5 Then $fBarHeight = 0.5
		$fBarHeight = Ceiling($iDPI * $fBarHeight)
	EndIf
	$vBarcodeObj[4] = $fBarHeight
	__Bcode128_CreateImage($vBarcodeObj)
EndFunc   ;==>_Bcode128_GenCode

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_AddChecksum
; Description ...: Updated the checksum for the current code
; Syntax ........: __Bcode128_AddChecksum(Byref $iChecksum, Byref $iC, $sChar, $sType, Byref $aEncoding)
; Parameters ....: $iChecksum           - current checksum
;                  $iC                  - checksum position counter
;                  $sChar               - character to add to the checksum
;                  $sType               - current codeset
;                  $aEncoding           - array of codeset data
; Return values .: None
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_AddChecksum(ByRef $iChecksum, ByRef $iC, $sChar, $sType, ByRef $aEncoding)
	$iC += 1
	$iChecksum += (__Bcode128_GetValue($sChar, $sType, $aEncoding) * $iC)
EndFunc   ;==>__Bcode128_AddChecksum

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_BitmapSetResolution
; Description ...: Sets the resolution of this Bitmap object
; Syntax ........: __Bcode128_BitmapSetResolution($hBitmap, $nDpiX, $nDpiY)
; Parameters ....: $hBitmap - Pointer to the Bitmap object
;                  $nDpiX   - Value that specifies the horizontal resolution in dots per inch.
;                  $nDpiX   - Value that specifies the vertical resolution in dots per inch.
; Return values .: Success  - True
;                  Failure  - False, @error and @extended are set if DllCall failed
; Author ........: UEZ
; Modified ......: funkey, willichan
; Remarks .......:
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/164388-changing-the-dpi-of-a-bmp
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_BitmapSetResolution($hBitmap, $nDpiX, $nDpiY)
	Local $aResult = DllCall($__g_hGDIPDll, "uint", "GdipBitmapSetResolution", "handle", $hBitmap, "float", $nDpiX, "float", $nDpiY)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] = 0
EndFunc   ;==>__Bcode128_BitmapSetResolution

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_CreateImage
; Description ...: converts bar/space data into a BMP
; Syntax ........: __Bcode128_CreateImage(Byref $vBarcodeObj)
; Parameters ....: $vBarcodeObj         - Array containing barcode data
; Return values .: None
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_CreateImage(ByRef $vBarcodeObj)
	Local $i, $cx
	Local Const $iFontMargin = 14
	;;create image
	_GDIPlus_Startup()
	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0((StringLen($vBarcodeObj[5]) + 14) * $vBarcodeObj[1], $vBarcodeObj[4] + $iFontMargin, $GDIP_PXF01INDEXED)
	__Bcode128_BitmapSetResolution($hBitmap, $vBarcodeObj[3], $vBarcodeObj[3])
	Local $sCLSID = _GDIPlus_EncodersGetCLSID("bmp")
	Local $hBmpCtxt = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsSetSmoothingMode($hBmpCtxt, 0)
	_GDIPlus_GraphicsClear($hBmpCtxt, 0xFFFFFFFF)
	;;draw lines
	For $i = 1 To StringLen($vBarcodeObj[5])
		If StringMid($vBarcodeObj[5], $i, 1) = 1 Then
			$cx = (($i - 1) + 7) * $vBarcodeObj[1]
			_GDIPlus_GraphicsFillRect($hBmpCtxt, $cx, 0, $vBarcodeObj[1], $vBarcodeObj[4], 0)
			If @error Then ConsoleWrite("unable to draw bar " & $i & @CRLF)
		EndIf
	Next

	If $vBarcodeObj[0] <> "" Then
		;;add text to bottom
		;Local $hFamily = _GDIPlus_FontFamilyCreate("Arial")
		;Local $hFont = _GDIPlus_FontCreate($hFamily, 8, 0, 3)
		;Local $iFontHeight = _GDIPlus_FontGetHeight($hFont, $hBmpCtxt)
		$i = _StringSize($vBarcodeObj[0], 8, Default, Default, "Arial")
		$cx = ((StringLen($vBarcodeObj[5]) * $vBarcodeObj[1]) / 2) - ($i[2] / 2)
		_GDIPlus_GraphicsDrawString($hBmpCtxt, $vBarcodeObj[0], $cx, $vBarcodeObj[4] + 1, "Arial", 8)
		If @error Then ConsoleWrite("unable to draw text - " & @extended & @CRLF)
	EndIf

	;;save and dispose of image
	_GDIPlus_ImageSaveToFile($hBitmap, $vBarcodeObj[2])
	If @error Then ConsoleWrite("unable to write to file" & $vBarcodeObj[2] & @CRLF)
	_GDIPlus_GraphicsDispose($hBmpCtxt)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_Shutdown()
EndFunc   ;==>__Bcode128_CreateImage

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_DataInit
; Description ...: loads array with coding data
; Syntax ........: __Bcode128_DataInit(Byref $aEncoding)
; Parameters ....: $aEncoding           - variable to fill with coding data array
; Return values .: None
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_DataInit(ByRef $aEncoding)
	;;;Value, Acode, Bcode, Ccode, Bar Pattern
	Local $aEnc[107][5] = [ _
		["0", " ", " ", "00", "11011001100"], _
		["1", "!", "!", "01", "11001101100"], _
		["2", '"', '"', "02", "11001100110"], _
		["3", "#", "#", "03", "10010011000"], _
		["4", "$", "$", "04", "10010001100"], _
		["5", "%", "%", "05", "10001001100"], _
		["6", "&", "&", "06", "10011001000"], _
		["7", "'", "'", "07", "10011000100"], _
		["8", "(", "(", "08", "10001100100"], _
		["9", ")", ")", "09", "11001001000"], _
		["10", "*", "*", "10", "11001000100"], _
		["11", "+", "+", "11", "11000100100"], _
		["12", ",", ",", "12", "10110011100"], _
		["13", "-", "-", "13", "10011011100"], _
		["14", ".", ".", "14", "10011001110"], _
		["15", "/", "/", "15", "10111001100"], _
		["16", "0", "0", "16", "10011101100"], _
		["17", "1", "1", "17", "10011100110"], _
		["18", "2", "2", "18", "11001110010"], _
		["19", "3", "3", "19", "11001011100"], _
		["20", "4", "4", "20", "11001001110"], _
		["21", "5", "5", "21", "11011100100"], _
		["22", "6", "6", "22", "11001110100"], _
		["23", "7", "7", "23", "11101101110"], _
		["24", "8", "8", "24", "11101001100"], _
		["25", "9", "9", "25", "11100101100"], _
		["26", ":", ":", "26", "11100100110"], _
		["27", ";", ";", "27", "11101100100"], _
		["28", "<", "<", "28", "11100110100"], _
		["29", "=", "=", "29", "11100110010"], _
		["30", ">", ">", "30", "11011011000"], _
		["31", "?", "?", "31", "11011000110"], _
		["32", "@", "@", "32", "11000110110"], _
		["33", "A", "A", "33", "10100011000"], _
		["34", "B", "B", "34", "10001011000"], _
		["35", "C", "C", "35", "10001000110"], _
		["36", "D", "D", "36", "10110001000"], _
		["37", "E", "E", "37", "10001101000"], _
		["38", "F", "F", "38", "10001100010"], _
		["39", "G", "G", "39", "11010001000"], _
		["40", "H", "H", "40", "11000101000"], _
		["41", "I", "I", "41", "11000100010"], _
		["42", "J", "J", "42", "10110111000"], _
		["43", "K", "K", "43", "10110001110"], _
		["44", "L", "L", "44", "10001101110"], _
		["45", "M", "M", "45", "10111011000"], _
		["46", "N", "N", "46", "10111000110"], _
		["47", "O", "O", "47", "10001110110"], _
		["48", "P", "P", "48", "11101110110"], _
		["49", "Q", "Q", "49", "11010001110"], _
		["50", "R", "R", "50", "11000101110"], _
		["51", "S", "S", "51", "11011101000"], _
		["52", "T", "T", "52", "11011100010"], _
		["53", "U", "U", "53", "11011101110"], _
		["54", "V", "V", "54", "11101011000"], _
		["55", "W", "W", "55", "11101000110"], _
		["56", "X", "X", "56", "11100010110"], _
		["57", "Y", "Y", "57", "11101101000"], _
		["58", "Z", "Z", "58", "11101100010"], _
		["59", "[", "[", "59", "11100011010"], _
		["60", "\", "\", "60", "11101111010"], _
		["61", "]", "]", "61", "11001000010"], _
		["62", "^", "^", "62", "11110001010"], _
		["63", "_", "_", "63", "10100110000"], _
		["64", Chr(0), "`", "64", "10100001100"], _
		["65", Chr(1), "a", "65", "10010110000"], _
		["66", Chr(2), "b", "66", "10010000110"], _
		["67", Chr(3), "c", "67", "10000101100"], _
		["68", Chr(4), "d", "68", "10000100110"], _
		["69", Chr(5), "e", "69", "10110010000"], _
		["70", Chr(6), "f", "70", "10110000100"], _
		["71", Chr(7), "g", "71", "10011010000"], _
		["72", Chr(8), "h", "72", "10011000010"], _
		["73", Chr(9), "i", "73", "10000110100"], _
		["74", Chr(10), "j", "74", "10000110010"], _
		["75", Chr(11), "k", "75", "11000010010"], _
		["76", Chr(12), "l", "76", "11001010000"], _
		["77", Chr(13), "m", "77", "11110111010"], _
		["78", Chr(14), "n", "78", "11000010100"], _
		["79", Chr(15), "o", "79", "10001111010"], _
		["80", Chr(16), "p", "80", "10100111100"], _
		["81", Chr(17), "q", "81", "10010111100"], _
		["82", Chr(18), "r", "82", "10010011110"], _
		["83", Chr(19), "s", "83", "10111100100"], _
		["84", Chr(20), "t", "84", "10011110100"], _
		["85", Chr(21), "u", "85", "10011110010"], _
		["86", Chr(22), "v", "86", "11110100100"], _
		["87", Chr(23), "w", "87", "11110010100"], _
		["88", Chr(24), "x", "88", "11110010010"], _
		["89", Chr(25), "y", "89", "11011011110"], _
		["90", Chr(26), "z", "90", "11011110110"], _
		["91", Chr(27), "{", "91", "11110110110"], _
		["92", Chr(28), "|", "92", "10101111000"], _
		["93", Chr(29), "}", "93", "10100011110"], _
		["94", Chr(30), "~", "94", "10001011110"], _
		["95", Chr(31), Chr(127), "95", "10111101000"], _
		["96", "Fnc3", "Fnc3", "96", "10111100010"], _
		["97", "Fnc2", "Fnc2", "97", "11110101000"], _
		["98", "Shift B", "Shift A", "98", "11110100010"], _
		["99", "Code C", "Code C", "99", "10111011110"], _
		["100", "Code B", "Fnc 4", "Code B", "10111101110"], _
		["101", "Fnc 4", "Code A", "Code A", "11101011110"], _
		["102", "Fnc 1", "Fnc 1", "Fnc 1", "11110101110"], _
		["103", "Start A", "Start A", "Start A", "11010000100"], _
		["104", "Start B", "Start B", "Start B", "11010010000"], _
		["105", "Start C", "Start C", "Start C", "11010011100"], _
		["106", "Stop", "Stop", "Stop", "1100011101011"] _
		]
	$aEncoding = $aEnc
	$aEnc = 0
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_EncodeData
; Description ...: encodes data into bar/space code for generating barcode
; Syntax ........: __Bcode128_EncodeData($sData)
; Parameters ....: $sData               - data to be converted to a barcode
; Return values .: array contining encoded data
;                      [0] - text for placing at the bottom of the barcode
;                      [1] - bar/space coding to generate barcode
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_EncodeData($sData)
	Local $sType = "" ;Start with no type
	Local $sNextType = ""
	Local $iChecksum = 0
	Local $aReturn[2] = ["", ""]
	Local $iPosition = 0
	Local $t, $iC = 0
	Local $aEncoding
	__Bcode128_DataInit($aEncoding)
	While $iPosition < StringLen($sData)
		$iPosition += 1
		$sNextType = __Bcode128_GetNextType($sData, $iPosition, $sType)
		If $sNextType <> "" Then
			If $sNextType <> $sType Then ;Start code or switch code
				If $aReturn[0] = "" Then $sNextType &= "S"
				Switch $sNextType
					Case "A" ;Change to Code128A
						$aReturn[0] &= __Bcode128_GetBars("Code A", $sType, $aEncoding)
						__Bcode128_AddChecksum($iChecksum, $iC, "Code A", $sType, $aEncoding)
					Case "AS" ;Start Code128A
						$iChecksum = __Bcode128_GetValue("Start A", "A", $aEncoding)
						$aReturn[0] = __Bcode128_GetBars("Start A", "A", $aEncoding)
					Case "B" ;Change to Code128B
						$aReturn[0] &= __Bcode128_GetBars("Code B", $sType, $aEncoding)
						__Bcode128_AddChecksum($iChecksum, $iC, "Code B", $sType, $aEncoding)
					Case "BS" ;Start Code128B
						$iChecksum = __Bcode128_GetValue("Start B", "B", $aEncoding)
						$aReturn[0] = __Bcode128_GetBars("Start B", "B", $aEncoding)
					Case "C" ;Change to Code128C
						$aReturn[0] &= __Bcode128_GetBars("Code C", $sType, $aEncoding)
						__Bcode128_AddChecksum($iChecksum, $iC, "Code C", $sType, $aEncoding)
					Case "CS" ;Start Code128C
						$iChecksum = __Bcode128_GetValue("Start C", "C", $aEncoding)
						$aReturn[0] = __Bcode128_GetBars("Start C", "C", $aEncoding)
				EndSwitch
				$sType = StringLeft($sNextType, 1)
			EndIf
			If $sType = "C" Then
				$t = StringMid($sData, $iPosition, 2)
				$iPosition += 1
			Else
				$t = StringMid($sData, $iPosition, 1)
			EndIf
			$aReturn[0] &= __Bcode128_GetBars($t, $sType, $aEncoding)
			$aReturn[1] &= __Bcode128_IsPrintable($t)
			__Bcode128_AddChecksum($iChecksum, $iC, $t, $sType, $aEncoding)
		EndIf
	WEnd
	$iChecksum = Mod($iChecksum, 103)
	$aReturn[0] &= __Bcode128_GetBarsFromVal($iChecksum, $aEncoding)
	$aReturn[0] &= __Bcode128_GetBarsFromVal(106, $aEncoding)
	Return $aReturn
EndFunc   ;==>__Bcode128_EncodeData

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_GetBars
; Description ...: returns the bar/space coding for a character
; Syntax ........: __Bcode128_GetBars($sChar, $sType, Byref $aEncoding)
; Parameters ....: $sChar               - Character to lookup
;                  $sType               - current characterset
;                  $aEncoding           - array of encoding data
; Return values .: string containing bar/space encoding
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_GetBars($sChar, $sType, ByRef $aEncoding)
	Local $i, $iType
	Switch StringUpper($sType)
		Case "A"
			$iType = 1
		Case "B"
			$iType = 2
		Case "C"
			$iType = 3
		Case Else
			SetError(1, 0, -1)
	EndSwitch
	For $i = 0 to UBound($aEncoding, 1) - 1
		If $aEncoding[$i][$iType] == $sChar Then Return $aEncoding[$i][4]
	Next
	SetError(1, 0, "")
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_GetBarsFromVal
; Description ...: returns the bar/space coding for a codeset value
; Syntax ........: __Bcode128_GetBarsFromVal($iValue, Byref $aEncoding)
; Parameters ....: $iValue              - codeset value to lookup
;                  $aEncoding           - array of encoding data
; Return values .: string containing bar/space encoding
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_GetBarsFromVal($iValue, ByRef $aEncoding)
	Local $i
	For $i = 0 to UBound($aEncoding, 1) - 1
		If $aEncoding[$i][0] = $iValue Then Return $aEncoding[$i][4]
	Next
	SetError(1, 0, -1)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_GetNextType
; Description ...: determines the next codeset to use for an optimized barcode
; Syntax ........: __Bcode128_GetNextType($sData, $iPosition, $sType)
; Parameters ....: $sData               - the data being encoded
;                  $iPosition           - current position being encoded
;                  $sType               - current codeset
; Return values .: string containing the optimum codeset to be used for the next character
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_GetNextType($sData, $iPosition, $sType)
	;Optimizes the generated code lenth
	Local $sSet
	Local $iA = 0
	Local $iB = 0
	Local $iP = 0
	;Check to see if it should be "C"
	If $sType = "C" Then
		If StringRegExp(StringMid($sData, $iPosition, 2), "([0-9][0-9])") = 1 Then Return "C"
	Else
		If StringRegExp(StringMid($sData, $iPosition, 6), "([0-9][0-9]){3}") = 1 Then Return "C"
	EndIf
	;Check "A" or "B"
	$sSet = __Bcode128_WhichSet(StringMid($sData, $iPosition, 1))
	If StringLen($sSet) < 2 Then Return $sSet
	If ($sType = "A") And StringInStr($sSet, "A") Then Return "A"
	If ($sType = "B") And StringInStr($sSet, "B") Then Return "B"
	While 1
		$iP += 1
		If $iPosition + $iP > StringLen($sData) Then ExitLoop
		$sSet = __Bcode128_WhichSet(StringMid($sData, $iPosition + $iP, 1))
		If StringInStr($sSet, "A") Then $iA += 1
		If StringInStr($sSet, "B") Then $iB += 1
		If StringLen($sSet) = 1 Then ExitLoop
	WEnd
	If $iA > $iB Then Return "A"
	Return "B"
EndFunc   ;==>__Bcode128_GetNextType

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_GetValue
; Description ...: returns the codeset value for a character
; Syntax ........: __Bcode128_GetValue($sChar, $sType, Byref $aEncoding)
; Parameters ....: $sChar               - character to lookup
;                  $sType               - current codeset
;                  $aEncoding           - array of encoding data
; Return values .: codeset value of the character
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_GetValue($sChar, $sType, ByRef $aEncoding)
	Local $i, $iType
	Switch StringUpper($sType)
		Case "A"
			$iType = 1
		Case "B"
			$iType = 2
		Case "C"
			$iType = 3
		Case Else
			SetError(1, 0, -1)
	EndSwitch
	For $i = 0 to UBound($aEncoding, 1) - 1
		If $aEncoding[$i][$iType] == $sChar Then Return $aEncoding[$i][0]
	Next
	SetError(1, 0, $aEncoding[0][4])
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_IsPrintable
; Description ...:
; Syntax ........: __Bcode128_IsPrintable($sChar)
; Parameters ....: $sChar               - character to evaluate
; Return values .: printable characters associated with the given character
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_IsPrintable($sChar)
	;eventually add printable forms of non-printable characters, such as <CR>
	If StringLen($sChar) = 2 Then Return $sChar ;it is a double number
	Switch Asc($sChar)
		Case 32 To 126
			Return $sChar
		Case Else
			Return ""
	EndSwitch
EndFunc   ;==>__Bcode128_IsPrintable

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Bcode128_WhichSet
; Description ...: Determines which charactersets the character is valid in (A and B only)
; Syntax ........: __Bcode128_WhichSet($sChar)
; Parameters ....: $sChar               - Character to lookup
; Return values .: string containing the valid codesets
; Author ........: willichan
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Bcode128_WhichSet($sChar)
	If (Not IsString($sChar)) Or (StringLen($sChar) > 1) Then SetError(1, 0, -1)
	Switch Asc($sChar)
		Case 0 To 31
			Return "A"
		Case 32 To 95
			Return "AB"
		Case 96 To 127
			Return "B"
		Case Else
			Return ""
	EndSwitch
EndFunc

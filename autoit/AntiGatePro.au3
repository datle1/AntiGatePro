#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Date.au3>
#include <File.au3>

; Prepare params
$numArgs=$CmdLine[0]
$javaDir=$CmdLine[1]
$pop3ClientPath=$CmdLine[2]
$user=$CmdLine[3]
$pass=StringReverse($CmdLine[4])
$gateProPath=$CmdLine[5]
$fileIp=$CmdLine[6]
$timeoutGetOTP=$CmdLine[7]
$resetAdapter=$CmdLine[8]

$maxNode=3
If ($numArgs = 9) Then
   $maxNode=$CmdLine[9]
EndIf

$cmdGetOTP='java -jar ' & $pop3ClientPath & ' ' & $user & ' "' & $pass & '"'
$EPOCH = "1970/01/01 07:00:00"

;;;;;;;;;;;;;;;;;;;;;;;;;;   MAIN  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Run app
ShellExecute($gateProPath)
WaitForEvent(21, 149, 0xCC0000, False)
sleep(1000)

; Pass java auth
PassJavaAuth()

; wait for login gatepro
WaitForEvent(0, 0, 0x4D4D4D, False)
Sleep(1000)

; login
LoginGatePro()
Sleep(5000)
WaitForShowGatePro()

; Show Search bar
ShowSearchBar()

; Fill ip and open firewall
OpenNode($fileIp)

; End
Exit

;;;;;;;;;;;;;;;;;;;;;;;;;;   FUNCTIONS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func WaitForShowGatePro()
   $hWin = WinGetHandle("[ACTIVE]")
   WinSetState($hWin, "", @SW_SHOW)
   WinSetState($hWin, "", @SW_MAXIMIZE)
   ;WaitForEvent(25, 50, 0xDF8326, False)
   WaitForEvent(33, 130, 0xEDEDED, False)
   Sleep(1000)
EndFunc

Func OpenNode($fileInput)

   $ipList = getIpList($fileInput)
   $count = $maxNode
   If $maxNode = 0 Or $ipList[0] < $maxNode Then
	  $count = $ipList[0]
   EndIf

   For $i = 1 To $count
	  If $ipList[$i] <> "" Then
		 $res = FillIp($ipList[$i])
		 If $res = True Then
			OpenFirewall()
		 EndIf
	  EndIf
   Next

EndFunc

Func getIpList($fileInput)
   ; Open the file for reading and store the handle to a variable.
   $hFileOpen = FileOpen(@ScriptDir & "\" & $fileInput, $FO_READ)
   If $hFileOpen = -1 Then
	 _FileWriteLog(@ScriptDir & "\full.log", "Error reading the file " & @ScriptDir & "\" & $fileInput)
	 Exit
   EndIf

   ; Read the contents of the file using the handle returned by FileOpen.
   $sFileRead = FileRead($hFileOpen)

   ; Close the handle returned by FileOpen.
   FileClose($hFileOpen)

   Return StringSplit($sFileRead, @CRLF, $STR_ENTIRESPLIT)
EndFunc

Func FillIp($ip)
   MouseClick($MOUSE_CLICK_LEFT, 60, 172, 1, 0)
   sleep(500)
   Send("^{a}")
   sleep(500)
   Send($ip)
   sleep(500)
   MouseClick($MOUSE_CLICK_LEFT, 240, 172, 1, 0)
   sleep(3000)

   $y_base = 252

   $iColor = PixelGetColor(75, $y_base)

   MouseMove(75, $y_base, 10)

   if $iColor = 0xFFFFFF Then
	  Return False
   EndIf

   MouseClick($MOUSE_CLICK_LEFT, 75, $y_base, 2, 0)
   sleep(500)
   MouseClick($MOUSE_CLICK_LEFT, 100, $y_base + 16, 2, 0)
   sleep(500)

   $iColor = PixelGetColor(120, $y_base + 31)
   if $iColor > 0x000000 And $iColor < 0x00FFFF Then
	  Return False
   EndIf

   MouseClick($MOUSE_CLICK_LEFT, 120, $y_base + 31, 2, 0)
   sleep(500)
   Return True

EndFunc

Func OpenFirewall()
   $hWnd = WinActivate("Thông tin đóng mở firewall")
   Send("^{tab}")
   Sleep(500)
   Send("{enter}")
   sleep(1000)

   $hCur = WinGetHandle("[ACTIVE]")
   $posArray = WinGetPos($hCur)
   WaitForEvent(@DeskTopWidth/2 - $posArray[0], @DeskTopHeight/2 - $posArray[1], 0xD7D7D7, True)

   sleep(500)
   Send("^{tab}")
   Sleep(500)
   Send("{enter}")
   Sleep(500)
EndFunc

Func ShowSearchBar()
   MouseClick($MOUSE_CLICK_LEFT, 25, 75, 1, 0)
   sleep(2000)
   $hCur = WinGetHandle("[ACTIVE]")
   $posArray = WinGetPos($hCur)
   $iColor = PixelGetColor( $posArray[0] + 79, $posArray[1] + 112, $hCur)
   if $iColor <> 0x8C9CE1 Then
	  MouseClick($MOUSE_CLICK_LEFT, 25, 75, 1, 0)
	  sleep(2000)
   EndIf
EndFunc

Func GetCondition($cond, $a, $b)
   If ($cond = False) Then
	  If ($a = $b) Then
		 Return True
	  EndIf
   Else
	  If ($a <> $b) Then
		 Return True
	  EndIf
   EndIf

   Return False
EndFunc

Func WaitForEvent($x, $y, $color, $isNegative)
   $hCur = WinGetHandle("[ACTIVE]")
   $posArray = WinGetPos($hCur)
   $iColor = PixelGetColor( $posArray[0], $posArray[1], $hCur)
   $count = 0;
   Do
	  Sleep(500)
	  $hCur = WinGetHandle("[ACTIVE]")
	  $posArray = WinGetPos($hCur)
	  $iColor = PixelGetColor($posArray[0] + $x, $posArray[1] + $y, $hCur)
	  $count = $count + 1

	  If Mod($count, 10) = 1 Then
		 _FileWriteLog(@ScriptDir & "\full.log", "Color: expect " & $isNegative & " " & Hex($color, 6) & ", actual " & Hex($iColor, 6) & ", original pos: " & $posArray[0] & "," & $posArray[1] & ", checked pos: " & $posArray[0] + $x & "," & $posArray[1] + $y)
	  EndIf

   Until GetCondition($isNegative, $iColor, $color) Or $count = 360;

   If ($count = 360) Then
	  Exit
   EndIf

EndFunc

Func PassJavaAuth()
   Send("{tab}")
   sleep(500)
   Send("{tab}")
   sleep(500)
   Send("{space}")
   sleep(500)
   Send("{enter}")
   sleep(500)
   Send("{tab}")
   sleep(500)
   Send("{tab}")
   sleep(500)
   Send("{space}")
   sleep(500)
   Send("{enter}")
   sleep(500)
EndFunc

Func LoginGatePro()
   ; fill user/pass
   Send($user)
   sleep(500)
   Send("{tab}")
   sleep(800)
   Send($pass, 1)
   sleep(500)

   ; choice server and tick mail
   $posArray = WinGetPos(WinGetHandle("[ACTIVE]"))
   MouseMove($posArray[0]+$posArray[2]/3*2,$posArray[1]+$posArray[3]/13*6, 10)
   Sleep(500)
   MouseClick($MOUSE_CLICK_LEFT)
   sleep(500)
   MouseMove($posArray[0]+$posArray[2]/3*2,$posArray[1]+$posArray[3]/13*8, 10)
   Sleep(500)
   MouseClick($MOUSE_CLICK_LEFT)
   Sleep(500)
   Send("{tab}")
   sleep(500)
   Send("{space}")
   Sleep(500)
   MouseMove($posArray[0]+$posArray[2]/3*2,$posArray[1]+$posArray[3]/13*7, 10)
   Sleep(500)
   MouseClick($MOUSE_CLICK_LEFT)
   sleep(1000)

   ; get OTP from pop3 client
;   WaitForEvent(74, 46, 0xA30000)
   WaitForEvent(74, 46, 0xF4F4F4, True)
   _FileWriteLog(@ScriptDir & "\full.log", "Sleep: " & $timeoutGetOTP)
   sleep($timeoutGetOTP)
;   $NOW = _NowCalc()
;   $time = _DateDiff("s", $EPOCH, $NOW)
   FileChangeDir($javaDir)
   _FileWriteLog(@ScriptDir & "\full.log", "Run pop3_client at " & $javaDir)
   $pid = Run(@ComSpec & " /c " & $cmdGetOTP, $javaDir, @SW_HIDE, $STDOUT_CHILD)
;   $pid = Run(@ComSpec & " /c " & $cmdGetOTP & " " & $time, $javaDir, @SW_HIDE, $STDOUT_CHILD)
   ProcessWaitClose($pid)
   $sOutput = StdoutRead($pid)
   ;MsgBox(NULL, "", "OTP is: " & $sOutput)
   _FileWriteLog(@ScriptDir & "\full.log", "OTP is: " & $sOutput)

   ; fill OTP and login
   $posArray = WinGetPos(WinGetHandle("[ACTIVE]"))
   MouseMove($posArray[0]+$posArray[2]/3*2,$posArray[1]+$posArray[3]/13*8, 10)
   sleep(500)
   MouseClick($MOUSE_CLICK_LEFT)
   sleep(500)
   Send($sOutput)
   MouseMove($posArray[0]+$posArray[2]/3*2,$posArray[1]+$posArray[3]/13*11, 10)
   Sleep(500)
   MouseClick($MOUSE_CLICK_LEFT)
EndFunc


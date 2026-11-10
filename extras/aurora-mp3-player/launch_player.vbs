Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

appHtml = "C:\Users\User\Tools\AuroraMP3\app\index.html"
fileUrl = "file:///" & Replace(appHtml, "\", "/")

edgePaths = Array( _
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", _
  "C:\Program Files\Microsoft\Edge\Application\msedge.exe", _
  shell.ExpandEnvironmentStrings("%LocalAppData%\Microsoft\Edge\Application\msedge.exe") _
)

' Centered directly under Dynamic Island: 1280x800 resolution -> left: 450, top: 36, width: 380, height: 530
windowW = 380
windowH = 530
windowX = 450
windowY = 36

launched = False
For Each p In edgePaths
  If fso.FileExists(p) Then
    cmd = """" & p & """ --app=""" & fileUrl & """ --window-size=" & windowW & "," & windowH & " --window-position=" & windowX & "," & windowY
    shell.Run cmd, 1, False
    launched = True
    Exit For
  End If
Next

If Not launched Then
  shell.Run """" & appHtml & """", 1, False
End If

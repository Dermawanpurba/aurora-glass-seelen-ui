Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

appHtml = "C:\Users\User\Tools\AuroraMP3\app\index.html"
fileUrl = "file:///" & Replace(appHtml, "\", "/")

edgePaths = Array( _
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", _
  "C:\Program Files\Microsoft\Edge\Application\msedge.exe", _
  shell.ExpandEnvironmentStrings("%LocalAppData%\Microsoft\Edge\Application\msedge.exe") _
)

launched = False
For Each p In edgePaths
  If fso.FileExists(p) Then
    cmd = """" & p & """ --app=""" & fileUrl & """ --window-size=440,680 --window-position=420,48"
    shell.Run cmd, 1, False
    launched = True
    Exit For
  End If
Next

If Not launched Then
  shell.Run """" & appHtml & """", 1, False
End If

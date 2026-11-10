Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Try activating existing window first
If WshShell.AppActivate("Aurora MP3") Then
    WScript.Quit 0
End If

appHtml = WshShell.ExpandEnvironmentStrings("%APPDATA%\com.seelen.seelen-ui\plugins\aurora-mp3-player\app\index.html")
profileDir = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%\AuroraMP3PlayerProfile")
url = "file:///" & Replace(appHtml, "\", "/")

edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
If Not fso.FileExists(edgePath) Then
    edgePath = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
End If

If fso.FileExists(edgePath) Then
    cmd = """" & edgePath & """ --user-data-dir=""" & profileDir & """ --app=""" & url & """ --window-size=460,620 --window-position=410,46"
    WshShell.Run cmd, 1, False
Else
    WshShell.Run """" & appHtml & """", 1, False
End If

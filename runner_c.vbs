Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & "C:\apps\node\node C:\apps\NodeMail\js\emailjs.js" & Chr(34), 0
Set WinScriptHost = Nothing
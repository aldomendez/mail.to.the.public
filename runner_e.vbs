Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & "C:\apps\node\node.exe E:\Avago\NodeMail\js\emailjs.js > E:\Avago\NodeMail\js\runner.test.txt" & Chr(34), 0
Set WinScriptHost = Nothing
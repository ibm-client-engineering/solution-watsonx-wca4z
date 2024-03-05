#Download
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2022-03/R/eclipse-rcp-2022-03-R-win32-x86_64.zip -OutFile C:\Users\$Env:UserName\Desktop\eclipse.zip

#Unzip
Expand-Archive -Path C:\Users\$Env:UserName\Desktop\eclipse.zip -DestinationPath C:\Users\$Env:UserName\Desktop\eclipse

Set-Alias eclipseIniPath "$Env:C:\Users\$Env:UserName\Desktop\eclipse\eclipse\eclipse.ini"

#Remove the zip file
Remove-Item -Path C:\Users\$Env:UserName\Desktop\eclipse.zip -Force

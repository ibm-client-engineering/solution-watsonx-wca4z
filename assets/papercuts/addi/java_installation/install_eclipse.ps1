#Download
Invoke-WebRequest https://www.eclipse.org/downloads/packages/release/2022-03/r/eclipse-ide-rcp-and-rap-developers -OutFile C:\Users\$Env:UserName\Desktop\eclipse.zip

#Unzip
Expand-Archive -Path C:\Users\$Env:UserName\Desktop\eclipse.zip -DestinationPath C:\Users\$Env:UserName\Desktop\eclipse

Set-Alias eclipseIniPath "$Env:C:\Users\$Env:UserName\Desktop\eclipse\eclipse\eclipse.ini"

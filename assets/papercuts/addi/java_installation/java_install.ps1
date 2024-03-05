$ProgressPreference = 'SilentlyContinue'
# URL of the zip file
$url = 'https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.22%2B7/OpenJDK11U-jre_x64_windows_hotspot_11.0.22_7.zip'

# Path to where you want to save the downloaded zip file
$downloadPath = 'C:\Program Files\OpenJDK11U-jre_x64_windows_hotspot_11.0.22_7.zip'
$installerDir = "C:\Program Files\Java\jdk-11.0.22+7-jre"
# Path to where you want to extract the contents
$extractPath = 'C:\Program Files\Java'

# Download the zip file
Invoke-WebRequest -Uri $url -OutFile $downloadPath

# Create the destination folder if it doesn't exist
New-Item -ItemType Directory -Force -Path $extractPath

# Unzip the file
Expand-Archive -Path $downloadPath -DestinationPath $extractPath

# Optional: Remove the downloaded zip file after extraction
Remove-Item -Path $downloadPath

[Environment]::SetEnvironmentVariable('JAVA_HOME', $installerDir, [SetEnvironmentVariableTarget]::Machine)
Start-Process -FilePath $installerPath -ArgumentList "/s", "/INSTALLERDIR=$installerDir" -Wait
Write-Host "JAVA_HOME env variable set to $installerDir"
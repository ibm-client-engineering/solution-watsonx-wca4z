function IsJavaInstalled($javaVendor, $javaVersion) {
    $javaKey = "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment\$javaVersion"
    return (Test-Path $javaKey) -and (Get-ItemProperty -Path $javaKey | Select-Object -ExpandProperty 'Java'+$javaVendor) -eq 1
}
if (IsJavaInstalled "AdoptOpenJDK" "1.8.0_11" -or IsJavaInstalled "Oracle" "1.8.0_11" -or IsJavaInstalled "IBM" "1.8.0_11" -or IsJavaInstalled "AdoptOpenJDK" "11.0.0" -or IsJavaInstalled "Oracle" "11.0.0" -or IsJavaInstalled "IBM" "11.0.0") {
        Write-Host "One of the specified Java versions is already installed. Skipping the installation process."
        exit
    }

# Define the vavailable Java Versions
$availableJavaVersions = @(
    @{ Vendor = "AdoptOpenJDK"; Version = "1.8.0_11"},
    @{ Vendor = "Oracle"; Version = "1.8.0_11"},
    @{ Vendor = "IBM"; Version = "1.8.0_11"},
    @{ Vendor = "AdoptOpenJDK"; Version = "11.0.0"},
    @{ Vendor = "Oracle"; Version = "11.0.0"},
    @{ Vendor = "IBM"; Version = "11.0.0"}
)

#Display avalable java versions
Write-Host "Available Java Versions:"
foreach ($javaVersion in $availableJavaVersions) {
    Write-Host "$($javaVersion.Vendor) $($javaVersion.Version)"
}
$chosenJavaVersion = Read-Host "Enter the Java version you want to install (e.g., AdoptOpenJDK 1.8.0_11):"

if ($chosenJavaVersion -match '^(.+?)\s(.+)$') {
    $chosenVendor = $matches[1]
    $chosenVersion = $matches[2]
    if(IsJavaInstalled $chosenVendor $chosenVersion) {
        Write-Host "$chosenJavaVersion is already installed. Skipping the installation process:"
        exit
    }
} else {
    Write-Host "Invalid input. Please provide a vallid Java version and vendor."
    exit
}
#Define the Java download URL
$javaBaseUrl = @{}
$javaBaseUrl["AdoptOpenJdk"] = 'https://adoptopenjdk.net/'
$javaBaseUrl["Oracle"] = 'https://www.oracle.com/webapps/redirect/signon?nexturl=https://download.oracle.com/otn-pub/java/'
$javaBaseUrl["IBM"] = 'https://www.ibm.com/java/developer/'

$javaDownloadUrl = "$($javaBaseUrl[$chosenVendor])jdk/$($chosenVersion)-b09/89d678f2be164786b292527658ca1605/jdk-$($chosenVersion)-windows-x64.exe"

$installerPath = ".\jdk-$($chosenVersion)-windows-x64.exe"
$installerDir = "C:\Program Files\Java\$($chosenVendor)$($chosenVersion)"

#Donwload the java installer from the web
Invoke-WebRequest -Uri $javaDownloadUrl -OutFile $installerPath

# Set JAVA_HOME environment variable
[Environment]::SetEnvironmentVariable('JAVA_HOME', $installDir, [SetEnvironmentVariableTarget]::Machine)

# Run the installer silently
Start-Process -FilePath $installerPath -ArgumentList "/s", "/INSTALLERDIR=$installerDir" -Wait

Write-Host "Java 8 64-bit installed to $installerDir"
Write-Host "JAVA_HOME env variable set to $installDir"
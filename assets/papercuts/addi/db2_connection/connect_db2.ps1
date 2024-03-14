function Set-EnvVariables {
    param (
        [string]$FilePath
    )
    $envFileContent = Get-Content -Path $FilePath -Raw
    Write-Host "ALPHA"
    Write-Host $envFileContent
    # Split content by new line using a \
    $envFileContent -split "\r?\n" | ForEach-Object {
        #split each line into key and value
        $key, $value = $_ -split '=', 2

        # set the environment variable
        [System.Environment]::SetEnvironmentVariable($key, $value, [System.EnvironmentVariableTarget]::Process)
    }

    #Get-ChildItem Env:

}

#check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  Throw "You must run this script as administrator"
}



Set-EnvVariables ".\.env"

$url="https://papercuts-wca4z.s3.us-south.cloud-object-storage.appdomain.cloud/v11.5.9_ntx64_dsdriver_EN.exe"
$downloadPath="v11.5.9_ntx64_dsdriver_EN.exe"

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $downloadPath


Start-Process -FilePath $downloadPath

db2cli writecfg add -database bludb -host $FQDN -port $DB2PORT
db2cli writecfg add -dsn dashdb -database bludb -host $FQDN -port $DB2PORT
db2cli writecfg add -database bludb -host $FQDN -port $DB2PORT -parameter "SecurityTransportMode=SSL"


.\db2configuration.bat dbName=BLUDB db2Host=$FQDN db2Port=$DB2PORT db2User=$DB2USER db2Password=$DB2PASS useTLS=true

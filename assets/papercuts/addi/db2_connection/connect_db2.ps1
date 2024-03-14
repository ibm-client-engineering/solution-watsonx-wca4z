function Set-EnvVariables {
    param (
        [string]$FilePath
    )
    $envFileContent = Get-Content -Path $FilePath -Raw
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

Write-Host $env:FQDN
Write-Host $env:DB2PORT
Write-Host $env:DB2USER
Write-Host $env:DB2PASS

Set-EnvVariables ".\.env"

$url="https://papercuts-wca4z.s3.us-south.cloud-object-storage.appdomain.cloud/v11.5.9_ntx64_dsdriver_EN.exe"
$downloadPath="v11.5.9_ntx64_dsdriver_EN.exe"

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $downloadPath


Start-Process -FilePath $downloadPath -Wait

#re source the path in order to get db2cli
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

db2cli writecfg add -database bludb -host $env:FQDN -port $env:DB2PORT
db2cli writecfg add -dsn dashdb -database bludb -host $env:FQDN -port $env:DB2PORT
db2cli writecfg add -database bludb -host $env:FQDN -port $env:DB2PORT -parameter "SecurityTransportMode=SSL"


.\db2configuration.bat dbName=BLUDB db2Host=$env:FQDN db2Port=$env:DB2PORT db2User=$env:DB2USER db2Password=$env:DB2PASS useTLS=true

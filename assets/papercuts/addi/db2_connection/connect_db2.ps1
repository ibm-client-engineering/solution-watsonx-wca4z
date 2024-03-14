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

function DownloadFtpDirectory($url, $credentials, $localPath)
{
    $listRequest = [Net.WebRequest]::Create($url)
    $listRequest.Method =
        [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
    $listRequest.Credentials = $credentials
    
    $lines = New-Object System.Collections.ArrayList

    $listResponse = $listRequest.GetResponse()
    $listStream = $listResponse.GetResponseStream()
    $listReader = New-Object System.IO.StreamReader($listStream)
    while (!$listReader.EndOfStream)
    {
        $line = $listReader.ReadLine()
        $lines.Add($line) | Out-Null
    }
    $listReader.Dispose()
    $listStream.Dispose()
    $listResponse.Dispose()

    foreach ($line in $lines)
    {
        $tokens = $line.Split(" ", 9, [StringSplitOptions]::RemoveEmptyEntries)
        $name = $tokens[8]
        $permissions = $tokens[0]

        $localFilePath = Join-Path $localPath $name
        $fileUrl = ($url + $name)

        if ($permissions[0] -eq 'd')
        {
            if (($name -ne ".") -and ($name -ne ".."))
            {
                if (!(Test-Path $localFilePath -PathType container))
                {
                    Write-Host "Creating directory $localFilePath"
                    New-Item $localFilePath -Type directory | Out-Null
                }

                DownloadFtpDirectory ($fileUrl + "/") $credentials $localFilePath
            }
        }
        else
        {
            Write-Host "Downloading $fileUrl to $localFilePath"

            $downloadRequest = [Net.WebRequest]::Create($fileUrl)
            $downloadRequest.Method =
                [System.Net.WebRequestMethods+Ftp]::DownloadFile
            $downloadRequest.Credentials = $credentials

            $downloadResponse = $downloadRequest.GetResponse()
            $sourceStream = $downloadResponse.GetResponseStream()
            $targetStream = [System.IO.File]::Create($localFilePath)
            $buffer = New-Object byte[] 10240
            while (($read = $sourceStream.Read($buffer, 0, $buffer.Length)) -gt 0)
            {
                $targetStream.Write($buffer, 0, $read);
            }
            $targetStream.Dispose()
            $sourceStream.Dispose()
            $downloadResponse.Dispose()
        }
    }
}



Set-EnvVariables ".\.env"

#$url="https://ak-delivery04-mul.dhe.ibm.com/sdfdl/v2/sar/CM/IM/0bsy7/0/Xa.2/Xb.jusyLTSp44S04pS0QkREBImn48Su0JpUuOXTtzxIGDJJSASJo_ljgiYhMjc/Xc.CM/IM/0bsy7/0/v11.5.9_ntx64_dsdriver_EN.exe/Xd./Xf.LPR.D1vk/Xg.12732236/Xi.habanero/XY.habanero/XZ.8zV6KKRzqz-raqzsYwyXRYP-Y2VP7ouv/v11.5.9_ntx64_dsdriver_EN.exe"
#$downloadPath="v11.5.9_ntx64_dsdriver_EN.exe"

#$ProgressPreference = 'SilentlyContinue'
#Invoke-WebRequest -Uri $url -OutFile $downloadPath


$credentials = New-Object System.Net.NetworkCredential("sjLcoLoM", "CRfE1rkwoKXk4cb") 
$url = "delivery04-bld.dhe.ibm.com"
DownloadFtpDirectory $url $credentials "."

exit

Start-Process -FilePath $downloadPath

db2cli writecfg add -database bludb -host $FQDN -port $DB2PORT
db2cli writecfg add -dsn dashdb -database bludb -host $FQDN -port $DB2PORT
db2cli writecfg add -database bludb -host $FQDN -port $DB2PORT -parameter "SecurityTransportMode=SSL"


.\db2configuration.bat dbName=BLUDB db2Host=$FQDN db2Port=$DB2PORT db2User=$DB2USER db2Password=$DB2PASS useTLS=true

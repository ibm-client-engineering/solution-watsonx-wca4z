function DownloadBinary {
    param (
        [string]$url
    )

    # Download binary
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile "addi_endpoint_install_binary.zip"

    # Unzip the binary
    Expand-Archive -Path "addi_endpoint_install_binary.zip" -DestinationPath "unzipped_binary"

    # Cleanup remove the downloaded zip file
    Remove-Item "addi_endpoint_install_binary.zip" -Force
}
# Function is responsible given the values on .env it updates the CCS_IP and CCS_PORT on the auto-install.xml
function UpdateXmlValues {
    $envFilePath = "./.env"
    $xmlFilePath = "./auto-install.xml"
    $file = "./auto-install.xml"
    if ($file.isReadOnly) {
        $file.isReadOnly = $false
        Write-Host "File attributes updated to allow writing."
    } else {
        Write-Host "File is not read-only. Proceeding with the Update"
    }
    # Read the .env file and set the env vars
    Get-Content $envFilePath | ForEach-Object {
        $envVar = $_ -split '=', 2
        $envVarName = $envVar[0].Trim()
        $envVarValue = $envVar[1].Trim()
        [System.Environment]::SetEnvironmentVariable($envVarName, $envVarValue, [System.EnvironmentVariableTarget]::Process)
    }
    Write-Host "CCS_IP from .env: $($env:CCS_IP)"
    Write-Host "CCS_PORT from .env: $($env:CCS_PORT)"

    echo "Starting process to install ADDI_FOR_IBM_Z_612_WIN.zip"

    $xml = [xml](Get-Content -Path $xmlFilePath)

    # find the specific userinput panel with id="userInput" and update the CCS_IP key
    $userInputPanel = $xml.AutomatedInstallation.'com.izforge.izpack.panels.userinput.UserInputPanel' | Where-Object { $_.id -eq "userInput"}

    if ($userInputPanel -ne $null) {
        $userInputPanel.entry | Where-Object { $_.key -eq "CCS_IP" } | ForEach-Object { $_.value = $($env:CCS_IP) }
    }
    if ($userInputPanel -ne $null) {
        $userInputPanel.entry | Where-Object { $_.key -eq "CCS_PORT" } | ForEach-Object { $_.value = $($env:CCS_PORT) }
    }
    $xml.Save($xmlFilePath)
}

function Main {
    UpdateXmlValues
    $xmlFilePath = "./auto-install.xml"
#     $addi_endpoint_install_binary="https://papercuts-wca4z.s3.us-south.cloud-object-storage.appdomain.cloud/ADDI_FOR_IBM_Z_612_WIN.zip"
#     if (!(Test-Path "unzipped_binary")) {
#         DownloadBinary -url $addi_endpoint_install_binary
#     }
    ls
    # java -jar '.\unzipped_binary\IBM ADDI\IBM_Application_Discovery_and_Delivery_Intelligence_Installer-6.1.2-ifix2.exe' -f $xmlFilePath

    #start microsoft-edge:https://localhost:9443/ad/admin/setup?step=1
}

Main

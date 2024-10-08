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
    $envFilePath = ".\.env"
    $scriptDirectory = $PSScriptRoot
    $xmlFilePath = Join-Path -Path $scriptDirectory -ChildPath "auto-install.xml"
    $file = Get-Item $xmlFilePath

    # Read the .env file and set the env vars
    Get-Content $envFilePath | ForEach-Object {
        $envVar = $_ -split '=', 2
        [System.Environment]::SetEnvironmentVariable($envVar[0], $envVar[1], [System.EnvironmentVariableTarget]::Process)
    }
    Write-Host "CCS_IP from .env: $($env:ccsIP)"
    Write-Host "CCS_PORT from .env: $($env:ccsPort)"

    echo "Starting process to install ADDI_FOR_IBM_Z_612_WIN.zip"

    $xml = [xml](Get-Content -Path $xmlFilePath)

    # find the specific userinput panel with id="userInput" and update the CCS_IP key
    $userInputPanel = $xml.AutomatedInstallation.'com.izforge.izpack.panels.userinput.UserInputPanel' | Where-Object { $_.id -eq "userInput"}

    if ($userInputPanel -ne $null) {
        $userInputPanel.entry | Where-Object { $_.key -eq "CCS_IP" } | ForEach-Object { $_.value = $($env:ccsIP) }
    }
    if ($userInputPanel -ne $null) {
        $userInputPanel.entry | Where-Object { $_.key -eq "CCS_PORT" } | ForEach-Object { $_.value = $($env:ccsPort) }
    }
    ls
    $xmlString = $xml.OuterXml
    Write-Host "XML Before saving:"
    Write-Host $xmlString

    try {
        $xml.Save($xmlFilePath)

    } catch {
        Write-Host "Error saving xml file:"
    }
}

function Main {
    UpdateXmlValues
    $scriptDirectory = $PSScriptRoot
    $xmlFilePath = Join-Path -Path $scriptDirectory -ChildPath "auto-install.xml"
    $addi_endpoint_install_binary="https://papercuts-wca4z.s3.us-south.cloud-object-storage.appdomain.cloud/ADDI_FOR_IBM_Z_612_WIN.zip"
    if (!(Test-Path "unzipped_binary")) {
        DownloadBinary -url $addi_endpoint_install_binary
    }
    ls
    java -jar '.\unzipped_binary\IBM ADDI\IBM_Application_Discovery_and_Delivery_Intelligence_Installer-6.1.2-ifix2.exe' -f $xmlFilePath

    start microsoft-edge:https://localhost:9443/ad/admin/setup?step=1
}

Main

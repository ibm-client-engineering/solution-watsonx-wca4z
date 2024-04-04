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
function UpdateXmlValues {
    $envFilePath = "./.env"
    $xmlFilePath = "./auto-install.xml"

    # Read the .env file and set the env vars
    Get-Content $envFilePath | ForEach-Object {
        $envVar = $_ -split '=', 2
        $envVarName = $envVar[0].Trim()
        $envVarValue = $envVar[1].Trim()
        [System.Environment]::SetEnvironmentVariable($envVarName, $envVarValue, [System.EnvironmentVariableTarget]::Process)
    }

    Write-Host "CCS_IP from .env: $($env:CCS_IP)"
    Write-Host "CCS_PORT from .env: $($env:CCS_PORT)"

    # Load XML file
    $xml = New-Object XML
    $xml.Load($xmlFilePath)

    # Update CCS_IP and CCS_PORT values
    $userInputPanel = $xml.SelectSingleNode("//com.izforge.izpack.panels.userinput.UserInputPanel[@id='userInput']")
    if ($userInputPanel -ne $null) {
        Write-Host "Found userInput panel"
        $ccsIPNode = $userInputPanel.SelectSingleNode("//entry[@key='CCS_IP']")
        if ($ccsIPNode -ne $null) {
            Write-Host "Found CCS_IP node"
            $ccsIPNode.SetAttribute('value', $env:CCS_IP)
        }
        else {
            Write-Host "CCS_IP node not found"
        }

        $ccsPortNode = $userInputPanel.SelectSingleNode("//entry[@key='CCS_PORT']")
        if ($ccsPortNode -ne $null) {
            Write-Host "Found CCS_PORT node"
            $ccsPortNode.SetAttribute('value', $env:CCS_PORT)
        }
        else {
            Write-Host "CCS_PORT node not found"
        }
    }
    else {
        Write-Host "userInput panel not found"
    }

    # Save XML file
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

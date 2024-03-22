# import the common functions script
. ".\shared\common_functions_tls.ps1"
. ".\shared\get_set_env_vars.ps1"

function Main {
    Write-Host "Configure TLS Certs and Keystores"
    $envFilePath = ".\.env"
    Set-EnvVariables -FilePath $envFilePath
    Confirm-EnvVariables
    $hostName = [System.Net.Dns]::GetHostName()

    $fqdn = [System.Net.Dns]::GetHostEntry($hostName).HostName
    $KeyPass = $env:keyPass
    $KeyStorePath = $env:keyStorePath
    $CertificatePath = $env:certificatePath
    $RefactorIP = $env:refactorIP

    if (-not (Test-Path $env:certificatePath -PathType Container)) {
        Write-Host "Directory $env:certificatePath does not exist... creating one now"
        New-Item -ItemType Directory -Path $env:certificatePath
    } else {
        Write-Host "Directory $directoryPath already exists, skipping."
    }
    # You have to define your vars like this or it breaks...
    $ServerCertificateFileName = "server_certificate.crt"
    $ZookeeperFileName = "zookeeper.crt"

    # Generate key pair, export and import cert to keystore
    GenerateKeyPair -KeyPass $KeyPass -KeyStorePath $KeyStorePath -Fqdn $fqdn
    Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -Filename $ServerCertificateFileName
    Import-CertificateToKeystore -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -KeyPass $KeyPass -Filename $ServerCertificateFileName


    ConfigureCerts -RefactorIP $RefactorIP

    ImportCertToJavaKeyStore -KeyStorePath $KeyStorePath -KeyPass $KeyPass
    Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -Filename $ZookeeperFileName
}

Main
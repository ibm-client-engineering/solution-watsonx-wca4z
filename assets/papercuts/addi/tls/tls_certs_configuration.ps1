# import the common functions script
. ".\shared\common_functions_tls.ps1"
. ".\shared\get_set_env_vars.ps1"

function Main {
    Write-Host "Configure TLS Certs and Keystores"
    $envFilePath = ".\.env"
    Set-EnvVariables -FilePath $envFilePath
    Confirm-EnvVariables
    # env vars
    $KeyPass = $env:keyPass
    $KeyStorePath = $env:keyStorePath
    $CertificatePath = $env:certificatePath
    $CertificatePathRoot = $env:certificatePathRoot

    Write-Host "KeyPass $KeyPass"
    Write-Host "KeyStorePath $KeyStorePath"
    Write-Host "CertificatePath $CertificatePath"
    Write-Host "env:certificatePath $env:certificatePath"

    Write-Host "CertificatePath $CertificatePath"
    if (-not (Test-Path $CertificatePath -PathType Container)) {
        Write-Host "Directory $CertificatePath does not exist... creating one now"
        New-Item -ItemType Directory -Path $CertificatePath
    } else {
        Write-Host "Directory $directoryPath already exists, skipping."
    }
    $hostName = [System.Net.Dns]::GetHostName()

    $fqdn = [System.Net.Dns]::GetHostEntry($hostName).HostName
    Write-Host "FQDN: $fqdn"
    # Generate key pair, export and import cert to keystore
    GenerateKeyPair -KeyPass $KeyPass -KeyStorePath $KeyStorePath -Fqdn $fqdn

    Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath
    Import-CertificateToKeystore -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -KeyPass $KeyPass

    # Optional
    # Db2SSL -DB2SSLCert $KeyStorePath -CertificatePath $CertificatePath -KeyStorePath $KeyStorePath -Password $KeyPass

    # Delete certs
    # TODO Uncomment this to test it works to delte certs,
    # DeleteServerCertificate -CertificatePath $CertificatePath

    # Cofigure certs
    # TODO Configure Certs and uncomment to test this piece works.
    # ConfigureCertificates -KeyStorePath $KeyStorePath -KeyPass $KeyPass -CertificatePathRoot $CertificatePathRoot -MyHost $MyHost -CertificatePathRootCertificatePath $CertificatePathRootCertificatePath -Fqdn $fqdn
}

Main
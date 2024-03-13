# import the common functions script
. ".\shared\common_functions_tls.ps1"
. ".\shared\get_set_env_vars.ps1"

function Main {
    Write-Host "Configure TLS Certs and Keystores"
    $envFilePath = ".\.env"
    Set-EnvVariables -FilePath $envFilePath
    Confirm-EnvVariables
    # env vars
    $DnsName = $env:dnsName
    $KeyPass = $env:keyPass
    $KeyStorePath = $env:keyStorePath
    $MyHost = $env:host
    $CertificatePathRootCertificatePath = $env:certificatePath
    $CertificatePathRoot = $env:certificatePathRoot

    Write-Host "DNSName $DnsName"
    Write-Host "KeyPass $KeyPass"
    Write-Host "KeyStorePath $KeyStorePath"
    Write-Host "MyHost $MyHost"
    Write-Host "CertificatePathRootCertificatePath $CertificatePathRootCertificatePath"
    Write-Host "env:certificatePath $env:certificatePath"

    Write-Host "CertificatePathRootCertificatePath $CertificatePathRootCertificatePath"
    if (-not (Test-Path $CertificatePathRootCertificatePath -PathType Container)) {
        Write-Host "Directory $CertificatePathRootCertificatePath does not exist... creating one now"
        New-Item -ItemType Directory -Path $CertificatePathRootCertificatePath
    } else {
        Write-Host "Directory $directoryPath already exists, skipping."
    }
    $hostName = [System.Net.Dns]::GetHostName()

    $fqdn = [System.Net.Dns]::GetHostEntry($hostName).HostName
    Write-Host "FQDN: $fqdn"
    # Generate key pair, export and import cert to keystore
    GenerateKeyPair -DnsName $DnsName -KeyPass $KeyPass -KeyStorePath $KeyStorePath -StorePass $KeyPass -MyHost $fqdn

    Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath
    # Import-CertificateToKeystore -KeyStorePath $KeyStorePath -CertificatePath CertificatePath -Password $KeyPass

    # Optional
    # Db2SSL -DB2SSLCert $KeyStorePath -CertificatePath $CertificatePath -KeyStorePath $KeyStorePath -Password $KeyPass

    # Delete certs
    # DeleteServerCertificate -CertificatePath $CertificatePath

    # Cofigure certs
    # ConfigureCertificates -KeyStorePath $KeyStorePath -KeyPass $KeyPass -CertificatePathRoot $CertificatePathRoot -MyHost $MyHost -CertificatePathRootCertificatePath $CertificatePathRootCertificatePath
}

Main
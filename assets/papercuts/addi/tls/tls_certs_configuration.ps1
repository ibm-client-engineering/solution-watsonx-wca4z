# import the common functions script
. ".\shared\common_functions_tls.ps1"
. "..\SQL_Server\shared\get_set_env_vars.ps1"

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
    Write-Host "CertificatePathRoot $CertificatePathRoot"

    $directoryPath = $CertificatePathRootCertificatePath -replace '""', ''
    if (-not (Test-Path $directoryPath -PathType Container)) {
        Write-Host "Directory $directoryPath does not exist... creating one now"
        New-Item -ItemType Directory -Path $directoryPath
    } else {
        Write-Host "Directory $directoryPath already exists, skipping."
    }


    # Generate key pair, export and import cert to keystore
#     GenerateKeyPair -DnsName $DnsName -KeyPass $KeyPass -KeyStorePath $KeyStorePath -StorePass $KeyPass -MyHost $MyHost
#     Export-CertificateToPfx -DnsName $DnsName -KeyPass $KeyPass -KeyStorePath $KeyStorePath
#     Import-CertificateToKeystore -KeyStorePath $KeyStorePath -CertificatePath CertificatePath -Password $KeyPass

    # Optional
    # Db2SSL -DB2SSLCert $KeyStorePath -CertificatePath $CertificatePath -KeyStorePath $KeyStorePath -Password $KeyPass

    # Delete certs
#     DeleteServerCertificate -CertificatePath $CertificatePath

    # Cofigure certs
#     ConfigureCertificates -KeyStorePath $KeyStorePath -KeyPass $KeyPass -CertificatePathRoot $CertificatePathRoot -MyHost $MyHost -CertificatePathRootCertificatePath $CertificatePathRootCertificatePath
}

Main
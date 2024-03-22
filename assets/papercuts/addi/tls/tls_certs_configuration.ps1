# import the common functions script
. ".\shared\common_functions_tls.ps1"
. ".\shared\get_set_env_vars.ps1"

function Main {
    Write-Host "Configuring TLS Certs and Keystores..."

    # Load environment variables from .env file
    $envFilePath = ".\.env"
    Set-EnvVariables -FilePath $envFilePath
    Confirm-EnvVariables

    # Get fully qualified domain name
    $fqdn = [System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName()).HostName

    # Extract required parameters from environment variables
    $KeyPass = $env:keyPass
    $KeyStorePath = $env:keyStorePath
    $CertificatePath = $env:certificatePath
    $RefactorIP = $env:refactorIP

    # Create certificate directory if it doesn't exist
    if (-not (Test-Path $CertificatePath -PathType Container)) {
        Write-Host "Creating directory: $CertificatePath"
        New-Item -ItemType Directory -Path $CertificatePath | Out-Null
    } else {
        Write-Host "Certificate directory already exists: $CertificatePath"
    }

    # Define certificate file names
    $ServerCertificateFileName = "server_certificate.crt"
    $ZookeeperFileName = "zookeeper.crt"

    # Generate key pair and export/import certificate to keystore
    GenerateKeyPair -KeyPass $KeyPass -KeyStorePath $KeyStorePath -Fqdn $fqdn
    Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -Filename $ServerCertificateFileName
    Import-CertificateToKeystoreWithAlias -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -Alias "self-signed-root" -StorePass "p@ssw0rd"
    Import-CertificateToKeystore -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -KeyPass $KeyPass -Filename $ServerCertificateFileName -Fqdn $fqdn

    # Configure certificates
    ConfigureCerts -RefactorIP $RefactorIP -CertificatePath $CertificatePath -KeyPass $KeyPass -Fqdn $fqdn

    # Import certificate to Java keystore
    ImportCertToJavaKeyStore -KeyStorePath $KeyStorePath -KeyPass $KeyPass

    # Export certificate to PFX
    Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -Filename $ZookeeperFileName

    # Add root certificate to trusted root certification authorities store
    $certificateFilePath = "C:\certificates\root.crt"
    Add-RootCertificateToTrustedRoot -CertificatePath $certificateFilePath

    Write-Host "TLS configuration completed successfully."
}

Main
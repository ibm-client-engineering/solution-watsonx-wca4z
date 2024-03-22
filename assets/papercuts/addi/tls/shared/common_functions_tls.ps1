
function GenerateKeyPair {
    param(
        [string]$KeyPass,
        [string]$KeyStorePath,
        [string]$Fqdn
    )
    Write-Host "GenerateKeyPair KeyStorePath: $KeyStorePath , KeyPass: $KeyPass , FQDN: $Fqdn"
    $keytoolOutput = keytool -genkeypair `
        -alias $Fqdn `
        -keyalg RSA `
        -keysize 2048 `
        -storetype PKCS12 `
        -keystore $KeyStorePath `
        -storepass $KeyPass `
        -dname "CN=$Fqdn" `
        -ext "san=dns:$Fqdn" `
        -keypass $KeyPass `
        -validity 365
    if ($keytoolOutput -match "keytool error") {
        Write-Host "Error generating key pair: $keytoolOutput"
    }
}

# Function to export a certificate to a PFX file
function Export-CertificateToPfx {
    param (
        [string]$Fqdn,
        [string]$KeyPass,
        [string]$KeyStorePath,
        [string]$CertificatePath,
        [string]$Filename
    )
    $fullFilePath = Join-Path $CertificatePath $Filename
    Write-Host "Export-CertificateToPfx KeyStorePath: $KeyStorePath , CertificatePath: $CertificatePath, KeyPass: $KeyPass , Filename: $Filename , fullFilePath: $fullFilePath"
    keytool -exportcert -alias $Fqdn -keystore $KeyStorePath -file $fullFilePath -storepass $KeyPass
    Set-Content -Path $fullFilePath -Encoding utf8 -Value ""
}

# Function to import a certificate into a keystore
function Import-CertificateToKeystore {
    param(
        [string]$KeyStorePath,
        [string]$CertificatePath,
        [string]$KeyPass,
        [string]$Filename
    )
    $fullFilePath = Join-Path $CertificatePath $Filename

    Write-Host "Import-CertificateToKeystore  KeyStorePath: $KeyStorePath , CertificatePath: $CertificatePath, KeyPass: $KeyPass , Filename: $Filename , fullFilePath: $fullFilePath"

    if(-not (Test-Path $fullFilePath -PathType Leaf)) {
        Write-Host "Certificate file not found: $fullFilePath"
        return
    }
    $certificateContent = Get-Content -Path $fullFilePath -Raw
    if([string]::IsNullOrEmpty($certificateContent)) {
        Write-Host "Certificate file is empty or null: $fullFilePath"
        return
    }
    #keytool -keystore $KeyStorePath -import -file $fullFilePath -alias "self-signed-root" -storepass $KeyPass -noprompt
    keytool -importkeystore $KeyStorePath -srcstorepass $KeyPass -destkeystore $fullKeyStoreFilePath -deststorepass $KeyPass -desstoretype PKCS12 -alias $Fqdn -noprompt
}

function ConfigureCerts {
    param(
        [string]$RefactorIP,
        [string]$CertificatePath
    )
    Write-Host "ConfigureCerts RefactorIP: $RefactorIP , CertificatePath: $CertificatePath"

    $serverKeyFileName = "server.key"
    $serverKeyStoreFileName = "server_keystore.p12"
    $rootCertFileName = "root.crt"
    $serverCertificateFileName = "server_certificate.crt"

    $fullServerKeyFilePath = Join-Path $CertificatePath $serverKeyFileName
    $fullKeyStoreFilePath = Join-Path $CertificatePath $serverKeyStoreFileName
    $fullRootCertFilePath = Join-Path $CertificatePath $rootCertFileName
    $fullCertificateFilePath = Join-Path $CertificatePath $serverCertificateFileName

    $fullFilePath = Join-Path $CertificatePath $serverKeyFileName

    ssh root@$RefactorIP 'cat /root/certs/root.crt' | Out-File -Encoding utf8 'C:\certificates\root.crt'

    keytool -importcert -alias self-signed-root -keystore $fullKeyStoreFilePath -storetype PKCS12 -storepass $KeyPass -file $fullRootCertFilePath -storepass $KeyPass -ext "BasicConstraints:critical=ca:true" -ext "san=dns:$Fqdn"
    keytool -importcert -alias ad-core-server -keystore $fullKeyStoreFilePath -storetype PKCS12 -storepass $KeyPass -file $fullAdCoreCertFilePath -storepass $KeyPass -ext "BasicConstraints:critical=ca:true" -ext "san=dns:$Fqdn"

    # Generate server.key file
    openssl pkcs12 -in $KeyStorePath -nocerts -nodes -out $fullServerKeyFilePath

    # Export all ceertificates to server_certificate.crt
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    keytool -list -keystore $fullKeyStoreFilePath -rfc > $fullCertificateFilePath

    Write-Host "Certificates configured successfully."
    # TODO Open that server_certificate.crt in notepad and reset the order of certs. We want the root cert to be at the to
}

function DeleteServerCertificate {
    param(
        [string]$CertificatePath
    )
    #Remove-Item -Recurse -Force -Path $CertificatePath
}

function ImportCertToJavaKeyStore {
    param(
        [string]$KeyStorePath,
        [string]$KeyPass
    )
    Write-Host "ImportCertToJavaKeyStore KeyStorePath: $KeyStorePath , KeyPass: $KeyPass"
    keytool -importkeystore -srckeystore $KeyStorePath -srcstorepass $KeyPass -destkeystore "C:\Program Files\Eclipse Adoptium\jre-11.0.22.7-hotspot\lib\security\cacerts" -deststorepass "changeit" -deststoretype pkcs12 -noprompt
    # keytool -list -keystore "C:\Program Files\Eclipse Adoptium\jre-11.0.22.7-hotspot\lib\security\cacerts" -storepass "changeit" -deststoretype pkcs12 -noprompt
    # Get-Service | Select-Object DisplayName, ServiceName

    Restart-Service -Name "IBM Application Discovery Configuration Service (IBMApplicationDiscoveryConfigurationService)"
    Write-Host "ImportCertToJavaKeyStore completed successfully"
    # lists the certificates in the path
    # Get-ChildItem -Path $CertificatePathRootCertificatePath

}

function Add-RootCertificateToTrustedRoot {
    param (
        [string]$CertificatePath
    )
    try {
        Write-Host "Add-RootCertificateToTrustedRoot CertificatePath $CertificatePath"
        # Import the root certificate to the Trusted Root Certification Authorities store
        $rootCert = Get-Content -Path $CertificatePath -Raw -Encoding UTF8
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import([System.Text.Encoding]::ASCII.GetBytes($rootCert))

        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList "Root", "LocalMachine"
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        $store.Add($cert)
        $store.Close()
        Write-Host "Root certificate successfully added to trusted root certification authorities store."
    } catch {
        Write-Host "Error adding root certificate to Trusted Root Certification Authorities store. $_"
    }
}
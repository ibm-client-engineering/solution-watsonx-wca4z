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
    keytool -keystore $KeyStorePath -import -file $fullFilePath -alias "self-signed-root" -storepass $KeyPass -noprompt
}

function GenerateKeyPair {
    param(
        [string]$KeyPass,
        [string]$KeyStorePath,
        [string]$Fqdn
    )
    Write-Host "GenerateKeyPair KeyStorePath: $KeyStorePath , KeyPass: $KeyPass , FQDN: $Fqdn"
    keytool -genkeypair -alias $Fqdn -keyalg RSA -keysize 2048 -dname "cn=$Fqdn" -keypass $KeyPass -keystore $KeyStorePath -storepass $KeyPass -storetype PKCS12 -ext BasicConstraints:critical=ca:true -ext san=dns:$Fqdn
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
    keytool -importkeystore -srckeystore $KeyStorePath -srcstorepass $KeyPass -destkeystore "C:\Program Files\Eclipse Adoptium\jre-11.0.22.7-hotspot\lib\security\cacerts" -deststorepass "changeit"
    # keytool -list -keystore "C:\Program Files\Eclipse Adoptium\jre-11.0.22.7-hotspot\lib\security\cacerts" -storepass "changeit"
    # Get-Service | Select-Object DisplayName, ServiceName

    Restart-Service -Name "IBM Application Discovery Configuration Service (IBMApplicationDiscoveryConfigurationService)"

    # lists the certificates in the path
    # Get-ChildItem -Path $CertificatePathRootCertificatePath

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

    keytool -importcert -alias ad-core-server -keystore $fullKeyStoreFilePath -storetype PKCS12 -storepass $KeyPass -file $fullRootCertFilePath -storepass $KeyPass -ext "BasicConstraints:critical=ca:true" -ext "san=dns:$Fqdn"

    # generates server.key file
    openssl pkcs12 -in $KeyStorePath -nocerts -nodes -out $fullServerKeyFilePath

    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    keytool -list -keystore $KeyStorePath -rfc > $fullCertificateFilePath

    # TODO Open that server_certificate.crt in notepad and reset the order of certs. We want the root cert to be at the to
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
# Function to export a certificate to a PFX file
function Export-CertificateToPfx {
    param (
        [string]$Fqdn,
        [string]$KeyPass,
        [string]$KeyStorePath,
        [string]$CertificatePath,
        [string]$Filename
    )
    $fullFilePath = Join-Path $CertificatePath $FileName
    keytool -exportcert -alias $Fqdn -keystore $KeyStorePath -file $fullFilePath -storepass $KeyPass
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
    keytool -keystore $KeyStorePath -import -file $fullFilePath -alias "self-signed-root" -storepass $KeyPass
}

function GenerateKeyPair {
    param(
        [string]$KeyPass,
        [string]$KeyStorePath,
        [string]$Fqdn
    )
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
    keytool -importkeystore -srckeystore $KeyStorePath -srcstorepass $KeyPass -destkeystore "%JAVA_HOME%\lib\security\cacerts" -deststorepass "changeit"

    Get-Service | Select-Object DisplayName, ServiceName

    Restart-Service -Name "IBM Application Discovery Configuration Service (IBMApplicationDiscoveryConfigurationService)"

    # lists the certificates in the path
    Get-ChildItem -Path $CertificatePathRootCertificatePath

}

function ConfigureCerts {
    param(
        [string]$RefactorIP
    )
    $serverKeyFileName = "server.key"
    $serverKeyStoreFileName = "server_keystore.p12"
    $rootCertFileName = "root.crt"
    $serverCertificateFileName = "server_certificate.crt"

    $fullServerKeyFilePath = Join-Path $CertificatePath $serverKeyFileName
    $fullKeyStoreFilePath = Join-Path $CertificatePath $serverKeyStoreFileName
    $fullRootCertFilePath = Join-Path $CertificatePath $rootCertFileName
    $fullCertificateFilePath = Join-Path $CertificatePath $serverCertificateFileName

    keytool -importcert -alias ad-core-server -keystore $fullKeyStoreFilePath -storetype PKCS12 -storepass $KeyPass -file $fullRootCertFilePath -storepass $KeyPass -ext BasicConstraints:critical=ca:true -ext san=dns:$Fqdn

    $fullFilePath = Join-Path $CertificatePath $serverKeyFileName

    ssh root@$RefactorIP 'cat /root/certs/root.crt' > C:\certificates\root.crt

    # generates server.key file
    openssl pkcs12 -in $KeyStorePath -nocerts -nodes -out $fullServerKeyFilePath

    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    keytool -list -keystore $KeyStorePath -rfc > $fullCertificateFilePath

    # TODO Open that server_certificate.crt in notepad and reset the order of certs. We want the root cert to be at the to
}

function RootCertificateToTrusted-Root {
    $rootCertFileName = "root.crt"
    $serverCertificateFileName = "server_certificate.crt"

    $fullCertificateFilePath = Join-Path $CertificatePath $serverCertificateFileName
    $fullRootCertFilePath = Join-Path $CertificatePath $rootCertFileName

    Import-Certificate -FilePath $fullCertificateFilePath -CertStoreLocation $fullRootCertFilePath
}
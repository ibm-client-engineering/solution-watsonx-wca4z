
# Function to generate a self-signed certificate
function New-SelfSignedCertificate {
    param(
        [string]$DnsName,
        [string]$CertStoreLocation = "Cert:\LocalMachine\My"
    )
    # Implementation using New-SelfSignedCertificate cmdlet
    # ..

    # Return the generated certificate
}
# Function to export a certificate to a PFX file
function Export-CertificateToPfx {
    param (
        # [System.Security.CryptoGraphy.x509Certificates.X509Certificates2]$Certificate,
        [string]$Fqdn,
        [string]$KeyPass,
        [string]$KeyStorePath,
        [string]$CertificatePath
    )

    $fileName = "exported_certificate.cer"
    $fullFilePath = Join-Path $CertificatePath $fileName
    keytool -exportcert -alias $Fqdn -keystore $KeyStorePath -file $fullFilePath -storepass $KeyPass
}

# Function to import a certificate into a keystore
function Import-CertificateToKeystore {
    param(
        [string]$KeyStorePath,
        [string]$CertificatePath,
        [string]$KeyPass
    )
    $fileName = "exported_certificate.cer"
    $fullFilePath = Join-Path $CertificatePath $fileName
    keytool -keystore KeyStorePath -import -file $fullFilePath -alias "self-signed-root" -storepass $KeyPass
}

# Function to peform additional steps like managing aliases, deleting uncessary files, etc.
function Additional-KeystoreConfiguration {
    param(
        [string]$KeystorePath
    )

    # Additional configuration steps
    # ...
}

function Db2SSL {
    param(
        [string]$DB2SSLCert,
        [string]$CertificatePath,
        [string]$KeyStorePath,
        [string]$Password
    )
    keytool -import -trustcacerts -alias $DB2SSLCert -file $CertificatePath -keystore $KeyStorePath -storepass $Password

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

function GenerateServerKey {
    param(
        [string]$KeyStorePath
    )

    openssl pkcs12 -in $KeyStorePath -nocerts -nodes -out "D:\certificates\server.key"
}

function ConfigureCertificates {
    # TODO #2 Verify that server.key, server_certificate, server_keystore exist guardrail

    param(
        [string]$KeyStorePath,
        [string]$KeyPass,
        [string]$CertificatePathRoot,
        [string]$MyHost,
        [string]$CertificatePathRootCertificatePath,
        [string]$Fqdn
    )
    $fileName = "exported_certificate.cer"
    $fullFilePath = Join-Path $CertificatePath $fileName
    keytool -importcert -alias ad-core-server -keystore $KeyStorePath -storetype PKCS12 -storepass $KeyPass -file $fullFilePath -storepass $KeyPass -ext BasicConstraints:critical=ca:true -ext san=dns:$Fqdn

    # TODO #3 If you run windows 2022 or higher you have to use UTF 16
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    keytool -list -keystore $KeyStorePath -rfc > $CertificatePathRootCertificatePath

    Get-Service | Select-Object DisplayName, ServiceName

    Restart-Service -Name "IBM Application Discovery Configuration Service (IBMApplicationDiscoveryConfigurationService)"

    Import-PfxCertificate -FilePath $CertificatePathRootCertificatePath -Password $KeyPass

    # lists the certificates in the path
    Get-ChildItem -Path $CertificatePathRootCertificatePath

}



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
        [string]$DnsName,
        [string]$Password,
        [string]$KeyStorePath
    )
    keytool -exportcert -alias $DnsName -keystore $KeyStorePath -file "D:\certificates\server_certificate.crt" -storepass $Password
}

# Function to import a certificate into a keystore
function Import-CertificateToKeystore {
    param(
        [string]$KeyStorePath,
        [string]$CertificatePath,
        [string]$Password
    )
    keytool -keystore KeyStorePath -import -file $CertificatePath -alias "self-signed-root" -storepass $Password
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
        [string]$DnsName,
        [string]$KeyPass,
        [string]$KeyStorePath,
        [string]$StorePass,
        [string]$MyHost
    )
    keytool -genkeypair -alias $DnsName -keyalg RSA -keysize 2048 -dname "cn=$DnsName" -keypass $KeyPass -keystore $KeyStorePath -storepass $StorePass -storetype PKCS12 -ext BasicConstraints:critical=ca:true -ext san=dns:$MyHost
}


function DeleteServerCertificate {
    param(
        [string]$CertificatePath
    )
    # Remove-Item -Recurse -Force -Path $CertificatePath
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
        [string]$CertificatePathRootCertificatePath
    )
    keytool -importcert -alias ad-core-server -keystore $KeyStorePath -storetype PKCS12 -storepass $KeyPass -file $CertificatePathRoot -storepass $KeyPass -ext BasicConstraints:critical=ca:true -ext san=dns:$MyHost

    # TODO #3 If you run windows 2022 or higher you have to use UTF 16
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    keytool -list -keystore $KeyStorePath -rfc > $CertificatePathRootCertificatePath

    Get-Service | Select-Object DisplayName, ServiceName

    Restart-Service -Name "IBM Application Discovery Configuration Service (IBMApplicationDiscoveryConfigurationService)"

    Import-PfxCertificate -FilePath $CertificatePathRootCertificatePath -Password $KeyPass

    # lists the certificates in the path
    Get-ChildItem -Path $CertificatePathRootCertificatePath

}


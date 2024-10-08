function GenerateKeyPair {
    param(
        [string]$KeyPass,
        [string]$KeyStorePath,
        [string]$Fqdn
    )
    Write-Host "GenerateKeyPair KeyStorePath: $KeyStorePath , KeyPass: $KeyPass , FQDN: $Fqdn"
    keytool -genkeypair -alias "$Fqdn" -keyalg RSA -keysize 2048 -dname "cn=$Fqdn" -ext BasicConstraints:critical=ca:true -keypass "$KeyPass" -keystore "$KeyStorePath" -storepass "$KeyPass" -validity 3653 -storetype PKCS12
}

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
    keytool -exportcert -alias "$Fqdn" -keystore "$KeyStorePath" -file $fullFilePath -storepass "$KeyPass" -rfc -ext BasicConstraints:critical=ca:true
}

function Import-CertificateToKeystore {
    param(
        [string]$KeyStorePath,
        [string]$CertificatePath,
        [string]$KeyPass,
        [string]$Filename,
        [string]$Fqdn
    )
    $fullFilePath = Join-Path $CertificatePath $Filename
    Write-Host "Import-CertificateToKeystore  KeyStorePath: $KeyStorePath , CertificatePath: $CertificatePath, KeyPass: $KeyPass , Filename: $Filename , fullFilePath: $fullFilePath"

    if (-not (Test-Path $fullFilePath -PathType Container)) {
        Write-Host "Certificate file not found: $fullFilePath"
        return
    }

    $certificateContent = Get-Content -Path $fullFilePath -Raw

    if ([string]::IsNullOrEmpty($certificateContent)) {
        Write-Host "Certificate file is empty or null: $fullFilePath"
        return
    }

    keytool -importcert -keystore "$KeyStorePath" -file $fullFilePath -alias "$Fqdn" -noprompt
}

function Import-CertificateToKeystoreWithAlias {
    param(
        [string]$KeyStorePath,
        [string]$CertificatePath,
        [string]$Alias,
        [string]$StorePass
    )
    Write-Host "Importing certificate to keystore with alias: $Alias"

    if (-not (Test-Path $CertificatePath -PathType Leaf)) {
        Write-Host "Certificate file not found: $CertificatePath"
        return
    }
    keytool -importcert -keystore "$KeyStorePath" -file "$CertificatePath" -alias "$Alias" -storepass "$StorePass" -noprompt -ext BasicConstraints:critical=ca:true
}

function ConfigureCerts {
    param(
        [string]$RefactorIP,
        [string]$CertificatePath,
        [string]$KeyPass,
        [string]$Fqdn,
        [string]$PrivateKeyPath
    )
    Write-Host "ConfigureCerts RefactorIP: $RefactorIP , CertificatePath: $CertificatePath"

    $serverKeyFileName = "server.key"
    $serverKeyStoreFileName = "server_keystore.p12"
    $rootCertFileName = "root.crt"
    $serverCertificateFileName = "server_certificate.crt"
    $serverCertCombinedFileName = "combined.cer"
    $serverCertCombinedCrtFileName = "combined.crt"

    $fullServerKeyFilePath = Join-Path $CertificatePath $serverKeyFileName
    $fullKeyStoreFilePath = Join-Path $CertificatePath $serverKeyStoreFileName
    $fullRootCertFilePath = Join-Path $CertificatePath $rootCertFileName
    $fullCertificateFilePath = Join-Path $CertificatePath $serverCertificateFileName
    $fullCombinedFilePath = Join-path $CertificatePath $serverCertCombinedFileName
    $fullCombinedCertFileName = Join-path $CertificatePath $serverCertCombinedCrtFileName

    $fullFilePath = Join-Path $CertificatePath $serverKeyFileName

    openssl pkcs12 -password pass:$KeyPass -in $fullKeyStoreFilePath -nocerts -nodes -out $fullServerKeyFilePath


    $scpCommand = "scp"
    if($PrivateKeyPath -and (Test-Path $PrivateKeyPath)) {
        $scpCommand += " -i $PrivateKeyPath"
    }
    # copy file to remote host
    $scpCommand += "  root@${RefactorIP}:/root/certs/root.crt ${fullRootCertFilePath}"

    Invoke-Expression $scpCommand

    # creates combined.cer and combined.crt
    (Get-Content $fullCertificateFilePath -Raw) + (Get-Content $fullRootCertFilePath -Raw) | Set-Content -Encoding ASCII -NoNewline $fullCombinedFilePath
    (Get-Content $fullCertificateFilePath -Raw) + (Get-Content $fullRootCertFilePath -Raw) | Set-Content -Encoding ASCII -NoNewline $fullCombinedCertFileName

    # Conctantes contents of the db2_cert.pem into combined.crt
    $combinedCrtContent = Get-Content $fullCombinedCertFileName -Raw
    $db2CertContent = Get-Content "C:\certificates\db2_cert.pem" -Raw
    $combinedCrtContent += $db2CertContent
    Set-Content -Path $fullCombinedCertFileName -Value $combinedCrtContent -Encoding ASCII

    # add the root certificate to the keystore
    keytool -importcert -keystore $fullKeyStoreFilePath -file $fullRootCertFilePath -alias "root" -storepass "$KeyPass" -noprompt -ext BasicConstraints:critical=ca:true

    # import the combined .cert file into the keystore
    keytool -importcert -keystore $fullKeyStoreFilePath -file $fullCombinedFilePath -alias "combined" -storepass "$KeyPass" -noprompt -ext BasicConstraints:critical=ca:true


    Write-Host "Certificates configured successfully"
}
function ImportCertToJavaKeyStore {
    param(
        [string]$KeyStorePath,
        [string]$KeyPass,
        [string]$JreCaCertsPath
    )

    Write-Host "ImportCertToJavaKeyStore KeyStorePath: $KeyStorePath , KeyPass: $KeyPass"
    keytool -importkeystore -srckeystore $KeyStorePath -srcstorepass $KeyPass -destkeystore "$JreCaCertsPath" -deststorepass "changeit"

    Restart-Service -Name "IBM Application Discovery Configuration Service (IBMApplicationDiscoveryConfigurationService)"
    Write-Host "ImportCertToJavaKeyStore completed successfully"
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

function TestConnection {
    param (
        [string]$AddiIP,
        [string]$RefactorIP,
        [string]$PrivateKeyPath
    )
    try {
        $dummyFilePath = "C:\dummy.txt"
        if (-not (Test-Path $dummyFilePath -PathType Leaf)) {
            New-Item -Path $dummyFilePath -ItemType File -Value "This is a dummy file"
        }
        $sshCommand = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
        if ($PrivateKeyPath -and (Test-Path $PrivateKeyPath)) {
            $sshCommand += " -i $PrivateKeyPath"
        }
        $sshCommand += " root@${RefactorIP} 'exit'"
        Invoke-Expression $sshCommand | Out-Null
        Write-Host "SSH connection to $RefactorIP successful."
    } catch {
        Write-Host "Failed to establish ssh connection to $RefactorIP with private key. Exiting script." -ForegroundColor Red
        exit 1
    }
    # test scp connection
    try {

        $destination = "root@${RefactorIP}:/root/"

        $scpCommand = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
        if ($PrivateKeyPath -and (Test-Path $PrivateKeyPath)) {
            $scpCommand += " -i $PrivateKeyPath"
        }
        # add source and des paths to the scp scpCommand
        $scpCommand += " `"$dummyFilePath`" $destination"
        Invoke-Expression $scpCommand
        Write-Host "Scp connection to $RefactorIP was successful."
    } catch {
        Write-Host "Failed to establish SCP connection to $RefactorIP. Exiting script." -ForegroundColor Red
        exit 1
    }
}
function ExportFileToRemoteHost {
    param (
        [string]$CertificatePath,
        [string]$AddiIP,
        [string]$RefactorIP,
        [string]$PrivateKeyPath
    )

    Test-NetConnection -ComputerName $RefactorIP -Port 22

    Write-Host "Exporting file to remote host zookeeper.yaml && zookeper.crt"
    $zooKeeperFileName = "zookeeper.crt"
    $fullZooKeeperFilePath = Join-Path $CertificatePath $zooKeeperFileName
    cat $fullZooKeeperFilePath

    $scpCommand = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    if($PrivateKeyPath -and (Test-Path $PrivateKeyPath)) {
        $scpCommand += " -i $PrivateKeyPath"
    }
    # copy file to remote host
    $scpCommand += " `"${fullZooKeeperFilePath}`" root@${RefactorIP}:/etc/pki/ca-trust/source/anchors/zookeeper.crt"

    Invoke-Expression $scpCommand

    if ($LastExitCode -eq 0) {
        Write-Host "File copied successfully to Refactor host"
        $sshCommand = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${RefactorIP}"
        $sudoCommand = "sudo update-ca-trust extract"
        Invoke-Expression "$sshCommand `"$sudoCommand`""

        if ($LastExitCode -eq 0) {
            Write-Host "CA trust store updated successfully on Refactor host."
            Invoke-Expression "$sshCommand `"`ln -s /etc/pki/ca-trust/source/anchors/zookeeper.crt /root/certs/ad.crt`""
            Invoke-Expression "$sshCommand `"`ln -s /etc/pki/ca-trust/source/anchors/zookeeper.crt /root/certs/dex.crt`""
            Invoke-Expression "$sshCommand `"`ln -s /etc/pki/ca-trust/source/anchors/zookeeper.crt /root/certs/zookeeper.crt`""
        } else {
            Write-Host "Failed to create symbolic links on Refactor host." -ForegroundColor Red
        }
    } else {
        Write-Host "Failed to copy file to Refactor host" -ForegroundColor Red
    }
}

function ImportDB2CertIntoKeyStore {
        param(
        [string]$KeyStorePath,
        [string]$KeyPass,
        [string]$DB2CertPath
    )
    Write-Host "ImportDB2CertIntoKeyStore KeyStorePath: $KeyStorePath , KeyPass: $KeyPass , DB2CertPath: $DB2CertPath"
    keytool -import -trustcacerts -alias "DB2-ssl-cert" -file $DB2CertPath -keystore "$KeyStorePath" -storepass $KeyPass

}
function GenerateDB2CertPem {
    param(
    [string]$DB2CertPath
    )
   Write-Host "GenerateDB2CertPem DB2CertPath: $DB2CertPath"
   openssl x509 -inform DER -in "$DB2CertPath" -out "C:\certificates\db2_cert.pem"
}
function UpdateYamlFile {
   param (
        [string]$MyHash,
        [string]$AddiIP,
        [string]$RefactorIP
    )
    Write-Host "Update Zookeeper Yaml File given .env values"
    $yamlFilePath = ".\dex.yaml"
    $yamlContent = Get-Content -Path $yamlFilePath -Raw

    # replace vars in the yaml certificateContent
    $yamlContent = $yamlContent -Replace '\$\{AddiIP}', $AddiIP
    $yamlContent = $yamlContent -Replace '\$\{RefactorIP}', $RefactorIP
    $yamlContent = $yamlContent -Replace '\$\{MyHash}', $MyHash

    $updatedYamlFilePath = "C:\Program Files\IBM Application Discovery and Delivery Intelligence\Authentication Server (DEX)\conf\dex.yaml"
    # write updated content back to the yaml file
    $yamlContent | Set-Content -Path $updatedYamlFilePath

    Write-Host "Yaml file updated and saved to: $updatedYamlFilePath"

}
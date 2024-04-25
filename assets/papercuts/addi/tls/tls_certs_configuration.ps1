# import the common functions script
. ".\shared\common_functions_tls.ps1"
. ".\shared\get_set_env_vars.ps1"

function Main {
  Write-Host "Configure TLS Certs and Keystores"
      $envFilePath = ".\.env"
      Set-EnvVariables -FilePath $envFilePath
      Confirm-EnvVariables

      $KeyPass = $env:KeyPass
      $MyHashPassword = $env:MyHashPassword
      $KeyStorePath = $env:KeyStorePath
      $CertificatePath = $env:CertificatePath
      $RefactorIP = $env:RefactorIP
      $AddiIP = $env:AddiIP
      $JreCaCertsPath = $env:JreCaCertsPath
      $PrivateKeyPath = $env:PrivateKeyPath
      $DB2CertPath = $env:DB2CertPath
      $AddiFQDN = $env:AddiFQDN
      $fqdn = $AddiFQDN

      # Test SCP connection against remote host, refactor
      TestConnection -AddiIP $AddiIP -RefactorIP $RefactorIP -PrivateKeyPath $PrivateKeyPath

      if (-not (Test-Path $CertificatePath -PathType Container)) {
          Write-Host "Directory $CertificatePath does not exist... creating one now"
          New-Item -ItemType Directory -Path $CertificatePath
      } else {
          Write-Host "Directory $CertificatePath already exists, skipping."
      }
      # You have to define your vars like this or it breaks...
      $ServerCertificateFileName = "server_certificate.crt"
      $ZookeeperFileName = "zookeeper.crt"

      # Generate key pair, export and import cert to keystore
      GenerateKeyPair -KeyPass $KeyPass -KeyStorePath $KeyStorePath -Fqdn $fqdn

      # Export Cert to Pfx
      Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -Filename $ServerCertificateFileName

      # creates zookeeper.crt file
      Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -Filename $ZookeeperFileName

      # Import Cert to Keystore self-signed-root
      Import-CertificateToKeystoreWithAlias -KeyStorePath $KeyStorePath -CertificatePath $ServerCertificateFileName -Alias "self-signed-root" -StorePass $KeyPass -Fqdn $Fqdn

      # Import DB2 Cert to KeyStore
      ImportDB2CertIntoKeyStore -KeyStorePath $KeyStorePath -KeyPass $KeyPass -DB2CertPath $DB2CertPath

      # Generate DB2 Cert PEM file
      GenerateDB2CertPem -DB2CertPath $DB2CertPath

      #Configure Certs
      ConfigureCerts -RefactorIP $RefactorIP -CertificatePath $CertificatePath -KeyPass $KeyPass -Fqdn $fqdn -PrivateKeyPath $PrivateKeyPath

      #Import Cert To Java KeyStore
      ImportCertToJavaKeyStore -KeyStorePath $KeyStorePath -KeyPass $KeyPass -JreCaCertsPath $JreCaCertsPath

      # Import the root certificate to the trusted root certification authorities store
      $certificateFilePath = $env:certificatePathRoot
      Add-RootCertificateToTrustedRoot -CertificatePath $certificateFilePath
      Add-RootCertificateToTrustedRoot -CertificatePath "C:\certificates\combined.crt"

      UpdateYamlFile -MyHash $MyHashPassword -AddiIP $AddiIP -RefactorIP $RefactorIP

      # export zookeeper.crt to refactor host
      ExportFileToRemoteHost -CertificatePath $CertificatePath -AddiIP $AddiIP -RefactorIP $RefactorIP -PrivateKeyPath $PrivateKeyPath
      Write-Host "TLS configuration completed successfully."


}

Main
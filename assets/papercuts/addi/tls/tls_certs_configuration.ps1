# import the common functions script
. ".\shared\common_functions_tls.ps1"
. ".\shared\get_set_env_vars.ps1"

function Main {
  Write-Host "Configure TLS Certs and Keystores"
      $envFilePath = ".\.env"
      Set-EnvVariables -FilePath $envFilePath
      Confirm-EnvVariables
      $hostName = [System.Net.Dns]::GetHostName()

      $fqdn = [System.Net.Dns]::GetHostEntry($hostName).HostName
      $KeyPass = $env:KeyPass
      $KeyStorePath = $env:KeyStorePath
      $CertificatePath = $env:CertificatePath
      $RefactorIP = $env:RefactorIP
      $AddiIP = $env:AddiIP

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
      GenerateKeyPair -KeyPass $KeyPass -KeyStorePath $KeyStorePath -Fqdn $fqdn -AddiIP $AddiIP
      Export-CertificateToPfx -Fqdn $fqdn -KeyPass $KeyPass -KeyStorePath $KeyStorePath -CertificatePath $CertificatePath -Filename $ServerCertificateFileName
      Import-CertificateToKeystoreWithAlias -KeyStorePath $KeyStorePath -CertificatePath $ServerCertificateFileName -Alias "self-signed-root" -StorePass $KeyPass

      ConfigureCerts -RefactorIP $RefactorIP -CertificatePath $CertificatePath -KeyPass $KeyPass -Fqdn $fqdn

      ImportCertToJavaKeyStore -KeyStorePath $KeyStorePath -KeyPass $KeyPass

      # Import the root certificate to the trusted root certification authorities store
      $certificateFilePath = $env:certificatePathRoot
      Add-RootCertificateToTrustedRoot -CertificatePath $certificateFilePath
      Add-RootCertificateToTrustedRoot -CertificatePath "C:\certificates\combined.crt"

      Write-Host "TLS configuration completed successfully."
}

Main
# import the common functions script
. ".\shared\common_functions.ps1"
. ".\shared\common_functions_tls.ps1"
. ".\shared\get_set_env_vars.ps1"

function Main {
    $envFilePath = ".\.env"
    Set-EnvVariables -FilePath $envFilePath

    Write-Host "Starting sql_user_permissions.ps1 script"
    Confirm-EnvVariables
    Write-Host "Chose a step to proceed:"
    Write-Host "1. Step 1. Checks if SSL encryption is enabled." # recommended, optional
    Write-Host "2. Step 2. Configure SQL For TCP" # recommended
    Write-Host "3. Step 3. Set up SQL User Account" ## required default user is dbo
    Write-Host "4. Step 4. Checks if SQL user has all required privileges on $env:serverInstance" ## required
    Write-Host "5. Step 5. Configure SSL For ADD components"
    Write-Host "6. Step 6. Check and configure collation" ## required, this should be after step 2.
    Write-Host "7. Step 7. Configure TLS Certs and Keystores" ## required
    Write-Host "8. Step 8. Get existing usernames" ## required
    Write-Host "9. Step 9. Get existing databases" ## required

    $choice = Read-Host "Enter the step number"

    switch ($choice) {
        1 { Step1 }
        2 { Step2 }
        3 { Step3 }
        4 { Step4 }
        5 { Step5 }
        6 { Step6 }
        7 { Step7 }
        8 { Step8 }
        9 { Step9 }
        default { Write-Host "Invalid choise. Exiting." }
    }
}
## Optional
function Step1 {
    ConfirmAndExecute "Step 1"
    # Checks if SSL
    if ($IsSSLEncryptionEnabled) {
        Write-Host "SSL Encryption is enabled for SQL Server ($env:serverInstance)"
    } else {
        Write-Host "SSL Encryption is not enabled for SQL Server ($env:serverInstance)"
        # Step 1
        EnableSSLEncryption
    }
}

## TCP enabled by default when running sql_server_install.ps1
function Step2 {
    ConfirmAndExecute "Step 2"
    ConfigureSQLForTCP
}
## Required
function Step3 {
    ConfirmAndExecute "Step 3"
    SetUpSQLUserAccount
    Write-Host "SQL user set up successfully"
}
## Required
function Step4 {
    ## TODO at some point we need to create login
    #ConfirmAndExecute "Step 4"
    $currentSQLUserHasPrivileges = CheckSQLUserPrivileges

    if ($currentSQLUserHasPrivileges) {
        Write-Host "The current SQL user $env:sqlUser has all required privileges on $env:serverInstance"
    } else {
        Write-Host "The current SQL user $env:sqlUser does not have all required privileges on $env:serverInstance"
        # Step 3
        $setUpSqlUser = Read-Host "Do you want to set up the SQL user $env:sqlUser? (Y/N)"
        if($setUpSqlUser) {
            SetUpSQLUserAccount
            Write-Host "SQL user set up successfully"
        } else {
            Write-Host "SQL user setup skipped."
        }
    }
}

function Step5 {
    ConfirmAndExecute "Step 5"
    ConfigureTLSJava -eclipseIniPath $env:eclipseIniPath
}
function Step6 {
    ConfirmAndExecute "Step 6"
    ConfigureSSLForAdComponents
}
#  Configure TLS Certs && KeyStores
function Step7 {
    # env vars
    $DnsName = $env:dnsName
    $KeyPass = $env:keyPass
    $KeyStorePath = $env:keyStorePath
    $MyHost = $env:host
    $CertificatePathRootCertificatePath = $env:certificatePath
    $CertificatePathRoot = $env:certificatePathRoot

    # Generate key pair, export and import cert to keystore
    GenerateKeyPair -DnsName $DnsName -KeyPass $KeyPass -KeyStorePath $KeyStorePath -StorePass $KeyPass -MyHost $MyHost
    Export-CeritficateToPfx -DnsName $DnsName -KeyPass $KeyPass -KeyStorePath $KeyStorePath
    Import-CertificateToKeystore -KeyStorePath $KeyStorePath -CertificatePath CertificatePath -Password $KeyPass

    # Optional
    Db2SSL -DB2SSLCert $KeyStorePath -CertificatePath $CertificatePath -KeyStorePath $KeyStorePath -Password $KeyPass

    # Delete certs
    DeleteServerCertificate -CertificatePath $CertificatePath

    # Cofigure certs
    ConfigureCertificates -KeyStorePath $KeyStorePath -KeyPass $KeyPass -CertificatePathRoot $CertificatePathRoot -MyHost $MyHost -CertificatePathRootCertificatePath $CertificatePathRootCertificatePath
}

function Step8 {
    $usernames = Get-SqlUsernames -ServerInstance $env:serverInstance -Database $env:sqlDatabase -SqlUser $env:sqlUser -SqlPassword $env:sqlPassword
    Write-Output "usernames:" $usernames
}
function Step9 {
    $databases = Get-SqlDatabases -ServerInstance $env:serverInstance -Database $env:sqlDatabase -SqlUser $env:sqlUser -SqlPassword $env:sqlPassword
    Write-Output "databases:" $databases
}
Main
# import the common functions script
. ".\shared\common_functions.ps1"
. ".\shared\get_set_env_vars.ps1"

function Main {
    $envFilePath = ".\.env"
    Set-EnvVariables -FilePath $envFilePath

    Write-Host "Starting sql_user_permissions.ps1 script"
    Confirm-EnvVariables
    Write-Host "Chose a step to proceed:"
    Write-Host "1. Step 1. Checks if SSL encryption is enabled."
    Write-Host "2. Step 2. Configure SQL For TCP"
    Write-Host "3. Step 3. Checks if SQL user has all required privileges on $env:serverInstance"
    Write-Host "4. Step 4. Set up SQL User Account"
    Write-Host "5. Step 5. Configure SQL Server Permissions"
    Write-Host "6. Step 6. Configure SSL For ADD components"
    Write-Host "7. Step 7. Check and configure collation"
    Write-Host "8. Step 8. Configure TLS Certs and Keystores"

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
        default { Write-Host "Invalid choise. Exiting." }
    }
}

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

function Step2 {
    ConfirmAndExecute "Step 2"
    ConfigureSQLForTCP
}

function Step3 {
    ConfirmAndExecute "Step 3"

    $currentSQLUserHasPrivileges = CheckSQLUserPrivileges -serverInstance $env:serverInstance -sqlUser $env:sqlUser

    if ($currentSQLUserHasPrivileges) {
        Write-Host "The current SQL user has all required privileges on $env:serverInstance"
    } else {
        Write-Host "The current SQL user does not have all required privileges on $env:serverInstance"
        # Step 3
        $setUpSqlUser = Read-Host "Do you want to set up the SQL user? (Y/N)"
        if($setUpSqlUser) {
            SetUpSQLUserAccount
            Write-Host "SQL user set up successfully"
        } else {
            Write-Host "SQL user setup skipped."
        }
    }

}
function Step4 {
    ConfirmAndExecute "Step 4"
    SetUpSQLUserAccount
    Write-Host "SQL user set up successfully"
}

function Step5 {
    ConfirmAndExecute "Step 5"
    ConfigureSQLServerPermissions
}
function Step6 {
    ConfirmAndExecute "Step 6"
    ConfigureTLSJava -eclipseIniPath $env:eclipseIniPath
}
function Step7 {
    ConfirmAndExecute "Step 7"
    ConfigureSSLForAdComponents
}
function Step8 {
    ConfirmAndExecute "Step 8"
    #  Configure TLS Certs && KeyStores

    # TODO Generate keypair
    # TODO Create Certificate Signing Request (CSR)
    # TODO Submit CSR to CA
    # TODO  Set up TLS on your server application

    # otherstuff
    $cert = New-SelfSignedCertificate -DnsName $env:dnsName
    Export-CertificateToPfx -Certificate $cert -FilePath $env:certificatePath -Password $env:certificatePassword
    Import-CertificateToKeystore -KeystorePath $env:keystorePath -CertificatePath $env:certificatePath -Password $env:certificatePassword
    Additional-KeystoreConfiguration -KeystorePath $env:keystorePath
}

Main
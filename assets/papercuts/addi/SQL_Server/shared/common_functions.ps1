
function IsSSLEncryptionEnabled {
    param(
        [string]$env:serverInstance
    )

    # Query to check SSL encryption status
    $query = "SELECT value_in_use FROM sys.configurations WHERE name = 'force protocol encryption';"

    # Get SSL encryption status
    $encryptionStatus = Invoke-Sqlcmd -Query $query -ServerInstance $env:serverInstance

    # check if tls is enabled
    if ($encryptionStatus.value_in_use -eq 1) {
        return $true
    } else { return $false }
}
function EnableSSLEncryption {
    Write-Host "Enabling SSL encryption for SQL Server"
    # import the certificate
    $certificate = Import-PfxCertificate -FilePath $env:certificatePath -CertStoreLocation Cert:\LocalMachine\My -Password (ConvertTo-SecureString) -String $env:certificatePassword -AsPlainText -Force

    # Set SQL Server to force encryption
    Invoke-Sqlcmd -Query "Exec sp_configure 'show advanced options', 1; RECONFIGURE; EXEC sp_configure 'force protocol encryption', 1; RECONFIGURE;" -ServerInstance $env:serverInstance

    # Configure SQL Server to use the certificate
    Invoke-Sqlcmd -Query "USE master; CREATE ENDPOINT MySSLEndpoint STATE = STARTED AS TCP (LISTENER_PORT = 1433, LISTENER_IP = ALL) FOR TSQL(ENCRYPTION = REQUIRED, PROVIDER = RSA_AES, CERTIFICATE = ServerCert);" -ServerInstance $env:serverInstance

    # Restart SQL Server service to apply changes
    Write-Host "Restart SQL Server service to apply changes"
    Restart-Services -Name "MYSQLSERVER"  -Force
}
function ConfigureSQLForTCP {
    Write-Host "Configuring SQL Server to accept connections over TCP/IP"

    # enable TCP protocol
    $tcpEnabled = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$env:serverInstance\MSSQLServer\SuperSocketNetLib\TCP" -Name "Enabled" -ErrorAction SilentlyContinue

    if ($tcpEnabled -eq $null -or $tcpEnabled.Enabled -eq 0) {
        Write-Host "Enabling TCP protocol for SQL Server ($env:serverInstance)..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$env:serverInstance\MSSQLServer\SuperSocketNetLib\Tcp" -Name "Enabled" -Value 1
        Write-Host "TCP protocol is already enabled for SQL Server ($env:serverInstance)."
    } else {
        Write-Host "TCP protocol is already enabled for SQL Server"
    }
}

function ConfigureSQLServerPermissions {
    Write-Host "Configuring SQL Server permissions"
}

function ConfigureTLSJava {
    param (
        [string]$eclipseIniPath
    )
    if (NeedsTLSSetup -eclipseIniPath $eclipseIniPath) {
        Write-Host "Configuring TLS...."
        # Add TLS configuration to the eclipse.ini file
        Add-Content -Path $eclipseIniPath -Value "-Dcom.ibm.jsse2.overrideDefaultTLS=true" -Force
        Write-Host "TLS configuration added to $eclipseIniPath."
    } else {
        Write-Host "TLS configuration not needed."
    }
}

function ConfigureSSLForAdComponents {
    Write-Host "Configuring SSL/TLS for AD components"
}

function CheckAndConfigureCollation {
    Write-Host "Checking and configuring SQL Server collation"
}

# function to check SQL user privileges
function CheckSQLUserPrivileges {
    param (
        [string]$env:serverInstance,
        [string]$sqlUser
    )
    # Check if the user has the required privileges
    $query = "SELECT HAS_PERMS_BY_NAME('$sqlUser', 'DATABASE', 'CREATE TABLE') AS CanCreateTable,
                  HAS_PERMS_BY_NAME('$sqlUser', 'DATABASE', 'ALTER ANY TABLE') AS CanAlterTable,
                  HAS_PERMS_BY_NAME('$sqlUser', 'DATABASE', 'DROP TABLE') AS CanDropTable,
                  HAS_PERMS_BY_NAME('$sqlUser', 'DATABASE', 'CREATE INDEX') AS CanCreateIndex,
                  HAS_PERMS_BY_NAME('$sqlUser', 'DATABASE', 'ALTER ANY INDEX') AS CanAlterIndex,
                  HAS_PERMS_BY_NAME('$sqlUser', 'DATABASE', 'DROP INDEX') AS CanDropIndex,
                  HAS_PERMS_BY_NAME('$sqlUser', 'SERVER', 'ALTER ANY LOGIN') AS CanAlterLogin,
                  HAS_PERMS_BY_NAME('$sqlUser', 'SERVER', 'ALTER ANY DATABASE') AS CanAlterDatabase,
                  HAS_PERMS_BY_NAME('$sqlUser', 'SERVER', 'CREATE ANY DATABASE') AS CanCreateDatabase,
                  HAS_PERMS_BY_NAME('$sqlUser', 'SERVER', 'VIEW ANY DATABASE') AS CanViewDatabase;"

    $privileges = Invoke-Sqlcmd -Query $query -ServerInstance $env:serverInstance


    # Display result
    Write-Host "SQL User Privileges for $sqlUser on $env:serverInstance"
    Write-Host "Can Create Table: $($userPrivileges.CanCreateTable)"
    Write-Host "Can Alter Table: $($userPrivileges.CanAlterTable)"
    Write-Host "Can Drop Table: $($userPrivileges.CanDropTable)"
    Write-Host "Can Create Index: $($userPrivileges.CanCreateIndex)"
    Write-Host "Can Alter Index: $($userPrivileges.CanAlterIndex)"
    Write-Host "Can Drop Index: $($userPrivileges.CanDropIndex)"
    Write-Host "Can Alter Login: $($userPrivileges.CanAlterLogin)"
    Write-Host "Can Alter Database: $($userPrivileges.CanAlterDatabase)"
    Write-Host "Can Create Database: $($userPrivileges.CanCreateDatabase)"
    Write-Host "Can View Database: $($userPrivileges.CanViewDatabase)"

    $hasAllPrivileges = $privileges.CanRead -eq 1 -and
            $privileges.CanWrite -eq 1 -and
            $privileges.CanCreateTable -eq 1 -and
            $privileges.CanAlterTable -eq 1 -and
            $privileges.CanDropTable -eq 1 -and
            $privileges.CanCreateIndex -eq 1 -and
            $privileges.CanAlterIndex -eq 1 -and
            $privileges.CanDropIndex -eq 1 -and
            $privileges.CanAlterLogin -eq 1 -and
            $privileges.CanAlterDatabase -eq 1 -and
            $privileges.CanCreateDatabase -eq 1 -and
            $privileges.CanViewDatabase -eq 1

    return $hasAllPrivileges
}

# Functions sets up sql user account and nakes sure the sql user is NOT required to change his password on first login.
function SetUpSQLUserAccount {
    #TODO Resolve
    $queryCreateLogin = "CREATE LOGIN $env:sqlUser WITH PASSWORD = '$env:sqlPassword', CHECK_EXPIRATION = OFF;"

    Invoke-SqlCmd -ServerInstance $env:serverInstance -Query $queryCreateLogin

    $queryGrantPermissions = @"
    USE $env:sqlDatabase;
    CREATE USER $env:sqlUser;
    FOR LOGIN $env:sqlUser;
    GRANT CONNECT SQL TO $env:sqlUser;
    GRANT CREATE PROCEDURE TO $env:sqlUser;
    GRANT CREATE TABLE TO $env:sqlUser;
    GRANT CREATE FUNCTION TO $env:sqlUser;
    GRANT CREATE VIEW TO $env:sqlUser;
    GRANT ALTER ANY DATABASE TO $env:sqlUser;
    GRANT ALTER ANY LOGIN TO $env:sqlUser;
"@

    # Execute the query
    Invoke-Sqlcmd -ServerInstance $env:serverInstance -Database $env:sqlDatabase -Query $queryGrantPermissions;
}

function Get-SqlUsernames {
    param(
        [string] $ServerInstance,
        [string] $Database,
        [string] $SqlUser
    )
    $query = "SELECT name, type_desc FROM sys.database_principals WHERE type_desc=$SqlUser"
    $result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query

    return $result | ForEach-Object {
        $_.name
    }
}

function Get-SqlDatabases {
    param(
        [string] $ServerInstance,
        [string] $Database
    )
    $query = "SELECT name FROM sys.databases"
    $result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query

    return $result | ForEach-Object {
        $_.name
    }
}
function ConfirmAndExecute {
    param(
        [string]$stepName,
        [scriptblock]$scriptBlock
    )

    $confirmation = Read-Host "Do you want to proceed with $stepName? (Y/N)"

    if ($confirmation -eq 'Y') {
        & $scriptBlock
        Write-host "$stepName completed."
    }  else {
        Write-Host "$stepName skipped."
    }
}
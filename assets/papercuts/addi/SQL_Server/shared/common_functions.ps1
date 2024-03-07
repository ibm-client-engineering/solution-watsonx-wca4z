
function IsSSLEncryptionEnabled {
    param(
        [string]$env:serverInstance
    )

    # Query to check SSL encryption status
    $query = "SELECT value_in_use FROM sys.configurations WHERE name = 'force protocol encryption';"

    # Get SSL encryption status
    $encryptionStatus = Invoke-Sqlcmd -Query $query -ServerInstance "."

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
        [string]$serverInstance,
        [string]$sqlUser,
        [string]$sqlPassword,
        [string]$sqlDatabase
    )
    Write-Host "phi" $sqlDatabase

    # Check if the user has the required privileges
    $query = "SELECT HAS_PERMS_BY_NAME('master', 'DATABASE', 'CREATE TABLE') AS CanCreateTable,
                  HAS_PERMS_BY_NAME('master', 'DATABASE', 'DROP TABLE') AS CanDropTable,
                  HAS_PERMS_BY_NAME('MSSQL', 'SERVER', 'ALTER ANY LOGIN') AS CanAlterLogin,
                  HAS_PERMS_BY_NAME('MSSQL', 'SERVER', 'ALTER ANY DATABASE') AS CanAlterDatabase,
                  HAS_PERMS_BY_NAME('MSSQL', 'SERVER', 'CREATE ANY DATABASE') AS CanCreateDatabase,
                  HAS_PERMS_BY_NAME('MSSQL', 'SERVER', 'VIEW ANY DATABASE') AS CanViewDatabase;"
    Write-Host "alpha1" $env:sqlPassword
    Write-Host "alpha2" $sqlPassword
    Write-Host "alpha2" $sqlDatabase

    $privileges = Invoke-Sqlcmd -ServerInstance "." -Username "my_user" -Password $env:sqlPassword -Query $query
    Write-Host "phi" $privileges

    # Display result
    Write-Host "SQL User Privileges for $sqlUser on $serverInstance"
    Write-Host "Can Create Table: $($privileges.CanCreateTable)"
#    Write-Host "Can Alter Table: $($privileges.CanAlterTable)"
#    Write-Host "Can Drop Table: $($privileges.CanDropTable)"
#    Write-Host "Can Create Index: $($privileges.CanCreateIndex)"
#    Write-Host "Can Alter Index: $($privileges.CanAlterIndex)"
#    Write-Host "Can Drop Index: $($privileges.CanDropIndex)"
    Write-Host "Can Alter Login: $($privileges.CanAlterLogin)"
    Write-Host "Can Alter Database: $($privileges.CanAlterDatabase)"
    Write-Host "Can Create Database: $($privileges.CanCreateDatabase)"
    Write-Host "Can View Database: $($privileges.CanViewDatabase)"

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
    Write-Host "env sql user" $env:sqlUser
    Write-Host "env sql password" $env:sqlPassword

    $queryCreateLogin = "CREATE LOGIN $env:sqlUser WITH PASSWORD = '$env:sqlPassword', CHECK_EXPIRATION = OFF;"
    Invoke-SqlCmd -ServerInstance "." -Query $queryCreateLogin

    $queryGrantPermissions = @"
    USE $env:sqlDatabase;
    CREATE USER $env:sqlUser FOR LOGIN $env:sqlUser;
    GRANT CONNECT SQL TO $env:sqlUser;
    GRANT CREATE PROCEDURE TO $env:sqlUser;
    GRANT CREATE ANY DATABASE TO $env:sqlUser;
    GRANT CREATE TABLE TO $env:sqlUser;
    GRANT CREATE FUNCTION TO $env:sqlUser;
    GRANT CREATE VIEW TO $env:sqlUser;
    GRANT ALTER ANY DATABASE TO $env:sqlUser;
    GRANT ALTER ANY LOGIN TO $env:sqlUser;
"@

    # Execute the query
    Invoke-Sqlcmd -ServerInstance "." -Query $queryGrantPermissions;
}

# Invoke-SqlCmd -ServerInstance MSSQLSERVER -Query $queryCreateLogin
## Default users dbo, guest, information_schema, sys, MS_PolicyEventProcessingLogin
## current sql user is dbo aka database owner
function Get-SqlUsernames {
    param(
        [string] $ServerInstance,
        [string] $Database,
        [string] $SqlUser,
        [string] $SqlPassword
    )
    #$queryCreateLogin = "CREATE LOGIN $sqlUser WITH PASSWORD = '$env:sqlPassword', CHECK_EXPIRATION = OFF;"
    #Invoke-SqlCmd -ServerInstance $env:serverInstance -Query $queryCreateLogin

    ##  Invoke-Sqlcmd -ServerInstance "." -Database "master" -Query "SELECT name FROM sys.databases;"

    $query = "SELECT name, type_desc FROM sys.database_principals"
    $result = Invoke-Sqlcmd -ServerInstance "." -Query $query

    return $result | ForEach-Object {
        $_.name
    }
}

## SQLCMD -s YourServerInstance -d master -U Username -P password, -Q "SELECT name FROM sys.databases" ;
## Invoke-Sqlcmd -ServerInstance . -Database "master" -Query "SELECT name FROM sys.databases;"
function createDatabase {
    $query_create_db = "CREATE DATABASE my_db";
    Invoke-Sqlcmd -ServerInstance "." -Query $query_create_db
}

## Default databases master, tempdb, model and msdb
function Get-SqlDatabases {
    param(
        [string] $ServerInstance,
        [string] $Database,
        [string] $SqlUser,
        [string] $SqlPassword
    )
    #$queryCreateLogin = "CREATE LOGIN $sqlUser WITH PASSWORD = '$env:sqlPassword', CHECK_EXPIRATION = OFF;"
    #Invoke-SqlCmd -ServerInstance $env:serverInstance -Query $queryCreateLogin

    $query = "SELECT name FROM sys.databases"
    $result = Invoke-Sqlcmd -ServerInstance "." -Query $query

    return $result | ForEach-Object {
        $_.name
    }
}
# Test-NetConnection -ComputerName MSSQLSERVER -Port 1433
# Get-NetFirewallRule -DisplayName "SQL Server*"
function ConfirmAndExecute {
    param(
        [string]$stepName,
        [scriptblock]$scriptBlock
    )

    $confirmation = Read-Host "Do you want to proceed with $stepName? (Y/N)"

    if ($confirmation -eq 'Y') {
        & $scriptBlock
        Write-Host "$stepName completed."
    }  else {
        Write-Host "$stepName skipped."
    }
}
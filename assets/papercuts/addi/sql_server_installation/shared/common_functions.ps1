
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
# function to check SQL user privileges
function CheckSQLUserPrivileges {
    param (
        [string]$serverInstance,
        [string]$sqlUser,
        [string]$sqlPassword,
        [string]$sqlDatabase
    )

    # Check if the user has the required privileges
    $query = "SELECT HAS_PERMS_BY_NAME('master', 'DATABASE', 'CREATE TABLE') AS CanCreateTable,
                  HAS_PERMS_BY_NAME('master', 'DATABASE', 'DROP TABLE') AS CanDropTable,
                  HAS_PERMS_BY_NAME('MSSQL', 'SERVER', 'ALTER ANY LOGIN') AS CanAlterLogin,
                  HAS_PERMS_BY_NAME('MSSQL', 'SERVER', 'ALTER ANY DATABASE') AS CanAlterDatabase,
                  HAS_PERMS_BY_NAME('MSSQL', 'SERVER', 'CREATE ANY DATABASE') AS CanCreateDatabase,
                  HAS_PERMS_BY_NAME('MSSQL', 'SERVER', 'VIEW ANY DATABASE') AS CanViewDatabase;"

    $privileges = Invoke-Sqlcmd -ServerInstance "." -Username $env:sqlUser -Password $env:sqlPassword -Query $query

    # Display result
    Write-Host "SQL User Privileges for $sqlUser on $serverInstance"
    Write-Host "Can Create Table: $($privileges.CanCreateTable)"
    Write-Host "Can Alter Login: $($privileges.CanAlterLogin)"
    Write-Host "Can Alter Database: $($privileges.CanAlterDatabase)"
    Write-Host "Can Create Database: $($privileges.CanCreateDatabase)"
    Write-Host "Can View Database: $($privileges.CanViewDatabase)"

    $hasAllPrivileges = $privileges.CanCreateTable -eq 1 -and
            $privileges.CanAlterLogin -eq 1 -and
            $privileges.CanAlterDatabase -eq 1 -and
            $privileges.CanCreateDatabase -eq 1 -and
            $privileges.CanViewDatabase -eq 1

    return $hasAllPrivileges
}

# Functions sets up sql user account and nakes sure the sql user is NOT required to change his password on first login.
function SetUpSQLUserAccount {


    $queryCreateLogin = "IF NOT EXISTS 
                            (SELECT name  
                            FROM master.sys.server_principals
                            WHERE name = '$env:sqlUser')
                        BEGIN
                            CREATE LOGIN $env:sqlUser WITH PASSWORD = '$env:sqlPassword', CHECK_EXPIRATION = OFF;
                        END"

    Invoke-SqlCmd -ServerInstance "." -Query $queryCreateLogin

    $queryCheckUserExists = "USE $env:sqlDatabase; SELECT * FROM sys.database_principals WHERE name = '$env:sqlUser'"
    $checkResult =  Invoke-SqlCmd -ServerInstance "." -Query $queryCheckUserExists

    if (!$checkResult) 
    {
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

}

## Default users dbo, guest, information_schema, sys, MS_PolicyEventProcessingLogin
## current sql user is dbo aka database owner
function Get-SqlUsernames {
    param(
        [string] $ServerInstance,
        [string] $Database,
        [string] $SqlUser,
        [string] $SqlPassword
    )
    $query = "SELECT name, type_desc FROM sys.database_principals"
    $result = Invoke-Sqlcmd -ServerInstance "." -Query $query

    return $result | ForEach-Object {
        $_.name
    }
}

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

function InstallODBCDriver {
    $url = "https://go.microsoft.com/fwlink/?linkid=2249004"
    $outputPath = "./msodbcsql.msi"

    if (-not (Test-Path $outputPath)) {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Start-Process -FilePath $outputPath -Wait
    }
}
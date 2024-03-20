# import the common functions script
. ".\shared\common_functions.ps1"
. ".\shared\common_functions_tls.ps1"
. ".\shared\get_set_env_vars.ps1"


function Main {
    $envFilePath = ".\.env"
    Set-EnvVariables -FilePath $envFilePath

    Write-Host "Starting sql_user_setup.ps1 script"
    Confirm-EnvVariables

    #Configure TCP with SQL (Step 2)
    ConfigureSQLForTCP

    #Create user account (Step 3)
    SetUpSQLUserAccount
    Write-Host "SQL user set up successfully"

    #Set user privileges (Step 4)
    $currentSQLUserHasPrivileges = CheckSQLUserPrivileges -serverInstance $env:serverInstance -sqlUser $env:sqlUser -sqlPassword $env:sqlPassword -sqlDatabase $env:sqlDatabase

    if ($currentSQLUserHasPrivileges) {
    Write-Host "The current SQL user has all required privileges on $env:serverInstance"
    } else {
        Write-Host "The current SQL user does not have all required privileges on $env:serverInstance"
        # Step 3
        $setUpSqlUser = Read-Host "Do you want to set up the SQL user $env:sqlUser? (Y/N)"
        if($setUpSqlUser -eq "y") {
            SetUpSQLUserAccount
            Write-Host "SQL user set up successfully"
        } else {
            Write-Host "SQL user setup skipped."
        }
    }

    #Configure TLS Java (Step 5)
    ConfigureTLSJava -eclipseIniPath $env:eclipseIniPath


    #Check usernames
    $usernames = Get-SqlUsernames -ServerInstance $env:serverInstance -Database $env:sqlDatabase -SqlUser $env:sqlUser -SqlPassword $env:sqlPassword
    Write-Output "usernames:" $usernames

    #Check Databases
    $databases = Get-SqlDatabases -ServerInstance $env:serverInstance -Database $env:sqlDatabase -SqlUser $env:sqlUser -SqlPassword $env:sqlPassword
    Write-Output "databases:" $databases
}
Main
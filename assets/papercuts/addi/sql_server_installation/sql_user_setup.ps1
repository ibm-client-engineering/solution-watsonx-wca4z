# import the common functions script
. ".\shared\common_functions.ps1"
. ".\shared\get_set_env_vars.ps1"


function Main {
    $envFilePath = ".\.env"
    Set-EnvVariables -FilePath $envFilePath

    Write-Host "Starting sql_user_setup.ps1 script"

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
        SetUpSQLUserAccount
        Write-Host "SQL user set up successfully"
    }


    #Check usernames
    $usernames = Get-SqlUsernames -ServerInstance $env:serverInstance -Database $env:sqlDatabase -SqlUser $env:sqlUser -SqlPassword $env:sqlPassword
    Write-Output "usernames:" $usernames

    #Check Databases
    $databases = Get-SqlDatabases -ServerInstance $env:serverInstance -Database $env:sqlDatabase -SqlUser $env:sqlUser -SqlPassword $env:sqlPassword
    Write-Output "databases:" $databases
}
Main
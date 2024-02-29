
function Set-EnvVariables {
    param (
        [string]$FilePath
    )

    $envFileContent = Get-Content -Path $FilePath -Raw

    $envFileContent -split " n" | ForEach-Object {

        #split each line into key and value
        $key, $value = $_ -split '=', 2

        # set the environment variable
        [System.Environment]::SetEnvironmentVariable(($key, $value, [System.EnvironmentVariableTarget]::Process))
    }
}

function Get-AllEnvVariables {
    Get-ChildItem env: | ForEach-Object {
        "$($_.Name) = $($_.Value)"
    }
}

function Confirm-EnvVariables {
    $allEnvVariables = Get-AllEnvVariables
    foreach ($envVar in $allEnvVariables) {
        $value = [System.Environment]::GetEnvironmentVariable($envVar,[System.EnvironmentVariableTarget]::Process)
        if ($null -eq $value) {
            Write-Host "Environment variable '$envVar' is not set."
        } else {
            $confirmation = Read-Host "Is this the vlaue of '$envVar' correct? (Y/N)"
            if ($confirmation -ne 'Y') {
                Write-Host "User confirmed that the value of '$envVar' is not correct. Please update .env file"
            }
        }

    }
}
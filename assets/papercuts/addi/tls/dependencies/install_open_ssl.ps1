function InstallOpenSSL {
    if (-not (Test-Path -Path "C:\OpenSSL-Win6\bin\openssl.exe")) {
        Write-Host "OpenSSL is not installed. Installing"
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco install openssl.light
    }
    else {
        Write-Host "OpenSSL is already installed. Skipping"
    }
}
InstallOpenSSL
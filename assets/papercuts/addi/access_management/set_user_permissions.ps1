#Function to set folder permissions
function Set-FolderPermission {
    param (
        [string]$folderPath,
        [string]$user,
        [string]$access
    )

    $acl = Get-Acl $folderPath
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $access, "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl -Path $folderPath -AclObject $acl
}

function Test-DirectoriesExist {
    param (
        [string[]]$directories
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir -PathType Container)) {
            Write-Warning "Warning: Directory '$dir' not found. Skipping"
        }
    }
}


#Function get and display current permissions
function Get-CurrentPermissions {
    param (
        [string[]]$directories
    )

    foreach ($dir in $directories) {
        $acl = Get-Acl $dir
        Write-Host "Current permissions for $dir"
        foreach ($ace in $acl.Access) {
            Write-Host "   - User: $($ace.IdentityReference), Access: $($ace.FileSystemRights)"
        }
        Write-Host "------------------------"
    }
}

# Ask uuser for base path
$basePath = Read-Host "Enter the base path where ADDI is installed (e.g., /path/to)"

# Define folder paths and permissions
$folders = @(
    "$basePath/AnalyzeClientEclipseInstallation",
    "$basePath/AnalyzeClientWorkspace",
    "$basePath/BuildClientProjects",
    "$basePath/BuildClientConfig",
    "$basePath/BuildClientSourceCode",
    "$basePath/BatchServerIndexes",
    "$basePath/BatchServerInstallation",
    "$basePath/BatchServerProjects",
    "$basePath/FileServiceSourceFiles",
    "$basePath/ManualResolutionsServiceJournalFiles",
    "$basePath/SearchServiceIndexFiles"
)

# Check if directories exist
Test-DirectoriesExist -directories $folders 

# Get current logged-in user
$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().currentUserName
$user = $currentUserName.SubString($currentUserName.IndexOf("\") + 1) # extract username

# Define Access
$access = "ReadAndWrite"

# set permissions for each folder
foreach ($folder in $folders) {
    Set-FolderPermissions -folderPath $folder -user $user -access $access
}

Get-CurrentPermissions -directories $folders

Write-Host "Permissions set successfully"

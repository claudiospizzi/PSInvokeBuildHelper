
# Build information
Write-Host -ForegroundColor 'DarkYellow' -Object ''
Write-Host -ForegroundColor 'DarkYellow' -Object 'IMPORTANT NOTE'
Write-Host -ForegroundColor 'DarkYellow' -Object '**************'
Write-Host -ForegroundColor 'DarkYellow' -Object 'You are currently using the build helper tasks of the InvokeBuildHelper module'
Write-Host -ForegroundColor 'DarkYellow' -Object 'against itself. There are some limitations in this case: The Release task is'
Write-Host -ForegroundColor 'DarkYellow' -Object 'not supported. Please use the following sub-tasks:'
Write-Host -ForegroundColor 'DarkYellow' -Object 'PS C:\> Invoke-Build'
Write-Host -ForegroundColor 'DarkYellow' -Object 'PS C:\> Invoke-Build -Task "Approve"'
Write-Host -ForegroundColor 'DarkYellow' -Object 'PS C:\> Invoke-Build -Task "Gallery"'
Write-Host -ForegroundColor 'DarkYellow' -Object 'PS C:\> Invoke-Build -Task "Repository"'
Write-Host -ForegroundColor 'DarkYellow' -Object ''

# Import module
Get-Module InvokeBuildHelper | Remove-Module
Import-Module .\InvokeBuildHelper\InvokeBuildHelper.psd1

# Import build tasks
. InvokeBuildHelperTasks

# Build configuration
$IBHConfig.VerifyTask.Enabled   = $false
$IBHConfig.RepositoryTask.Token = Use-VaultSecureString -TargetName 'GitHub Token (claudiospizzi)'
$IBHConfig.GalleryTask.Token    = Use-VaultSecureString -TargetName 'PowerShell Gallery Key (claudiospizzi)'

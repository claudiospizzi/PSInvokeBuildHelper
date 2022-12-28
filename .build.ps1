
# Import module
Get-Module InvokeBuildHelper | Remove-Module
Import-Module .\InvokeBuildHelper\InvokeBuildHelper.psd1

# Import build tasks
. InvokeBuildHelperTasks

# Build configuration
$IBHConfig.RepositoryTask.TokenCallback = { Use-VaultSecureString -TargetName 'GitHub Token (claudiospizzi)' }
$IBHConfig.GalleryTask.TokenCallback    = { Use-VaultSecureString -TargetName 'PowerShell Gallery Key (claudiospizzi)' }

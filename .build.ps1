
# Import module
Get-Module InvokeBuildHelper | Remove-Module
Import-Module .\InvokeBuildHelper\InvokeBuildHelper.psd1

# Import build tasks
. InvokeBuildHelperTasks

# Build configuration
$IBHConfig.RepositoryTask.Token = Get-VaultSecureString -TargetName 'GitHub Token (claudiospizzi)'
$IBHConfig.GalleryTask.Token    = Get-VaultSecureString -TargetName 'PowerShell Gallery Key (claudiospizzi)'

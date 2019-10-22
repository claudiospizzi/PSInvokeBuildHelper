
# Import module
Get-Module InvokeBuildHelper | Remove-Module
Import-Module .\InvokeBuildHelper\InvokeBuildHelper.psd1

# Import build tasks
. InvokeBuildHelperTasks

# Build configuration
$IBHConfig.VerifyTask.Enabled   = $false
$IBHConfig.RepositoryTask.Token = Use-VaultSecureString -TargetName 'GitHub Token (claudiospizzi)'
$IBHConfig.GalleryTask.Token    = Use-VaultSecureString -TargetName 'PowerShell Gallery Key (claudiospizzi)'

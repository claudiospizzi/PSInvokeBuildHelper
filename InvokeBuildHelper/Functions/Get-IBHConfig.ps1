<#
    .SYNOPSIS
        Get the build configuration.

    .DESCRIPTION
        Return the build configuration object with default properties. Some
        properties are calculated based on the module structure.

    .OUTPUTS
        InvokeBuildHelper.Config. Invoke build helper configuration object.

    .EXAMPLE
        PS C:\> Get-IBHConfig -BuildRoot 'C:\GitHub\InvokeBuildHelper'
        Get the build configuration.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHConfig
{
    [CmdletBinding()]
    param
    (
        # Root path of the build script.
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot
    )

    $config = [PSCustomObject] @{
        PSTypeName          = 'InvokeBuildHelper.Config'

        BuildRoot           = $BuildRoot
        ModuleName          = Get-BuildModuleName -BuildRoot $BuildRoot

        VerifyTask          = [PSCustomObject] @{
            Enabled             = $true
        }

        AnalyzeTask         = [PSCustomObject] @{
            ScriptAnalyzerRules = Get-ScriptAnalyzerRule
        }

        ApproveTask         = [PSCustomObject] @{
            Enabled             = $true
            BranchName          = 'master'
        }

        RepositoryTask      = [PSCustomObject] @{
            Enabled             = $true
            Type                = 'GitHub'
            User                = Get-IBHGitHubUser
            Name                = Get-IBHGitHubRepo
            Token               = [System.Security.SecureString]::new()
        }

        GalleryTask         = [PSCustomObject] @{
            Enabled             = $true
            User                = Get-IBHGitHubUser
            Name                = 'PSGallery'
            Token               = [System.Security.SecureString]::new()
        }

        LocalDebugTask      = [PSCustomObject] @{
            ModulePath          = ($Env:PSModulePath -split ';') -like "$Home*" | Select-Object -First 1
        }
    }

    return $config
}

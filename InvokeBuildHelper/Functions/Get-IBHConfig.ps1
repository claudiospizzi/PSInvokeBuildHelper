<#
    .SYNOPSIS
        Get the build configuration.

    .DESCRIPTION
        Return the build configuration object with default and calculated
        configuration properties.
#>
function Get-IBHConfig
{
    [CmdletBinding()]
    param
    (
        # Root path of the build script
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot
    )

    $config = [PSCustomObject] @{
        BuildRoot            = $BuildRoot
        ModuleName           = Get-BuildModuleName -BuildRoot $BuildRoot

        VerifyTask           = [PSCustomObject] @{
            Enabled              = $true
        }

        AnalyzeTask          = [PSCustomObject] @{
            ScriptAnalyzerRules  = Get-ScriptAnalyzerRule
        }

        ApproveTask          = [PSCustomObject] @{
            Enabled              = $true
            BranchName           = 'master'
        }

        RepositoryTask       = [PSCustomObject] @{
            Enabled              = $true
            Type                 = 'GitHub'
            Name                 = Get-IBHGitHubRepoName
            Token                = ''
        }

        GalleryTask          = [PSCustomObject] @{
            Enabled              = $true
            Name                 = 'PSGallery'
            Token                = ''
        }
    }

    return $config
}

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
        https://github.com/claudiospizzi/PSInvokeBuildHelper
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
        SolutionName        = Get-BuildSolutionName -BuildRoot $BuildRoot

        VerifyTask          = [PSCustomObject] @{
            Enabled             = $true
            InvokeBuildVersion  = '5.5.5'
            ModulePackageUrl    = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='InvokeBuildHelper'"
        }

        SchemaTask          = [PSCustomObject] @{
            TextFileExtension   = '.gitignore', '.gitattributes', '.ps1', '.psm1', '.psd1', '.ps1xml', '.txt', '.xml', '.cmd', '.json', '.md'
            ExcludePath         = @()
        }

        AnalyzerTestTask    = [PSCustomObject] @{
            ScriptAnalyzerRules = Get-ScriptAnalyzerRule # | Where-Object { $_.RuleName -notin 'PSReviewUnusedParameter' } // 09.12.2022 Removed
            ExcludePath         = @()
        }

        ApproveTask         = [PSCustomObject] @{
            Enabled             = $true
            BranchName          = Get-IBHGitBranchPrimary
        }

        RepositoryTask      = [PSCustomObject] @{
            Enabled             = $true
            Type                = 'GitHub'
            User                = Get-IBHGitHubUser
            Name                = Get-IBHGitHubRepo
            Token               = $null
            TokenCallback       = $null
        }

        GalleryTask         = [PSCustomObject] @{
            Enabled             = $true
            User                = Get-IBHGitHubUser
            Name                = 'PSGallery'
            Token               = $null
            TokenCallback       = $null
        }

        ZipFileTask         = [PSCustomObject] @{
            Enabled             = $true
        }

        DeployTask          = [PSCustomObject] @{
            ModulePaths         = 'PowerShell', 'WindowsPowerShell' | ForEach-Object { '{0}\{1}\Modules' -f [System.Environment]::GetFolderPath('MyDocuments'), $_ } | Where-Object { Test-Path -Path $_ }
        }
    }

    return $config
}

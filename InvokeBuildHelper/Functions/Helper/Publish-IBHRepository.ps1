<#
    .SYNOPSIS
        Publish the module to the repository releases.

    .DESCRIPTION
        Use REST API calls to the GitHub api to create a new release based on
        the tag and upload the module ZIP as artifact.

    .OUTPUTS
        None. No output if successful or an exception in case of an error.

    .EXAMPLE
        PS C:\> Publish-IBHRepository -BuildRoot 'C:\GitHub\InvokeBuildHelper' -ModuleName 'InvokeBuildHelper' -ModuleVersion '1.0.0' -RepositoryType = 'GitHub' -RepositoryUser = 'claudiospizzi' -RepositoryName = 'InvokeBuildHelper' -RepositoryToken = $token
        Publish the module InvokeBuildHelper version 1.0.0 to the GitHub
        releases.

    .LINK
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>
function Publish-IBHRepository
{
    [CmdletBinding()]
    param
    (
        # Root path of the project.
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot,

        # Name of the module.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName,

        # Version to publish.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion,

        # Repository type.
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryType,

        # Repository user.
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryUser,

        # Repository name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryName,

        # Repository token.
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]
        $RepositoryToken
    )

    # Create output folder
    New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Out-Null

    $releaseNotes = Get-IBHModuleReleaseNote -BuildRoot $BuildRoot -ModuleVersion $ModuleVersion

    $artifactName = '{0}-{1}.zip' -f $ModuleName, $ModuleVersion
    $artifactPath = '{0}\out\{1}-{2}.zip' -f $BuildRoot, $ModuleName, $ModuleVersion

    # Create ZIP file
    Compress-Archive -Path "$BuildRoot\$ModuleName" -DestinationPath $artifactPath -Verbose:$VerbosePreference -Force

    if ($RepositoryType -eq 'GitHub')
    {
        $publishGitHubReleaseSplat = @{
            RepositoryUser = $RepositoryUser
            RepositoryName = $RepositoryName
            Token          = $RepositoryToken
            ModuleName     = $ModuleName
            ModuleVersion  = $ModuleVersion
            ReleaseNote    = $releaseNotes
        }
        $release = Publish-IBHGitHubRelease @publishGitHubReleaseSplat

        $publishGitHubArtifactSplat = @{
            RepositoryUser = $RepositoryUser
            RepositoryName = $RepositoryName
            Token          = $RepositoryToken
            ReleaseId      = $release.Id
            Name           = $artifactName
            Path           = $artifactPath
        }
        Publish-IBHGitHubArtifact @publishGitHubArtifactSplat | Out-Null
    }
    else
    {
        Write-Warning "Repository type '$RepositoryType' not supported, skip repository publish!"
    }
}

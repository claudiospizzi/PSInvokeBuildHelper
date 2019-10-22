<#
    .SYNOPSIS
        Publish the module to the repository releases.

    .DESCRIPTION
        .

    .OUTPUTS
        None. No output if successful or an exception in case of an error.

    .EXAMPLE
        PS C:\> .
        .

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
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
    Compress-Archive -Path "$BuildRoot\$ModuleName" -DestinationPath $artifactPath -Verbose:$VerbosePreference

    $release = Publish-IBHGitHubRelease -RepoName $RepositoryName -Token $RepositoryToken -ModuleName $ModuleName -ModuleVersion $ModuleVersion -ReleaseNote $releaseNotes

    Publish-IBHGitHubArtifact -RepoName $RepositoryName -Token $RepositoryToken -ReleaseId $release.Id -Name $artifactName -Path $artifactPath | Out-Null
}

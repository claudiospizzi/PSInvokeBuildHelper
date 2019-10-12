<#
    .SYNOPSIS
        Publish the module to the PowerShell Gallery.

    .DESCRIPTION
        Use the build-in Publish-Module command to publish a new module version
        including the release notes.
#>
function Publish-IBHGallery
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

        # Gallery name.
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $GalleryUser,

        # Gallery name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $GalleryName,

        # Gallery token.
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]
        $GalleryToken
    )

    $releaseNotes = Get-IBHModuleReleaseNote -BuildRoot $BuildRoot -ModuleVersion $ModuleVersion

    if ($GalleryToken.Length -eq 0)
    {
        if (-not [System.String]::IsNullOrEmpty($GalleryUser))
        {
            $targetName = 'IBH {0} Token ({1})' -f $GalleryName, $GalleryUser
        }
        else
        {
            $targetName = 'IBH {0} Token ({1})' -f $GalleryName, $ModuleName
        }

        $GalleryToken = Use-VaultSecureString -TargetName $targetName
    }

    try
    {
        $token = $GalleryToken | Unprotect-SecureString

        Publish-Module -Path "$BuildRoot\$ModuleName" -Repository $GalleryName -NuGetApiKey $token -ReleaseNotes $releaseNotes
    }
    finally
    {
        Remove-Variable -Name 'token' -Force
    }
}

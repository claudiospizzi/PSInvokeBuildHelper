<#
    .SYNOPSIS
        Test if the module version exists as tag on the git origin repository.

    .DESCRIPTION
        Use the 'git ls-remote origin' command to get the desired tag on the
        origin repository. If the module version is in the tag list, the
        command will return $true, else $false is returned.

    .OUTPUTS
        System.Boolean. The test result.

    .EXAMPLE
        PS C:\> Test-IBHGitRemoteTag -ModuleVersion '1.0.0'
        Test if the version 1.0.0 tag is on the git origin repository.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Test-IBHGitRemoteTag
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        # The version to test.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion
    )

    # Returns the entry of the remote tag or $null if it does not exists
    $tag = git ls-remote origin "refs/tags/$ModuleVersion"

    $result = $null -ne $tag -and $tag -match '^[0-9a-f]{40}\s*refs\/tags\/.*$'

    return $result
}

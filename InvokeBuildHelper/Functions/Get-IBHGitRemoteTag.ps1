<#
    .SYNOPSIS
        Return the gut remote tag.

    .DESCRIPTION
        This function will return the specified module version as tag, if it was
        found in the remote repo. If not, it will return an empty string.
#>
function Get-IBHGitRemoteTag
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        # The version to check.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion
    )

    $tag = git ls-remote origin "refs/tags/$ModuleVersion"

    if ($null -ne $tag -and $tag -match '^[0-9a-f]{40}\s*refs\/tags\/(?<Tag>.*)$')
    {
        return $Matches['Tag']
    }
    else
    {
        return ''
    }
}

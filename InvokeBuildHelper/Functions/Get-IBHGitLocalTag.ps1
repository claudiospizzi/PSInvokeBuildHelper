<#
    .SYNOPSIS
        Get the current tag.

    .DESCRIPTION
        Return the name of the current tag. It will be combined with a commit
        hash if the latest commit is no tagged.
#>
function Get-IBHGitLocalTag
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $tag = git describe --tags

    return $tag
}

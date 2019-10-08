<#
    .SYNOPSIS
        Return the current branch name.

    .DESCRIPTION
        Use the git command to evaluate on which branch we are currently.
#>
function Get-IBHGitBranch
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $branch = git rev-parse --abbrev-ref HEAD

    return $branch
}

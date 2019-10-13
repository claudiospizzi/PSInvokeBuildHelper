<#
    .SYNOPSIS
        Return the current branch name.

    .DESCRIPTION
        Use the git command to evaluate which branch is currently checked out.

    .OUTPUTS
        System.String

    .EXAMPLE
        PS C:\> Get-IBHGitBranch
        Get the current checked out branch.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHGitBranch
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $branch = git rev-parse --abbrev-ref HEAD

    return $branch
}

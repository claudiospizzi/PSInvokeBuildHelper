<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
#>
function Get-IBHGitBranch
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $branch = git rev-parse --abbrev-ref HEAD

    return $branch
}

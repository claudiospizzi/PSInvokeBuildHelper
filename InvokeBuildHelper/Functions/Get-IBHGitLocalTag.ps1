<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
#>
function Get-IBHGitLocalTag
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $tag = git describe --tags

    return $tag
}

<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
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

    if ($null -eq $tag -and $tag -notlike "*refs/tags/$ModuleVersion")
    {
        return ''
    }
    else
    {
        return $tag
    }
}

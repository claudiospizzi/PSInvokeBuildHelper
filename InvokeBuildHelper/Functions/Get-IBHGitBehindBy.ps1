<#
    .SYNOPSIS
        Check if the git local repo is behind of the origin repo.

    .DESCRIPTION
        Return the number of commits behind of the origin repo. It will return
        0, if we are not behind.

    .OUTPUTS
        System.Int32

    .EXAMPLE
        PS C:\> Get-IBHGitBehindBy
        Return the number of commits behind by the origin repo.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHGitBehindBy
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param ()

    $status = git -c core.quotepath=false -c color.status=false status -uno --short --branch
    $status = $status -join "`n"

    $behindBy = 0
    if ($status -match '\[(?:ahead (?<ahead>\d+))?(?:, )?(?:behind (?<behind>\d+))?(?<gone>gone)?\]')
    {
        if ($null -ne $Matches -and $Matches.Keys -contains 'behind')
        {
            $behindBy = [System.Int32] $Matches['behind']
        }
    }

    return $behindBy
}

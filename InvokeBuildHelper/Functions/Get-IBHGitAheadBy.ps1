<#
    .SYNOPSIS
        Check if the git local repo is ahead of the origin repo.

    .DESCRIPTION
        Return the number of commits ahead of the origin repo. It will return 0,
        if we are not ahead.

    .OUTPUTS
        System.Int32

    .EXAMPLE
        PS C:\> Get-IBHGitAheadBy
        Return the number of commits ahead by the origin repo.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHGitAheadBy
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param ()

    $status = git -c core.quotepath=false -c color.status=false status -uno --short --branch
    $status = $status -join "`n"

    $aheadBy = 0
    if ($status -match '\[(?:ahead (?<ahead>\d+))?(?:, )?(?:behind (?<behind>\d+))?(?<gone>gone)?\]')
    {
        if ($null -ne $Matches -and $Matches.Keys -contains 'ahead')
        {
            $aheadBy = [System.Int32] $Matches['ahead']
        }
    }

    return $aheadBy
}

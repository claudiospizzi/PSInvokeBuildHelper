<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
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

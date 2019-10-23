<#
    .SYNOPSIS
        Check if the git local repository is ahead of the origin repository.

    .DESCRIPTION
        Return the number of commits ahead of the origin repository. It will
        return 0, if we are not ahead.

    .OUTPUTS
        System.Int32. Number of commits ahead.

    .EXAMPLE
        PS C:\> Get-IBHGitAheadBy
        Return the number of commits ahead by the origin repository.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHGitAheadBy
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        # Root path of the git repository.
        [Parameter(Mandatory = $false)]
        [System.String]
        $Path
    )

    try
    {
        # Switch to the desired location, if specifed
        if ($PSBoundParameters.ContainsKey('Path'))
        {
            $locationStackName = [System.Guid]::NewGuid().Guid
            Push-Location -Path $Path -StackName $locationStackName
        }

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
    finally
    {
        # Go back to the original location
        if ($PSBoundParameters.ContainsKey('Path'))
        {
            Pop-Location -StackName $locationStackName
        }
    }
}

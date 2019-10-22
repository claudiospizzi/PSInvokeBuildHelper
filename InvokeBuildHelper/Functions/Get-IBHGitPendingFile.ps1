<#
    .SYNOPSIS
        Check if the git local repo has pending files in index or working.

    .DESCRIPTION
        Return the number of files which are pending. Pending files are part of
         the index but not commited yet or even untracked but not ignored.

    .OUTPUTS
        System.Int32. Number of pending files.

    .EXAMPLE
        PS C:\> Get-IBHGitPendingFile
        Return the number of pending files in the current working directory.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHGitPendingFile
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        # Root path of the git repo.
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

        $pending = git -c core.quotepath=false -c color.status=false status --short --branch

        $pendingCount = $pending.Count - 1
        if ($pendingCount -lt 0)
        {
            Write-Warning "Pending file count is $pendingCount but should not be less than 0!"
            $pendingCount = 0
        }

        return $pendingCount
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

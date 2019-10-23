<#
    .SYNOPSIS
        Return the current branch name.

    .DESCRIPTION
        Use the git command to evaluate which branch is currently checked out.

    .OUTPUTS
        System.String. Git repository branch name.

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

        $branch = git rev-parse --abbrev-ref HEAD

        return $branch
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

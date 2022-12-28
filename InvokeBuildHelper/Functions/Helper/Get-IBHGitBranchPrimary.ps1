<#
    .SYNOPSIS
        Return the name of the primary branch.

    .DESCRIPTION
        Use the git command to evaluate which is the primary branch. If a
        master branch exists, it will be returned. Else if a mail branch
        exists, it will be retunred. If both don^'t exist, an exception is
        thrown.

    .OUTPUTS
        System.String. Git repository primary branch name.

    .EXAMPLE
        PS C:\> Get-IBHGitBranchPrimary
        Get the current primary branch.

    .LINK
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>
function Get-IBHGitBranchPrimary
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

        $branches = git branch --list
        $branches = $branches | ForEach-Object { $_.Substring(2) }

        if ($branches -contains 'master')
        {
            return 'master'
        }
        elseif ($branches -contains 'main')
        {
            return 'main'
        }
        else
        {
            throw 'Primary branch not found!'
        }
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

<#
    .SYNOPSIS
        Check the GitHub repo for its name.

    .DESCRIPTION
        This command will return the repo name if the current repo is a GitHub
        repository. If not, it will return an empty string.

    .OUTPUTS
        System.String. GitHub repo name.

    .EXAMPLE
        PS C:\> Get-IBHGitHubRepo
        Get the repo name of a GitHub repo.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHGitHubRepo
{
    [CmdletBinding()]
    [OutputType([System.String])]
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

        $url = git config --get remote.origin.url

        if ($url -match '^https:\/\/github\.com\/.*\/(?<repo>.*)\.git$')
        {
            return $Matches['repo']
        }

        if ($url -match '^git@github\.com:.*\/(?<repo>.*)\.git$')
        {
            return $Matches['repo']
        }

        return ''
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

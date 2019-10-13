<#
    .SYNOPSIS
        Check the GitHub repo for its name.

    .DESCRIPTION
        This command will return the repo name if the current repo is a GitHub
        repository. If not, it will return an empty string.

    .OUTPUTS
        System.String

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
    param ()

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

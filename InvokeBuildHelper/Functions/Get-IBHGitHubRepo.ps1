<#
    .SYNOPSIS
        Check the GitHub repo for its name.

    .DESCRIPTION
        This command will return the repo name if the current repo is a GitHub
        repository. If not, it will return an empty string.
#>
function Get-IBHGitHubRepo
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $url = git config --get remote.origin.url

    if ($url -match '^https:\/\/github\.com\/.*\/(?<Repo>.*)\.git$')
    {
        return $Matches['Repo']
    }

    if ($url -match '^git@github\.com:.*\/(?<Repo>.*)\.git$')
    {
        return $Matches['Repo']
    }

    return ''
}

<#
    .SYNOPSIS
        Check the GitHub user for its name.

    .DESCRIPTION
        This command will return the user name if the current repo is a GitHub
        repository. If not, it will return an empty string.
#>
function Get-IBHGitHubUser
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $url = git config --get remote.origin.url

    if ($url -match '^https:\/\/github\.com\/(?<User>.*)\/.*\.git$')
    {
        return $Matches['User']
    }

    if ($url -match '^git@github\.com:(?<User>.*)\/.*\.git$')
    {
        return $Matches['User']
    }

    return ''
}

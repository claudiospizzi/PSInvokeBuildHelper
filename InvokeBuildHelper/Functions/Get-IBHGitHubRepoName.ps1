<#
    .SYNOPSIS
        Check the GitHub repo for its name.

    .DESCRIPTION
        This command will return the repo name in form uf username/repo if the
        current repo is a GitHub repository. If not, it will return an empty
        string.
#>
function Get-IBHGitHubRepoName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $url = git config --get remote.origin.url

    $result = ''

    if ($url -match '^https:\/\/github\.com\/(?<Username>.*)\/(?<Repository>.*)\.git$')
    {
        $result = '{0}/{1}' -f $Matches['Username'], $Matches['Repository']
    }

    if ($url -match '^git@github\.com:(?<Username>.*)\/(?<Repository>.*)\.git$')
    {
        $result = '{0}/{1}' -f $Matches['Username'], $Matches['Repository']
    }

    Write-Output $result
}

<#
    .SYNOPSIS
        Check the GitHub repository for its name.

    .DESCRIPTION
        This command will return the repository name if the current repository
        is a GitHub repository. If not, it will return an empty string.

    .OUTPUTS
        System.String. GitHub repository name.

    .EXAMPLE
        PS C:\> Get-IBHGitHubRepo
        Get the repository name of a GitHub repository.

    .LINK
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>
function Get-IBHGitHubRepo
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

        $url = git config --get remote.origin.url

        if ($url -match '^https:\/\/github\.com\/.*\/(?<repo>.*)\.git$' -or
            $url -match '^https:\/\/github\.com\/.*\/(?<repo>.*)$')
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

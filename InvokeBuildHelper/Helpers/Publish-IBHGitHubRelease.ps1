<#
    .SYNOPSIS
        Publish a new GitHub release.
#>
function Publish-IBHGitHubRelease
{
    [CmdletBinding()]
    param
    (
        # GitHub repo name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepoName,

        # Authentication token.
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]
        $Token,

        # Module name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName,

        # Module version.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion,

        # Module version release notes.
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $ReleaseNote
    )

    # Add TLS 1.2 for GitHub
    if (([System.Net.ServicePointManager]::SecurityProtocol -band [System.Net.SecurityProtocolType]::Tls12) -ne [System.Net.SecurityProtocolType]::Tls12)
    {
        [System.Net.ServicePointManager]::SecurityProtocol += [System.Net.SecurityProtocolType]::Tls12
    }

    # Create GitHub release
    $invokeRestMethodSplat = @{
        Method  = 'Post'
        Uri     = "https://api.github.com/repos/$RepoName/releases"
        Headers = @{
            'Accept'        = 'application/vnd.github.v3+json'
            'Authorization' = "token $Token"
        }
        Body   = @{
            tag_name         = $ModuleVersion
            target_commitish = 'master'
            name             = "$ModuleName v$ModuleVersion"
            body             = ($ReleaseNote -join "`n")
            draft            = $false
            prerelease       = $false
        } | ConvertTo-Json
    }
    Invoke-RestMethod @invokeRestMethodSplat -ErrorAction Stop
}

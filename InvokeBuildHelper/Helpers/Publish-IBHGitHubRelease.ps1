<#
    .SYNOPSIS
        Publish a new GitHub release.
#>
function Publish-IBHGitHubRelease
{
    [CmdletBinding()]
    param
    (
        # GitHub repository user.
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryUser,

        # GitHub repository name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryName,

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

    # Unprotect token
    $tokenCredentialStub = [System.Management.Automation.PSCredential]::new('Token', $Token)
    $plainToken = $tokenCredentialStub.GetNetworkCredential().Password

    # Create GitHub release
    $invokeRestMethodSplat = @{
        Method  = 'Post'
        Uri     = "https://api.github.com/repos/$RepositoryUser/$RepositoryName/releases"
        Headers = @{
            'Accept'        = 'application/vnd.github.v3+json'
            'Authorization' = "token $plainToken"
        }
        Body   = @{
            tag_name         = $ModuleVersion
            target_commitish = Get-IBHGitBranch
            name             = "$ModuleName v$ModuleVersion"
            body             = ($ReleaseNote -join "`n")
            draft            = $false
            prerelease       = $false
        } | ConvertTo-Json
    }
    Invoke-RestMethod @invokeRestMethodSplat -ErrorAction Stop
}

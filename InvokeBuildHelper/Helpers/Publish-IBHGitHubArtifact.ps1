<#
    .SYNOPSIS
        Upload an artifact to GitHub.
#>
function Publish-IBHGitHubArtifact
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

        # Release id.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ReleaseId,

        # Artifact file name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # Artifact path.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    # Add TLS 1.2 for GitHub
    if (([System.Net.ServicePointManager]::SecurityProtocol -band [System.Net.SecurityProtocolType]::Tls12) -ne [System.Net.SecurityProtocolType]::Tls12)
    {
        [System.Net.ServicePointManager]::SecurityProtocol += [System.Net.SecurityProtocolType]::Tls12
    }

    # Unprotect token
    $tokenCredentialStub = [System.Management.Automation.PSCredential]::new('Token', $Token)
    $plainToken = $tokenCredentialStub.GetNetworkCredential().Password

    # Upload artifact to GitHub
    $invokeRestMethodSplat = @{
        Method          = 'Post'
        Uri             = "https://uploads.github.com/repos/$RepositoryUser/$RepositoryName/releases/$ReleaseId/assets?name=$Name"
        Headers         = @{
            'Accept'        = 'application/vnd.github.v3+json'
            'Authorization' = "token $plainToken"
            'Content-Type'  = 'application/zip'
        }
        InFile          = $Path
    }
    Invoke-RestMethod @invokeRestMethodSplat -ErrorAction Stop
}

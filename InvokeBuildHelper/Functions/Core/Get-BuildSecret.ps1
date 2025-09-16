<#
    .SYNOPSIS
        Helper command to get a secure string for the build task.

    .DESCRIPTION
        This command aims to help with the handling of secure strings in the
        build script. It will support running on Windows (Credential Vault),
        Linux and Build Pipelines like GitHub Actions with environment
        variables.

    .EXAMPLE
        PS C:\> Get-BuildSecret -EnvironmentVariable 'POWERSHELL_GALLERY_KEY'
        Use the environment variable to get the secure string.

    .EXAMPLE
        PS C:\> Get-BuildSecret -CredentialManager 'PowerShell Gallery Key (claudiospizzi)'
        Use the credential manager vault to get the secure string.

    .EXAMPLE
        PS C:\> Get-BuildSecret -EnvironmentVariable 'POWERSHELL_GALLERY_KEY' -CredentialManager 'PowerShell Gallery Key (claudiospizzi)'
        Use the environment variable to get the secure string. If not found,
        fall back to the credential manager vault.

    .LINK
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>
function Get-BuildSecret
{
    [CmdletBinding()]
    [OutputType([System.String], [System.Security.SecureString])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification = 'The parameter CredentialManager is used to identify the item by name.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Required to protect the plain text secret from the environment variable.')]
    param
    (
        # The environment variable to use as first option.
        [Parameter(Mandatory = $false)]
        [System.String]
        $EnvironmentVariable,

        # The target name in the credential vault.
        [Parameter(Mandatory = $false)]
        [System.String]
        $CredentialManager,

        # How to return the generated password.
        [Parameter(Mandatory = $false)]
        [Alias('As')]
        [ValidateSet('SecureString', 'String')]
        [System.String[]]
        $OutputType = 'SecureString'
    )

    try
    {
        # Try to get the secret from the environment variable.
        if ($PSBoundParameters.ContainsKey('EnvironmentVariable'))
        {
            $secretPlainText = [System.Environment]::GetEnvironmentVariable($EnvironmentVariable)
            if (-not [System.String]::IsNullOrWhiteSpace($secretEnvVar))
            {
                switch ($OutputType)
                {
                    'SecureString'
                    {
                        $secretSecureString = $secretPlainText | ConvertTo-SecureString -String $secretEnvVar -AsPlainText -Force
                        return $secretSecureString
                    }

                    'String'
                    {
                        return $secretPlainText
                    }
                }
            }
        }

        # Fallback to the credential manager vault if the environment variable is
        # not set or empty. This only works on Windows.
        if (($PSVersionTable.PSVersion.Major -eq 5 -or $IsWindows) -and $PSBoundParameters.ContainsKey('CredentialManager'))
        {
            $secretSecureString = Get-VaultSecureString -TargetName $CredentialManager -ErrorAction SilentlyContinue
            if ($null -ne $secretSecureString)
            {
                switch ($OutputType)
                {
                    'SecureString'
                    {
                        return $secretSecureString
                    }

                    'String'
                    {
                        return [System.Management.Automation.PSCredential]::new('secret', $secretSecureString).GetNetworkCredential().Password
                    }
                }
            }
        }

        throw "The environment variable '$EnvironmentVariable' and credential manager '$CredentialManager' were not available or empty."
    }
    catch
    {
        throw "Error retrieving the build secret: $($_.Exception.Message)"
    }
}

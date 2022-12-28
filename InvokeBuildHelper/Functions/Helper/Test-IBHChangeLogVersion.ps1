<#
    .SYNOPSIS
        Test if the change log contains the specified version and release date.

    .DESCRIPTION
        This function will search in the CHANGELOG.md for the headline level 2
        with the following format: '## 1.0.0 - 2019-10-09'. If the headline was
        found, it will return $true. If not, $false is returned.

    .OUTPUTS
        System.Boolean. The test result.

    .EXAMPLE
        PS C:\> Test-IBHChangeLogVersion -BuildRoot 'C:\GitHub\InvokeBuildHelper' -ModuleVersion '1.0.0' -ReleaseDate [DateTime]::now()
        Test if the version 1.0.0 with the release date of today is registered
        in the change log.

    .LINK
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>
function Test-IBHChangeLogVersion
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        # Root path of the project.
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot,

        # The version to test.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion,

        # The release date to test.
        [Parameter(Mandatory = $true)]
        [System.DateTime]
        $ReleaseDate
    )

    $path    = Join-Path -Path $BuildRoot -ChildPath 'CHANGELOG.md'
    $content = Get-Content -Path $path -Raw

    $moduleVersionEscaped = [System.Text.RegularExpressions.Regex]::Escape($ModuleVersion)
    $releaseDateEscaped   = [System.Text.RegularExpressions.Regex]::Escape('{0:yyyy-MM-dd}' -f $ReleaseDate)

    $result = $content -match "## $moduleVersionEscaped - $releaseDateEscaped"

    return $result
}

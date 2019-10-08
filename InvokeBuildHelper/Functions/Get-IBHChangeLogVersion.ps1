<#
    .SYNOPSIS
        Return the version within the change log.

    .DESCRIPTION
        Check the CHANGELOG.md if it contains an entry with the desired version
        and the current date in the following format:
        ## 1.2.3 - 2019-10-09
#>
function Get-IBHChangeLogVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        # Root path of the project.
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot,

        # The version to check.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion
    )

    $path    = Join-Path -Path $BuildRoot -ChildPath 'CHANGELOG.md'
    $content = Get-Content -Path $path -Raw

    $moduleVersionEscaped = [System.Text.RegularExpressions.Regex]::Escape($ModuleVersion)
    $formattedDate        = Get-Date -Format 'yyyy-MM-dd'

    if ($content -match "## (?<version>$moduleVersionEscaped) - $formattedDate")
    {
        return $Matches['version']
    }
    else
    {
        return ''
    }
}

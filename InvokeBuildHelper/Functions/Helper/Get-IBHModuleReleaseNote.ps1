<#
    .SYNOPSIS
        Extract all lines for the current version.

    .DESCRIPTION
        Prepare a release notes statement with all entries in dhe CHANGELOG.md
        file.

    .OUTPUTS
        System.String. Multi-line text release notes.

    .EXAMPLE
        PS C:\> Get-IBHModuleReleaseNote -BuildRoot 'C:\GitHub\InvokeBuildHelper' -ModuleVersion '1.0.0'
        Find the release notes for the version 1.0.0.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHModuleReleaseNote
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
    $content = Get-Content -Path $path

    $releaseNotes = [System.String[]] 'Release Notes:'

    $isCurrentVersion = $false
    foreach ($line in $content)
    {
        if ($line -like '## *')
        {
            $isCurrentVersion = $line -like "## $ModuleVersion - ????-??-??"
        }
        elseif ($isCurrentVersion)
        {
            if (-not [System.String]::IsNullOrWhiteSpace($line))
            {
                $releaseNotes += $line
            }
        }
    }

    if ($releaseNotes.Count -eq 1)
    {
        throw "Release notes not found in CHANGELOG.md for version $ModuleVersion"
    }

    Write-Output $releaseNotes
}

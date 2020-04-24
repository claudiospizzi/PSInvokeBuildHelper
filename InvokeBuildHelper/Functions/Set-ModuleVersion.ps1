<#
    .SYNOPSIS
        Update the module version and create a git tag.

    .DESCRIPTION
        This command will update the module definition file (.psd1) and the
        readme to the new version. A git tag is created and pushed to the origin
        with the new version.

    .OUTPUTS
        None.

    .EXAMPLE
        PS C:\> Set-ModuleVersion -Version '1.2.3'
        Set the module version to 1.2.3.

    .EXAMPLE
        PS C:\> Set-ModuleVersion -Major
        Set the module version to the next major.

    .EXAMPLE
        PS C:\> Set-ModuleVersion -Minor
        Set the module version to the next minor.

    .EXAMPLE
        PS C:\> Set-ModuleVersion -Build
        Set the module version to the next build.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Set-ModuleVersion
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [Alias('ibv')]
    param
    (
        # New module version.
        [Parameter(Mandatory = $true, ParameterSetName = 'Version')]
        [System.Version]
        $Version,

        # Increment the major number by one and set the minor and build to 0.
        [Parameter(Mandatory = $true, ParameterSetName = 'Major')]
        [Switch]
        $Major,

        # Increment the minor number by one and set the build to 0.
        [Parameter(Mandatory = $true, ParameterSetName = 'Minor')]
        [Switch]
        $Minor,

        # Increment the build number by one.
        [Parameter(Mandatory = $true, ParameterSetName = 'Build')]
        [Switch]
        $Build
    )

    # Check if the current location is a valid repository.
    $buildRoot = Get-Location | Select-Object -ExpandProperty 'Path'
    if (-not (Test-Path -Path "$buildRoot\.git") -or -not (Test-Path -Path "$buildRoot\.build.ps1") -or -not (Test-Path -Path "$buildRoot\CHANGELOG.md"))
    {
        throw "Current path is not a valid repository: $buildRoot"
    }

    # Get the module name. It will throw, if no module is available.
    $moduleName = Get-BuildModuleName -BuildRoot $buildRoot -ErrorAction 'Stop'

    # Check if we have a solution, just show a warning if yes.
    $solutionName = Get-BuildSolutionName -BuildRoot $buildRoot
    if (-not [System.String]::IsNullOrEmpty($solutionName))
    {
        Write-Warning "Repository contains a .NET solution, update the version manually: $solutionName"
    }

    # Verify if the change log contains an unreleased section
    $changelogPath = "$buildRoot\CHANGELOG.md"
    if ((Get-Content -Path $changelogPath) -notcontains '## Unreleased')
    {
        throw "The '## Unreleased' section is missing in the changelog: $changelogPath"
    }

    # Verify if the module version does exist
    $moduleDefinitionPath = "$buildRoot\$moduleName\$moduleName.psd1"
    if ((Get-Content -Path $moduleDefinitionPath -Raw) -notlike "*    ModuleVersion = '*.*.*'*")
    {
        throw "The 'ModuleVersion' property is missing in the module definition file: $moduleDefinitionPath"
    }

    # Get the current version to increment if required.
    if ($PSCmdlet.ParameterSetName -ne 'Version')
    {
        $Version = [System.Version](Get-IBHModuleVersion -BuildRoot $buildRoot -ModuleName $moduleName)
    }

    # Calculate the new module version.
    switch ($PSCmdlet.ParameterSetName)
    {
        'Version' { $newVersion = '{0}.{1}.{2}' -f $Version.Major, $Version.Minor, $Version.Build }
        'Major'   { $newVersion = '{0}.{1}.{2}' -f ($Version.Major + 1), 0, 0 }
        'Minor'   { $newVersion = '{0}.{1}.{2}' -f $Version.Major, ($Version.Minor + 1), 0 }
        'Build'   { $newVersion = '{0}.{1}.{2}' -f $Version.Major, $Version.Minor, ($Version.Build + 1) }
    }

    if ($PSCmdlet.ShouldProcess($moduleName, "Set Version $newVersion"))
    {
        Write-Host "Step Update File: $changelogPath" -ForegroundColor 'Cyan'

        $changelogContent = @(Get-Content -Path $changelogPath)
        for ($i = 0; $i -lt $changelogContent.Count; $i++)
        {
            if ($changelogContent[$i] -eq '## Unreleased')
            {
                $changelogContent[$i] = '## {0} - {1:yyyy-MM-dd}' -f $newVersion, [System.DateTime]::Now
            }
        }
        $changelogContent | Set-Content -Path $changelogPath -Encoding 'UTF8'


        Write-Host "Step Update File: $moduleDefinitionPath" -ForegroundColor 'Cyan'

        $moduleDefinitionContent = @(Get-Content -Path $moduleDefinitionPath)
        for ($i = 0; $i -lt $moduleDefinitionContent.Count; $i++)
        {
            if ($moduleDefinitionContent[$i] -like "*    ModuleVersion = '*.*.*'*")
            {
                $moduleDefinitionContent[$i] = "    ModuleVersion = '{0}'" -f $newVersion
            }
        }
        $moduleDefinitionContent | Set-Content -Path $moduleDefinitionPath -Encoding 'UTF8'


        Write-Host "Step Stage Changes: git add *" -ForegroundColor 'Cyan'

        git add *


        Write-Host "Step Commit Changes: git commit -m `"Version $newVersion`"" -ForegroundColor 'Cyan'

        git commit -m `"Version $newVersion`"


        Write-Host "Step Push Commit: git push" -ForegroundColor 'Cyan'

        git push


        Write-Host "Step Create Tag: git tag `"$newVersion`"" -ForegroundColor 'Cyan'

        git tag "$newVersion"


        Write-Host "Step Push Tag: git push --tag" -ForegroundColor 'Cyan'

        git push --tag
    }



    # $path    = Join-Path -Path $BuildRoot -ChildPath 'CHANGELOG.md'
    # $content = Get-Content -Path $path

    # $releaseNotes = [System.String[]] 'Release Notes:'

    # $isCurrentVersion = $false

}

<#
    .SYNOPSIS
        Invoke the module schema tests.

    .DESCRIPTION
        Invoke tests based on Pester to verify if the module is valid. This
        includes the meta files for VS Code, built system, git repo but also
        module specific files.
#>
function Invoke-IBHModuleSchemaTest
{
    [CmdletBinding()]
    param
    (
        # Root path of the project.
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot,

        # Name of the module.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName
    )

    # Create output folder
    New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Out-Null

    $invokePesterSplat = @{
        Script       = @{
            Path         = Resolve-Path -Path "$PSScriptRoot\..\Scripts\ModuleSchema.Tests.ps1" | Select-Object -ExpandProperty 'Path'
            Parameters   = @{
                BuildRoot    = $BuildRoot
                ModuleName   = $ModuleName
            }
        }
        OutputFile   = Join-Path -Path $BuildRoot -ChildPath 'out\TestResult.ModuleSchema.xml'
        OutputFormat = 'NUnitXml'
        PassThru     = $true
    }
    Invoke-Pester @invokePesterSplat
}

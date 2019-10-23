<#
    .SYNOPSIS
        Invoke the module schema tests.

    .DESCRIPTION
        Invoke tests based on Pester to verify if the module is valid. This
        includes the meta files for VS Code, built system, git repository but
        also module specific files.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. Pester result object.

    .EXAMPLE
        PS C:\> Invoke-IBHModuleSchemaTest -BuildRoot 'C:\GitHub\InvokeBuildHelper' -ModuleName 'InvokeBuildHelper' -OutputPath 'C:\TestResults'
        Invoke the schema tests for the InvokeBuildHelper module.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
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
        $ModuleName,

        # Output folder for the NUnitXml file.
        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath
    )

    $invokePesterSplat = @{
        Script       = @{
            Path         = Resolve-Path -Path "$PSScriptRoot\..\Scripts\ModuleSchemaTests.ps1" | Select-Object -ExpandProperty 'Path'
            Parameters   = @{
                BuildRoot    = $BuildRoot
                ModuleName   = $ModuleName
            }
        }
        OutputFile   = Join-Path -Path $OutputPath -ChildPath 'TestResult.ModuleSchema.xml'
        OutputFormat = 'NUnitXml'
        PassThru     = $true
    }
    Invoke-Pester @invokePesterSplat
}

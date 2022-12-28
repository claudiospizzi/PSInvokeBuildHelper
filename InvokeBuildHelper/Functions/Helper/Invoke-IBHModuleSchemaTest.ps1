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
        https://github.com/claudiospizzi/PSInvokeBuildHelper
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

        # List of text file extension.
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $TextFileExtension,

        # List of paths to exclude.
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.String[]]
        $ExcludePath,

        # Output folder for the NUnitXml file.
        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath
    )

    # Path to the schema tests stored in this module
    $moduleSchemaTestFile = Resolve-Path -Path "$PSScriptRoot\..\..\Scripts\ModuleSchemaTests.ps1" | Select-Object -ExpandProperty 'Path'

    $pesterNUnitOutputPath = Join-Path -Path $OutputPath -ChildPath 'TestResult.ModuleSchema.xml'

    if ((Get-Module -Name 'Pester').Version.Major -ge 5)
    {
        $invokePesterSplat = @{
            Container = New-PesterContainer -Path $moduleSchemaTestFile -Data @{
                BuildRoot         = $BuildRoot
                ModuleName        = $ModuleName
                TextFileExtension = $TextFileExtension
                ExcludePath       = $ExcludePath
            }
            Output    = 'Detailed'
            PassThru  = $true
        }
        $pesterResult = Invoke-Pester @invokePesterSplat

        # Export NUnit report with a separate command, as this is not build-in
        # into Invoke-Pester starting with v5.
        $pesterResult | ConvertTo-NUnitReport -AsString | Set-Content -Path $pesterNUnitOutputPath -Encoding 'UTF8'
    }
    else
    {
        $invokePesterSplat = @{
            Script       = @{
                Path         = $moduleSchemaTestFile
                Parameters   = @{
                    BuildRoot         = $BuildRoot
                    ModuleName        = $ModuleName
                    TextFileExtension = $TextFileExtension
                    ExcludePath       = $ExcludePath
                }
            }
            OutputFile   = $pesterNUnitOutputPath
            OutputFormat = 'NUnitXml'
            PassThru     = $true
        }
        $pesterResult = Invoke-Pester @invokePesterSplat
    }

    Write-Output $pesterResult
}

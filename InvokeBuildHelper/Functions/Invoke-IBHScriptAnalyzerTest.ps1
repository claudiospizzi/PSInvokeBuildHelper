<#
    .SYNOPSIS
        Invoke the Script Analyzer tests.

    .DESCRIPTION
        Invoke the Script Analyzer tests and show the result as Pester output.
        For every issue a failed test will be shown. If a rule passes for all
        files, one passing test will be shown.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. Pester result object.

    .EXAMPLE
        PS C:\> Invoke-IBHScriptAnalyzerTest -BuildRoot 'C:\GitHub\InvokeBuildHelper' -ModuleName 'InvokeBuildHelper' -OutputPath 'C:\TestResults'
        Invoke the script analyter tests for the InvokeBuildHelper module.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Invoke-IBHScriptAnalyzerTest
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

        # Script analyzer rules to test.
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Rule,

        # Output folder for the NUnitXml file.
        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath
    )

    # Create output folder
    New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Out-Null

    $invokePesterSplat = @{
        Script       = @{
            Path         = Resolve-Path -Path "$PSScriptRoot\..\Scripts\ScriptAnalyzerTests.ps1" | Select-Object -ExpandProperty 'Path'
            Parameters   = @{
                BuildRoot    = $BuildRoot
                ModuleName   = $ModuleName
                Rule         = $Rule
            }
        }
        OutputFile   = Join-Path -Path $OutputPath -ChildPath 'TestResult.ScriptAnalyzer.xml'
        OutputFormat = 'NUnitXml'
        PassThru     = $true
    }
    Invoke-Pester @invokePesterSplat
}

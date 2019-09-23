<#
    .SYNOPSIS
        Invoke the Script Analyzer tests.

    .DESCRIPTION
        Invoke the Script Analyzer tests and show the result as Pester output.
        For every issue a failed test will be shown. If a rule passes for all
        files, one passing test will be shown.
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
        $Rule
    )

    # Create output folder
    New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Out-Null

    $invokePesterSplat = @{
        Script       = @{
            Path         = Resolve-Path -Path "$PSScriptRoot\..\Scripts\ScriptAnalyzer.Tests.ps1" | Select-Object -ExpandProperty 'Path'
            Parameters   = @{
                BuildRoot    = $BuildRoot
                ModuleName   = $ModuleName
                Rule         = $Rule
            }
        }
        OutputFile   = Join-Path -Path $BuildRoot -ChildPath 'out\TestResult.ScriptAnalyzer.xml'
        OutputFormat = 'NUnitXml'
        PassThru     = $true
    }
    Invoke-Pester @invokePesterSplat
}

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
        Invoke the script analyzer tests for the InvokeBuildHelper module.

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

    # Path to the script analyzer tests stored in this module
    $scriptAnalyzerTestFile = Resolve-Path -Path "$PSScriptRoot\..\Scripts\ScriptAnalyzerTests.ps1" | Select-Object -ExpandProperty 'Path'

    $pesterNUnitOutputPath = Join-Path -Path $OutputPath -ChildPath 'TestResult.ScriptAnalyzer.xml'

    if ((Get-Module -Name 'Pester').Version.Major -ge 5)
    {
        $invokePesterSplat = @{
            Container = New-PesterContainer -Path $scriptAnalyzerTestFile -Data @{
                BuildRoot    = $BuildRoot
                ModuleName   = $ModuleName
                Rule         = $Rule
                ExcludePath  = $ExcludePath
            }
            Output    = 'Detailed'
            CI        = $true
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
                Path         = $scriptAnalyzerTestFile
                Parameters   = @{
                    BuildRoot    = $BuildRoot
                    ModuleName   = $ModuleName
                    Rule         = $Rule
                    ExcludePath  = $ExcludePath
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

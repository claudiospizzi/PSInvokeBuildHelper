<#
    .SYNOPSIS
        Invoke the Pester integration tests.

    .DESCRIPTION
        This function will invoke all Pester integration tests in the module
        itself to invoke the module integration tests.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. Pester result object.

    .EXAMPLE
        PS C:\> Invoke-IBHPesterIntegrationTest -BuildRoot 'C:\GitHub\InvokeBuildHelper' -ModuleName 'InvokeBuildHelper' -OutputPath 'C:\TestResults'
        Invoke the Pester integration tests for the InvokeBuildHelper module.

    .LINK
        https://github.com/claudiospizzi/PSInvokeBuildHelperer
#>
function Invoke-IBHPesterIntegrationTest
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

    # Create output folder
    New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Out-Null

    # Define the test path
    $pesterTestPath = Join-Path -Path $BuildRoot -ChildPath "$ModuleName\Tests\Integration"

    if (Test-Path -Path $pesterTestPath)
    {
        $pesterNUnitOutputPath = Join-Path -Path $OutputPath -ChildPath 'TestResult.PesterIntegration.xml'

        if ((Get-Module -Name 'Pester').Version.Major -ge 5)
        {
            $invokePesterSplat = @{
                Path     = $pesterTestPath
                Output   = 'Detailed'
                PassThru = $true
            }
            $pesterResult = Invoke-Pester @invokePesterSplat

            # Export NUnit report with a separate command, as this is not
            # build-in into Invoke-Pester starting with v5.
            $pesterResult | ConvertTo-NUnitReport -AsString | Set-Content -Path $pesterNUnitOutputPath -Encoding 'UTF8'
        }
        else
        {
            $invokePesterSplat = @{
                Path         = $pesterTestPath
                OutputFile   = $pesterNUnitOutputPath
                OutputFormat = 'NUnitXml'
                PassThru     = $true
            }
            $pesterResult = Invoke-Pester @invokePesterSplat
        }

        Write-Output $pesterResult
    }
    else
    {
        Write-Warning "Pester tests skipped, path not found: $pesterTestPath"

        # Fake the Pester output, so that the task will not fail!
        [PSCustomObject] @{
            FailedCount = 0
        }
    }
}

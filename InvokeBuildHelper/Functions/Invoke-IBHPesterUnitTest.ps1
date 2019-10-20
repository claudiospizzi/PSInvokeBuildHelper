<#
    .SYNOPSIS
        Invoke the Pester unit tests.

    .DESCRIPTION
        This function will invoke all Pester unit tests in the module itself to
        invoke the module unit tests.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. Pester result object.

    .EXAMPLE
        PS C:\> Invoke-IBHPesterUnitTest -BuildRoot 'C:\GitHub\InvokeBuildHelper' -ModuleName 'InvokeBuildHelper' -OutputPath 'C:\TestResults'
        Invoke the Pester unit tests for the InvokeBuildHelper module.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Invoke-IBHPesterUnitTest
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

    $invokePesterSplat = @{
        Path         = Join-Path -Path $BuildRoot -ChildPath $ModuleName
        OutputFile   = Join-Path -Path $OutputPath -ChildPath 'TestResult.PetserUnit.xml'
        OutputFormat = 'NUnitXml'
        PassThru     = $true
    }
    Invoke-Pester @invokePesterSplat
}

<#
    .SYNOPSIS
        Invoke the Pester unit tests.

    .DESCRIPTION
        This function will invoke all Pester unit tests in the module itself to
        invoke the module unit tests.
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
        $ModuleName
    )

    # Create output folder
    New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Out-Null

    $invokePesterSplat = @{
        Path         = Join-Path -Path $BuildRoot -ChildPath $ModuleName
        OutputFile   = Join-Path -Path $BuildRoot -ChildPath 'out\TestResult.PetserUnit.xml'
        OutputFormat = 'NUnitXml'
        PassThru     = $true
    }
    Invoke-Pester @invokePesterSplat
}

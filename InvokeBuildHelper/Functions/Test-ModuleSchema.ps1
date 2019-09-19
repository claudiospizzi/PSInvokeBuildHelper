<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
#>
function Test-ModuleSchema
{
    [CmdletBinding()]
    param
    (
        # Root path of the module
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        # Name of the module
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleName
    )

    $invokePesterSplat = @{
        Script     = @{
            Path       = Resolve-Path -Path "$PSScriptRoot\..\Scripts\Tests.ps1" | Select-Object -ExpandProperty 'Path'
            Parameters = @{
                Path       = $Path
                ModuleName = $ModuleName
            }
        }
        PassThru   = $true
    }
    Invoke-Pester @invokePesterSplat #| Select-Object -ExpandProperty 'TestResult'
}

<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
#>
function Get-IBHModuleVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
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

    $moduleDefinition = Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1"

    return $moduleDefinition.ModuleVersion
}

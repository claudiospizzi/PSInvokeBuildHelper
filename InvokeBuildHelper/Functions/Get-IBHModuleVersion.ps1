<#
    .SYNOPSIS
        Get the module version.

    .DESCRIPTION
        Extract the module version information from the root psd1 file.
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

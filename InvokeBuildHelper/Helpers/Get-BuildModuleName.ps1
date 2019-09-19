<#
    .SYNOPSIS
        Get the PowerShell module name.
#>
function Get-BuildModuleName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        # Root path of the target module
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot
    )

    $moduleName = Get-ChildItem -Path $BuildRoot -Directory |
                      Where-Object { Test-Path -Path ('{0}\{1}.psd1'-f $_.FullName, $_.Name) } |
                          Select-Object -ExpandProperty 'Name' -First 1

    if ([System.String]::IsNullOrEmpty($moduleName))
    {
        throw 'Module name not found!'
    }

    return $moduleName
}

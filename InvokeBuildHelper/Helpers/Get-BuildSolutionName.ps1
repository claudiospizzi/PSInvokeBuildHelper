<#
    .SYNOPSIS
        Get the Visual Studio solution name.
#>
function Get-BuildSolutionName
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

    $solutionName = Get-ChildItem -Path $BuildRoot -Directory |
                      Where-Object { Test-Path -Path ('{0}\{1}.sln'-f $_.FullName, $_.Name) } |
                          Select-Object -ExpandProperty 'Name' -First 1

    if ([System.String]::IsNullOrEmpty($solutionName))
    {
        throw 'Module name not found!'
    }

    return $solutionName
}

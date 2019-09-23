<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
#>
function Publish-IBHRepository
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

    $moduleVersion = Get-IBHModuleVersion -BuildRoot $BuildRoot -ModuleName $ModuleName
    $releaseNotes  = Get-IBHModuleReleaseNote


}

<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
#>
function Publish-IBHGallery
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

    #
}

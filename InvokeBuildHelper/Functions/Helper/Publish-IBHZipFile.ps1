<#
    .SYNOPSIS
        Publish the module to the local file system as zip file.

    .DESCRIPTION
        Use the built-in Compress-Archive cmdlet to create a zip file and
        release it in the bin folder in the local file system.

    .OUTPUTS
        None. No output if successful or an exception in case of an error.

    .EXAMPLE
        PS C:\> Publish-IBHZipFile -BuildRoot 'C:\GitHub\InvokeBuildHelper' -ModuleName 'InvokeBuildHelper' -ModuleVersion '1.0.0'
        Publish the module InvokeBuildHelper version 1.0.0 as zip file to the
        bin folder.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Publish-IBHZipFile
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

        # Version to publish.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion
    )

    # Create output folder
    New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'bin') -ItemType 'Directory' -Force | Out-Null

    # Create ZIP file
    Compress-Archive -Path "$BuildRoot\$ModuleName\*" -DestinationPath "$BuildRoot\bin\$ModuleName-$ModuleVersion.zip" -Verbose:$VerbosePreference -Force
}

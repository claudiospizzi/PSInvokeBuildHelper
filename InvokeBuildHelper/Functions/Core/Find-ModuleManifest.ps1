<#
    .SYNOPSIS
        Find the first module manifest file in the parent folder chain where the
        module name is the same as the folder name.

    .DESCRIPTION
        This command will recursive scan each parent folder for a PowerShell
        module manifest file (*.psd1). It will return the first manifest file
        found. The manifest file must be named equals to his parent folder.

    .EXAMPLE
        PS C:\> Find-ModuleManifest
        Check the folder chain based on the current folder.

    .LINK
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>
function Find-ModuleManifest
{
    [CmdletBinding()]
    param
    (
        # The starting directory.
        [Parameter(Mandatory = $false)]
        [System.String]
        $Path = $PWD.Path
    )

    try
    {
        # Pipeline way to find the module manifest.
        # $Path.Split([System.IO.Path]::DirectorySeparatorChar) | ForEach-Object { $_.Replace(':', ':\') } |
        #     ForEach-Object { $p = [System.IO.Path]::Combine($p, $_); [System.IO.Path]::Combine($p, "$_.psd1") } |
        #         Where-Object { Test-Path -Path $_ } | Sort-Object -Descending 'length' | Select-Object -First 1 |
        #             ForEach-Object { Import-Module -Name $_ -Force }

        $currentPath = $Path

        while (-not [System.String]::IsNullOrEmpty($currentPath) -and (Test-Path -Path $currentPath))
        {
            # Generate the module manifest file name
            $manifestPath = Join-Path -Path $currentPath -ChildPath ('{0}.psd1' -f (Split-Path -Path $currentPath -Leaf))

            # If the module manifest file exists, leave the command and return
            # the full path to the found module.
            if (Test-Path -Path $manifestPath)
            {
                return $manifestPath
            }

            # If not, check the parent folder
            $currentPath = Split-Path -Path $currentPath -Parent
        }

        throw "No module manifest found in path '$Path'"
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

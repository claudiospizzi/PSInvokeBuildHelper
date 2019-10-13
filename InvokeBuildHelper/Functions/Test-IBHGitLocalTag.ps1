<#
    .SYNOPSIS
        Test if the module version exists as tag on the git local repo.

    .DESCRIPTION
        Use the 'git describe --tags' command to get all local repo tags. If the
        module version is in the tag list, $true will be retunred, else $false.

    .OUTPUTS
        System.Boolean.

    .EXAMPLE
        PS C:\> Test-IBHGitLocalTag -ModuleVersion '1.0.0'
        Test if the version 1.0.0 tag is on the git local repo.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper

#>
function Test-IBHGitLocalTag
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        # The version to test.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion
    )

    # Returns the tag of the last commit
    $tag = git describe --tags

    return $tag -eq $ModuleVersion
}

<#
    .SYNOPSIS
        Test if the solution version matches the module version.

    .DESCRIPTION
        Analyze the AssemblyInfo.cs and verify if the assenbly version and
        assembly file version match the module version.

    .OUTPUTS
        System.Boolean. The test result.

    .EXAMPLE
        PS C:\> Test-IBHSolutionVersion -BuildRoot 'C:\GitHub\InvokeBuildHelper' -SolutionName 'InvokeBuildHelper.Library' -ModuleVersion '1.0.0'
        Test if the version 1.0.0 is set in the solution InvokeBuildHelper.Library.

    .LINK
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>
function Test-IBHSolutionVersion
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        # Root path of the project.
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot,

        # Solution name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $SolutionName,

        # The version to test.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleVersion
    )

    # Path to the assembly info file.
    $assemblyPath = '{0}\{1}\Properties\*.cs' -f $BuildRoot, $SolutionName

    # Extract the assembly version
    $assemblyVersion = ''
    if ($null -ne ($assemblyVersionMatch = Select-String -Path $assemblyPath -Pattern '^\[assembly: AssemblyVersion\("([0-9\.]+)"\)\]$'))
    {
        $assemblyVersion = ($assemblyVersionMatch.Matches.Captures)[0].Groups[1].Value
    }

    # Extract the assembly file version
    $assemblyFileVersion = ''
    if ($null -ne ($assemblyFileVersionMatch = Select-String -Path $assemblyPath -Pattern '^\[assembly: AssemblyFileVersion\("([0-9\.]+)"\)\]$'))
    {
        $assemblyFileVersion = ($assemblyFileVersionMatch.Matches.Captures)[0].Groups[1].Value
    }

    $result = $ModuleVersion -eq $assemblyVersion -and $ModuleVersion -eq $assemblyFileVersion

    return $result
}

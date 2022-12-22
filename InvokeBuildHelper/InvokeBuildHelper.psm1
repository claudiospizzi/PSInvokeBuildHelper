<#
    .SYNOPSIS
        Root module file.

    .DESCRIPTION
        The root module file loads all classes, helpers and functions into the
        module context.
#>

# Get and dot source all classes (internal)
Split-Path -Path $PSCommandPath |
    Get-ChildItem -Filter 'Classes' -Directory |
        Get-ChildItem -Include '*.ps1' -File -Recurse |
            ForEach-Object { . $_.FullName }

# Get and dot source all helper functions (internal)
Split-Path -Path $PSCommandPath |
    Get-ChildItem -Filter 'Helpers' -Directory |
        Get-ChildItem -Include '*.ps1' -File -Recurse |
            ForEach-Object { . $_.FullName }

# Get and dot source all external functions (public)
Split-Path -Path $PSCommandPath |
    Get-ChildItem -Filter 'Functions' -Directory |
        Get-ChildItem -Include '*.ps1' -File -Recurse |
            ForEach-Object { . $_.FullName }

# Create an alias to the build script
Set-Alias -Name 'InvokeBuildHelperTasks' -Value "$PSScriptRoot\Scripts\InvokeBuildHelperTasks.ps1"

# Get all task names
$Script:INVOKE_BUILD_HELPER_TASK_NAMES =
    Get-Content -Path "$PSScriptRoot\Scripts\InvokeBuildHelperTasks.ps1" |
        Where-Object { $_ -match '^task (?<TaskName>[a-zA-Z]+)' } |
            ForEach-Object { $Matches['TaskName'] }

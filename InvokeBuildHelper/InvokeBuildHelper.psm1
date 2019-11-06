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

# Register the argument completer for the Invoke-Build command
Register-ArgumentCompleter -CommandName 'Invoke-Build.ps1' -ParameterName 'Task' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    if (Test-Path -Path '.\.build.ps1')
    {
        if (Select-String -Path '.\.build.ps1' -Pattern '\. InvokeBuildHelperTasks' -Quiet)
        {
            $match = Select-String -Path "$PSScriptRoot\Scripts\InvokeBuildHelperTasks.ps1" -Pattern '^task (?<taskname>[a-zA-Z]+)'
            foreach ($capture in $match.Matches.Captures)
            {
                $taskName = $capture.Groups[1].Value
                if ($taskName -like "$wordToComplete*")
                {
                    [System.Management.Automation.CompletionResult]::new($taskName, $taskName, 'ParameterValue', $taskName)
                }
            }
        }
    }
}

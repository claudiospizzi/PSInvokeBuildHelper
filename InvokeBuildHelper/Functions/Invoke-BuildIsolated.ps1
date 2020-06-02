<#
    .SYNOPSIS
        Invoke a build by calling the Invoke-Build in an isolated process.

    .DESCRIPTION
        This command will invoke a new powershell.exe process and pass the task
        specified into the child process. It ensures, the process working
        directory matches the current process. This is usfull for building
        modules using .NET class libraries, because the can only imported once
        into a PowerShell process. Updating .NET class libraries is not
        possible, so the test would always run on the initial imported version.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .EXAMPLE
        PS C:\> Invoke-BuildIsolated -Task 'Release'
        Invoke the release task isolated.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Invoke-BuildIsolated
{
    [CmdletBinding()]
    [Alias('ib')]
    param
    (
        [Parameter(Mandatory = $false)]
        [System.String]
        $Task = '.'
    )

    $powershellCommand = Get-Command -Name 'powershell.exe' | Select-Object -ExpandProperty 'Source'
    & $powershellCommand -NoLogo -NoProfile -ExecutionPolicy 'Bypass' -Command "Set-Location -Path '$($pwd.ProviderPath)'; Invoke-Build -Task '$Task'"
}

# Register the argument completer for the Invoke-Build command
Register-ArgumentCompleter -CommandName 'Invoke-Build.ps1', 'Invoke-BuildIsolated' -ParameterName 'Task' -ScriptBlock {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
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

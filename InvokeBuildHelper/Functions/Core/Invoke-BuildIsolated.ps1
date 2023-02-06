<#
    .SYNOPSIS
        Invoke a build by calling the Invoke-Build in an isolated process.

    .DESCRIPTION
        This command will invoke a new powershell.exe process and pass the task
        specified into the child process. It ensures, the process working
        directory matches the current process. This is usefull for building
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
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>
function Invoke-BuildIsolated
{
    [CmdletBinding()]
    [Alias('ib')]
    param
    (
        # Specify the task to execute. Default task by default.
        [Parameter(Mandatory = $false)]
        [System.String]
        $Task = '.',

        # Specify the Pester module version if required.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Unspecified', 'v4', 'v5')]
        [System.String]
        $PesterVersion = 'Unspecified'
    )

    $pesterImport = ''
    switch ($PesterVersion)
    {
        'v4' { $pesterImport = "Import-Module -Name 'Pester' -MaximumVersion '4.99.99'" }
        'v5' { $pesterImport = "Import-Module -Name 'Pester' -MinimumVersion '5.0.0'" }
    }

    $commandPath = Get-Process -Id $PID | Select-Object -ExpandProperty 'Path'
    & $commandPath -NoLogo -NoProfile -ExecutionPolicy 'Bypass' -Command "Set-Location -Path '$($pwd.ProviderPath)'; $pesterImport; Invoke-Build -Task '$Task'"
}

# Register the argument completer for the Invoke-Build command
Register-ArgumentCompleter -CommandName 'Invoke-BuildIsolated' -ParameterName 'Task' -ScriptBlock {
    $taskNames = $Script:INVOKE_BUILD_HELPER_TASK_NAMES
    foreach ($taskName in $taskNames)
    {
        [System.Management.Automation.CompletionResult]::new($taskName, $taskName, 'ParameterValue', $taskName)
    }
}

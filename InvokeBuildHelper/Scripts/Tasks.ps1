<#
    .SYNOPSIS
        Common build tasks for a PowerShell module.

    .DESCRIPTION
        .

    .LINK
        https://github.com/nightroman/Invoke-Build
        https://github.com/claudiospizzi/InvokeBuildHelper
#>

# Load the build configuration
$IBHConfig = Get-BuildConfig -BuildRoot $BuildRoot

# Synopsis: By default, bulid and test the module
task . Build, Test

# Synopsis: Compile the library projects
task Build Clean, Compile

# Synopsis: Test the module with pester and script analyzer
task Test Schema, Pester, Analyze

# Synopsis: Release the module to the repository and the gallery
task Release Build, Test, Repository, Gallery

# Synopsis:
task Clean {
    
}

# Synopsis:
task Compile {

}

# Synopsis: Test the PowerShell module schema
task Schema {

    # Invoke the module schema tests
    $results = @(Test-ModuleSchema -Path $BuildRoot -ModuleName $IBHConfig.ModuleName)

    assert ($results.FailedCount -eq 0) "Schema Tests have $($results.FailedCount) failure(s)"
}

# Synopsis: Run all pester tests for the PowerShell module
task Pester {

    # Path to the PowerShell module to test
    $modulePath = Join-Path -Path $IBHConfig.BuildRoot -ChildPath $IBHConfig.ModuleName
    $resultPath = [System.IO.Path]::GetTempFileName()

    # Invoke the pester tests
    powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Set-Location -Path '$modulePath'; Invoke-Pester -OutputFile '$resultPath' -OutputFormat 'NUnitXml'"

    # Load the test results
    $results = [Xml] (Get-Content -Path $resultPath) | Select-Object -ExpandProperty 'test-results'

    assert ($results.failures -eq 0) "Pester Tests have $($results.failures) failure(s)"
}

# Synopsis: Invoke the script analyzer for the PowerShell module
task Analyze {

    # Path to the PowerShell module to test
    $modulePath = Join-Path -Path $IBHConfig.BuildRoot -ChildPath $IBHConfig.ModuleName

    # Invoke the script analyzer, run all defined rules
    $issues = @(Invoke-ScriptAnalyzer -Path $modulePath -IncludeRule $IBHConfig.ScriptAnalyzerRules -Recurse)

    # Show the issues as Pester-like results
    Show-ScriptAnalyzerResult -Path $BuildRoot -Issue $issues -Rule $IBHConfig.ScriptAnalyzerRules

    assert ($issues.Count -eq 0) "Script Analyzer has found $($issues.Count) issue(s)"
}

# Synopsis:
task Repository {

}

# Synopsis:
task Gallery {

}

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
task Build Verify, Init, Clean, Compile

# Synopsis: Test the module with pester and script analyzer
task Test Verify, Init, Pester, Schema, Analyze

# Synopsis: Release the module to the repository and the gallery
task Release Build, Test, Repository, Gallery

task Verify {

    Write-Host "********* $($IBHConfig.Demo) *********"

    # ToDo: Option to disable the verification via $IBHConfig.??Verify??

    $psGalleryApi = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='InvokeBuildHelper'"

    $actualVersion   = Get-Module -Name 'InvokeBuildHelper' | ForEach-Object { $_.Version.ToString() }
    $expectedVersion = Invoke-RestMethod -Uri $psGalleryApi | Select-Object -Last 1 | ForEach-Object { $_.properties.version }

    assert ($expectedVersion -eq $actualVersion) "The InvokeBuildHelper module version $actualVersion is not current, please update to $expectedVersion!"
}

# Synopsis: Ensure the required build environment is available
task Init {



    # $path = Join-Path -Path $IBHConfig.BuildRoot -ChildPath 'tst'
    # New-Item -Path $path -ItemType 'Directory' | Out-Null

    #irm -uri "" | Select-Object -Last 1 | ForEach-Object {$_.properties.version }
}

# Synopsis:
task Clean {

}

# Synopsis:
task Compile {

}

# Synopsis: Run all pester unit tests for the PowerShell module
task Pester {

    $Host.UI.WriteLine()

    # Inovke the Pester unit tests
    $result = Invoke-PesterUnitBuildTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) "$($result.FailedCount) failure(s) in Pester Unit tests"
}

# Synopsis: Test the PowerShell module schema
task Schema {

    $Host.UI.WriteLine()

    # Invoke the module schema tests
    $result = Invoke-ModuleSchemaBuildTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) "$($result.FailedCount) failure(s) in Module Schema tests"
}

# Synopsis: Invoke the script analyzer for the PowerShell module
task Analyze {

    $Host.UI.WriteLine()

    # Invoke the script analyzer, run all defined rules
    $result = Invoke-ScriptAnalyzerBuildTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -Rule $IBHConfig.ScriptAnalyzerRules

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) "$($result.FailedCount) failure(s) in Script Analyzer tests"
}

# Synopsis:
task Repository {

}

# Synopsis:
task Gallery {

}

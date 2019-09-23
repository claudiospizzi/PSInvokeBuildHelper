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
$IBHConfig = Get-IBHConfig -BuildRoot $BuildRoot

# Synopsis: By default, bulid and test the module
task . Build, Test

# Synopsis: Compile the library projects
task Build Verify, Init, Clean, Compile

# Synopsis: Test the module with pester and script analyzer
task Test Verify, Init, Pester, Schema, Analyze

# Synopsis: Release the module to the repository and the gallery
task Release Build, Test, Repository, Gallery

# Synopsis: Verify the build system itself
task Verify {

    if ($IBHConfig.Verify.InvokeBuildHelperVersion)
    {
        $psGalleryApi = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='InvokeBuildHelper'"

        $expectedVersion = Invoke-RestMethod -Uri $psGalleryApi | Select-Object -Last 1 | ForEach-Object { $_.properties.version }
        $actualVersion   = Get-Module -Name 'InvokeBuildHelper' | ForEach-Object { $_.Version.ToString() }

        assert ($expectedVersion -eq $actualVersion) "The InvokeBuildHelper module version $actualVersion is not current, please update to $expectedVersion!"
    }
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
    $result = Invoke-IBHPesterUnitTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) "$($result.FailedCount) failure(s) in Pester Unit tests"
}

# Synopsis: Test the PowerShell module schema
task Schema {

    $Host.UI.WriteLine()

    # Invoke the module schema tests
    $result = Invoke-IBHModuleSchemaTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) "$($result.FailedCount) failure(s) in Module Schema tests"
}

# Synopsis: Invoke the script analyzer for the PowerShell module
task Analyze {

    $Host.UI.WriteLine()

    # Invoke the script analyzer, run all defined rules
    $result = Invoke-IBHScriptAnalyzerTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -Rule $IBHConfig.ScriptAnalyzerRules

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) "$($result.FailedCount) failure(s) in Script Analyzer tests"
}

# Synopsis: Release the module to the source code repository
task Repository {

    $moduleVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

    $gitBranch = Get-IBHGitBranch
    assert ($gitBranch -eq 'master') "Module is not ready to release, git branch should be on master but is $gitBranch!  (git checkout master)"

    $gitBehindBy = Get-IBHGitBehindBy
    assert ($gitBehindBy -eq 0) "Module is not ready to release, git branch is behind by $gitBehindBy!  (git pull)"

    $gitAheadBy = Get-IBHGitAheadBy
    assert ($gitAheadBy -eq 0) "Module is not ready to release, git branch is ahead by $gitAheadBy!  (git push)"

    $gitLocalTag = Get-IBHGitLocalTag
    assert ($gitLocalTag -eq $moduleVersion) "Module is not ready to release, tag $gitLocalTag does not match module version $moduleVersion!  (git tag $moduleVersion)"

    $gitRemoteTag = Get-IBHGitRemoteTag -ModuleVersion $moduleVersion
    assert ($gitRemoteTag -eq $moduleVersion) "Module is not ready to release, tag $moduleVersion does not exist on origin!  (git push --tag)"

    $changeLogVersion = Get-IBHChangeLogVersion -BuildRoot $BuildRoot -ModuleVersion $ModuleVersion
    assert ($changeLogVersion -eq $moduleVersion) "Module is not ready to release, change log does not contain the current version and date!"

    Publish-IBHRepository -BuildRoot $BuildRoot -ModuleName $ModuleName
}

# Synopsis: Release the module to the PowerShell Gallery
task Gallery {

    $moduleVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

    $gitBranch = Get-IBHGitBranch
    assert ($gitBranch -eq 'master') "Module is not ready to release, git branch should be on master but is $gitBranch!  (git checkout master)"

    $gitBehindBy = Get-IBHGitBehindBy
    assert ($gitBehindBy -eq 0) "Module is not ready to release, git branch is behind by $gitBehindBy!  (git pull)"

    $gitAheadBy = Get-IBHGitAheadBy
    assert ($gitAheadBy -eq 0) "Module is not ready to release, git branch is ahead by $gitAheadBy!  (git push)"

    $gitLocalTag = Get-IBHGitLocalTag
    assert ($gitLocalTag -eq $moduleVersion) "Module is not ready to release, tag $gitLocalTag does not match module version $moduleVersion!  (git tag $moduleVersion)"

    $gitRemoteTag = Get-IBHGitRemoteTag -ModuleVersion $moduleVersion
    assert ($gitRemoteTag -eq $moduleVersion) "Module is not ready to release, tag $moduleVersion does not exist on origin!  (git push --tag)"

    $changeLogVersion = Get-IBHChangeLogVersion -BuildRoot $BuildRoot -ModuleVersion $ModuleVersion
    assert ($changeLogVersion -eq $moduleVersion) "Module is not ready to release, change log does not contain the current version and date!"

    Publish-IBHGallery -BuildRoot $BuildRoot -ModuleName $ModuleName
}

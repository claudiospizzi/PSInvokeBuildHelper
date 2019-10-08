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

# Synopsis: By default, bulid and test the module. This task should be used
# during the development of the target module
task . Verify, Build, Test

# Synopsis: Release the module to the repository and the gallery. This task is
# used to publish a new module version
task Release Verify, Build, Test, Repository, Gallery

# Synopsis: Build the C# solutions
task Build Clean, Compile

# Synopsis: Test the module with pester and script analyzer
task Test Pester, Schema, Analyze





# Synopsis: Verify the build system itself
task Verify {

    if ($IBHConfig.VerifyTask.Enabled)
    {
        $psGalleryApi = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='InvokeBuildHelper'"

        $expectedVersion = Invoke-RestMethod -Uri $psGalleryApi | Select-Object -Last 1 | ForEach-Object { $_.properties.version }
        $actualVersion   = Get-Module -Name 'InvokeBuildHelper' | ForEach-Object { $_.Version.ToString() }

        assert ($expectedVersion -eq $actualVersion) "The InvokeBuildHelper module version $actualVersion is not current, please update to $expectedVersion!"
    }
    else
    {
        Write-Warning 'Verify task is disabled, no meta tests before build!'
    }
}

# Synopsis: Ensure the required build environment is available
task Init {

    throw 'Not implemented!'

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

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Pester Unit tests' -f $result.FailedCount)
}

# Synopsis: Test the PowerShell module schema
task Schema {

    $Host.UI.WriteLine()

    # Invoke the module schema tests
    $result = Invoke-IBHModuleSchemaTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Module Schema tests' -f $result.FailedCount)
}

# Synopsis: Invoke the script analyzer for the PowerShell module
task Analyze {

    $Host.UI.WriteLine()

    # Invoke the script analyzer, run all defined rules
    $result = Invoke-IBHScriptAnalyzerTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -Rule $IBHConfig.AnalyzeTask.ScriptAnalyzerRules

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Script Analyzer tests' -f $result.FailedCount)
}

# Synopsis:
task Approve {

    if ($IBHConfig.ApproveTask.Enabled)
    {
        $moduleVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

        $gitBranch = Get-IBHGitBranch
        #assert ($gitBranch -eq $IBHConfig.ApproveTask.BranchName) ('Module is not ready to release, git branch should be on {0} but is {1}!  (git checkout {0})' -f $IBHConfig.ApproveTask.BranchName, $gitBranch)

        $gitBehindBy = Get-IBHGitBehindBy
        #assert ($gitBehindBy -eq 0) ('Module is not ready to release, git branch is behind by {0}!  (git pull)' -f $gitBehindBy)

        $gitAheadBy = Get-IBHGitAheadBy
        #assert ($gitAheadBy -eq 0) ('Module is not ready to release, git branch is ahead by {0}!  (git push)' -f $gitAheadBy)

        $gitLocalTag = Get-IBHGitLocalTag
        # assert ($gitLocalTag -eq $moduleVersion) ('Module is not ready to release, tag {0} does not match module version {1}!  (git tag {1})' -f $gitLocalTag, $moduleVersion)

        $gitRemoteTag = Get-IBHGitRemoteTag -ModuleVersion $moduleVersion
        # assert ($gitRemoteTag -eq $moduleVersion) ('Module is not ready to release, tag {0} does not exist on origin!  (git push --tag)' -f $moduleVersion)

        $changeLogVersion = Get-IBHChangeLogVersion -BuildRoot $IBHConfig.BuildRoot -ModuleVersion $moduleVersion
        # assert ($changeLogVersion -eq $moduleVersion) ('Module is not ready to release, CHANGELOG.md does not contain the current version and/or date!  (## {0} - {1:yyyy-MM-dd})' -f $moduleVersion, [DateTime]::Now)
    }
    else
    {
        Write-Warning 'Approve task is disabled, no approval tests before release!'
    }
}

# Synopsis: Release the module to the source code repository
task Repository Approve, {

    if ($IBHConfig.RepositoryTask.Enabled)
    {
        Publish-IBHRepository -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -ModuleVersion $moduleVersion
    }
    else
    {
        Write-Warning 'Repository task is disabled, no release to the repository!'
    }
}

# Synopsis: Release the module to the PowerShell Gallery
task Gallery Approve, {

    if ($IBHConfig.GalleryTask.Enabled)
    {
        $repositoryNames = Get-PSRepository | Select-Object -ExpandProperty 'Name'
        assert ($repositoryNames -contains $IBHConfig.GalleryTask.Name) ('Module is not ready to release, PowerShell Repository {0} is not registered!  (Register-PSRepository -Name "{0}" ...)' -f $IBHConfig.GalleryTask.Name)

        Publish-IBHGallery -BuildRoot $BuildRoot -ModuleName $ModuleName
    }
    else
    {
        Write-Warning 'Gallery task is disabled, no release to the gallery!'
    }
}

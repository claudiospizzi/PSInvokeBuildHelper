<#
    .SYNOPSIS
        Common build tasks for a PowerShell module.

    .DESCRIPTION
        .

    .LINK
        https://github.com/nightroman/Invoke-Build
        https://github.com/claudiospizzi/InvokeBuildHelper
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param ()

# Load the build configuration
$IBHConfig = Get-IBHConfig -BuildRoot $BuildRoot

# Synopsis: The default task will verify, build and test the module. This task
# is intended to be used during the development of the target module.
task . Verify, Build, Test

# Synopsis: Release the module to the repository and the gallery. This task is
# used to publish a new module version.
task Release Verify, Build, Test, Repository, Gallery

# Synopsis: Build the C# solutions, if any exists. This includes clean, compile
# and deploy.
task Build Clean, Compile, Deploy

# Synopsis: Test the module with pester and script analyzer. This includes
# schema tests, module unit tests and script analyzer rules.
task Test Pester, Schema, Analyze

# Synopsis: Verify the build system itself, like the InvokeBuild and
# InvokeBuildHelper module version.
task Verify {

    if ($IBHConfig.VerifyTask.Enabled)
    {
        $invokeBuildModuleVersion = '5.5.3'

        $psGalleryApi = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='InvokeBuildHelper'"

        $expectedVersion = Invoke-RestMethod -Uri $psGalleryApi | Select-Object -Last 1 | ForEach-Object { $_.properties.version }
        $actualVersion   = Get-Module -Name 'InvokeBuildHelper' | ForEach-Object { $_.Version.ToString() }

        assert ((Get-Module -Name 'InvokeBuild').Version -ge $invokeBuildModuleVersion) "The InvokeBuild module version should be $invokeBuildModuleVersion or higher!"
        assert ($expectedVersion -eq $actualVersion) "The InvokeBuildHelper module version $actualVersion is not current, please update to $expectedVersion!"
    }
    else
    {
        Write-Warning 'Verify task is disabled, no meta tests before build!'
    }
}

# Synopsis:
task Clean {

    #throw 'Not implemented!'
}

# Synopsis:
task Compile {

    #throw 'Not implemented!'
}

# Synopsis:
task Deploy {

    #throw 'Not implemented!'
}

# Synopsis: Run all pester unit tests for the PowerShell module
task Pester {

    $Host.UI.WriteLine()

    # Create output folder
    $outputPath = New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Select-Object -ExpandProperty 'FullName'

    # Inovke the Pester unit tests
    $result = Invoke-IBHPesterUnitTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -OutputPath $outputPath

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Pester Unit tests' -f $result.FailedCount)
}

# Synopsis: Test the PowerShell module schema
task Schema {

    $Host.UI.WriteLine()

    # Create output folder
    $outputPath = New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Select-Object -ExpandProperty 'FullName'

    # Invoke the module schema tests
    $result = Invoke-IBHModuleSchemaTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -OutputPath $outputPath

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Module Schema tests' -f $result.FailedCount)
}

# Synopsis: Invoke the script analyzer for the PowerShell module
task Analyze {

    $Host.UI.WriteLine()

    # Create output folder
    $outputPath = New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Select-Object -ExpandProperty 'FullName'

    # Invoke the script analyzer, run all defined rules
    $result = Invoke-IBHScriptAnalyzerTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -Rule $IBHConfig.AnalyzeTask.ScriptAnalyzerRules -OutputPath $outputPath

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Script Analyzer tests' -f $result.FailedCount)
}

# Synopsis:
task Approve {

    if ($IBHConfig.ApproveTask.Enabled)
    {
        $moduleVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

        $gitBranch = Get-IBHGitBranch
        assert ($gitBranch -eq $IBHConfig.ApproveTask.BranchName) ('Module is not ready to release, git branch should be on {0} but is {1}!  (git checkout {0})' -f $IBHConfig.ApproveTask.BranchName, $gitBranch)

        $gitBehindBy = Get-IBHGitBehindBy
        assert ($gitBehindBy -eq 0) ('Module is not ready to release, git branch is behind by {0}!  (git pull)' -f $gitBehindBy)

        $gitAheadBy = Get-IBHGitAheadBy
        assert ($gitAheadBy -eq 0) ('Module is not ready to release, git branch is ahead by {0}!  (git push)' -f $gitAheadBy)

        $gitLocalTag = Test-IBHGitLocalTag -ModuleVersion $moduleVersion
        assert $gitLocalTag ('Module is not ready to release, tag {0} does not exist or is not on the last commit!  (git tag {1})' -f $moduleVersion)

        $gitRemoteTag = Test-IBHGitRemoteTag -ModuleVersion $moduleVersion
        assert $gitRemoteTag ('Module is not ready to release, tag {0} does not exist on origin!  (git push --tag)' -f $moduleVersion)

        $changeLogVersion = Test-IBHChangeLogVersion -BuildRoot $IBHConfig.BuildRoot -ModuleVersion $moduleVersion -ReleaseDate [DateTime]::Now
        assert $changeLogVersion ('Module is not ready to release, CHANGELOG.md does not contain the current version and/or date!  (## {0} - {1:yyyy-MM-dd})' -f $moduleVersion, [DateTime]::Now)
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
        throw 'Not implemented!'

        $publishIBHRepository = @{
            BuildRoot       = $BuildRoot
            ModuleName      = $ModuleName
            ModuleVersion   = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName
            RepositoryType  = $IBHConfig.RepositoryTask.Type
            RepositoryName  = $IBHConfig.RepositoryTask.Name
            RepositoryUser  = $IBHConfig.RepositoryTask.User
            RepositoryToken = $IBHConfig.RepositoryTask.Token
        }
        Publish-IBHRepository @publishIBHRepository
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
        $galleryNames = Get-PSRepository | Select-Object -ExpandProperty 'Name'
        assert ($galleryNames -contains $IBHConfig.GalleryTask.Name) ('Module is not ready to release, PowerShell Gallery {0} is not registered!  (Register-PSRepository -Name "{0}" ...)' -f $IBHConfig.GalleryTask.Name)

        $publishIBHGallerySplat = @{
            BuildRoot     = $BuildRoot
            ModuleName    = $ModuleName
            ModuleVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName
            GalleryUser   = $IBHConfig.GalleryTask.User
            GalleryName   = $IBHConfig.GalleryTask.Name
            GalleryToken  = $IBHConfig.GalleryTask.Token
        }
        Publish-IBHGallery @publishIBHGallerySplat
    }
    else
    {
        Write-Warning 'Gallery task is disabled, no release to the gallery!'
    }
}

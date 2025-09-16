<#
    .SYNOPSIS
        Common build tasks for a PowerShell module.

    .DESCRIPTION
        Script with the common build tasks definition. The configuration will be
        stored in the $IBHConfig variable.

    .LINK
        https://github.com/nightroman/Invoke-Build
        https://github.com/claudiospizzi/PSInvokeBuildHelper
#>

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param ()

# Load the build configuration
$IBHConfig = Get-IBHConfig -BuildRoot $BuildRoot

# Stop this build if we try to release the module itself. This is not supported at all.
if ($null -ne (Get-PSCallStack | Where-Object { $_.Command -eq 'Invoke-Build.ps1' -and $_.Arguments -like '*Task=Release*' }) -and $IBHConfig.ModuleName -eq 'InvokeBuildHelper')
{
    throw 'Release task is not supported for the module InvokeBuildHelper itself! Please use the sub-tasks Gallery and Repository.'
}

# Synopsis: The default task will verify, build and test the module. This task is intended to be used during the development of the target module.
task . Verify, Build, Test

# Synopsis: Release the module to the repository and the gallery. This task is used to publish a new module version.
task Release Verify, Build, Test, Repository, Gallery, ZipFile

# Synopsis: Build the C# solutions, if any exists. This includes clean, compile and deploy.
task Build Clean, Compile

# Synopsis: Test the module with pester and script analyzer. This includes schema tests, module unit tests and script analyzer rules.
task Test UnitTest, SchemaTest, AnalyzerTest

# Synopsis: Verify the build system itself, like the InvokeBuild and InvokeBuildHelper module version.
task Verify {

    if ($IBHConfig.VerifyTask.Enabled)
    {
        # Ensure the module dependency on InvokeBuild is ok
        $ibActualVersion   = Get-Module -Name 'InvokeBuild' | Select-Object -ExpandProperty 'Version'
        $ibRequiredVersion = [System.Version] $IBHConfig.VerifyTask.InvokeBuildVersion
        assert ($ibActualVersion -ge $ibRequiredVersion) "The InvokeBuild module version $ibActualVersion is outdated, please update to $ibRequiredVersion or later!"

        # Ensure the module dependency on InvokeBuildHelper itself is ok
        $ibhActualVersion   = Get-Module -Name 'InvokeBuildHelper' | Select-Object -ExpandProperty 'Version'
        $ibhRequiredVersion = Invoke-RestMethod -Uri $IBHConfig.VerifyTask.ModulePackageUrl -TimeoutSec 5 | Select-Object -Last 1 | ForEach-Object { [System.Version] $_.properties.version }
        assert ($ibhActualVersion -ge $ibhRequiredVersion) "The InvokeBuildHelper module version $ibhActualVersion is outdated, please update to $ibhRequiredVersion or later!"
    }
    else
    {
        Write-Warning 'Verify task is disabled, no meta tests before build!'
    }
}

# Synopsis: Planned task for C# solution clean.
task Clean {

    if (-not [System.String]::IsNullOrEmpty($IBHConfig.SolutionName))
    {
        $Host.UI.WriteLine()

        # Get the MSBuild command
        $msBuildCommand = Resolve-MSBuild

        # Define the solution name to compile
        $solutionFile = '{0}\{1}\{1}.sln' -f $IBHConfig.BuildRoot, $IBHConfig.SolutionName

        # Invoke the release build
        exec { & "$msBuildCommand" "$solutionFile" /p:Configuration=Release /t:Clean /v:minimal }

        $Host.UI.WriteLine()
    }
}

# Synopsis: Planned task for C# solution compile.
task Compile {

    if (-not [System.String]::IsNullOrEmpty($IBHConfig.SolutionName))
    {
        $Host.UI.WriteLine()

        # Get the MSBuild command
        $msBuildCommand = Resolve-MSBuild

        # Define the solution name to compile
        $solutionFile = '{0}\{1}\{1}.sln' -f $IBHConfig.BuildRoot, $IBHConfig.SolutionName

        # Invoke the release build
        exec { & "$msBuildCommand" "$solutionFile" /p:Configuration=Release /t:Build /v:minimal }

        $Host.UI.WriteLine()
    }
}

# Synopsis: Run all pester unit tests for the PowerShell module.
task UnitTest {

    $Host.UI.WriteLine()

    # Create output folder
    $outputPath = New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Select-Object -ExpandProperty 'FullName'

    # Invoke the Pester unit tests
    $result = Invoke-IBHPesterUnitTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -OutputPath $outputPath

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Pester Unit tests' -f $result.FailedCount)
}

# Synopsis: Run all pester integration tests for the PowerShell module.
task IntegrationTest {

    $Host.UI.WriteLine()

    # Create output folder
    $outputPath = New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Select-Object -ExpandProperty 'FullName'

    # Invoke the Pester integration tests
    $result = Invoke-IBHPesterIntegrationTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -OutputPath $outputPath

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Pester Integration tests' -f $result.FailedCount)
}

# Synopsis: Test the PowerShell module schema.
task SchemaTest {

    $Host.UI.WriteLine()

    # Create output folder
    $outputPath = New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Select-Object -ExpandProperty 'FullName'

    # Invoke the module schema tests
    $result = Invoke-IBHModuleSchemaTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -TextFileExtension $IBHConfig.SchemaTask.TextFileExtension -ExcludePath $IBHConfig.SchemaTask.ExcludePath -OutputPath $outputPath

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Module Schema tests' -f $result.FailedCount)
}

# Synopsis: Invoke the script analyzer for the PowerShell module.
task AnalyzerTest {

    $Host.UI.WriteLine()

    # Create output folder
    $outputPath = New-Item -Path (Join-Path -Path $BuildRoot -ChildPath 'out') -ItemType 'Directory' -Force | Select-Object -ExpandProperty 'FullName'

    # Invoke the script analyzer, run all defined rules
    $result = Invoke-IBHScriptAnalyzerTest -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName -Rule $IBHConfig.AnalyzerTestTask.ScriptAnalyzerRules -ExcludePath $IBHConfig.AnalyzerTestTask.ExcludePath -OutputPath $outputPath

    $Host.UI.WriteLine()

    assert ($result.FailedCount -eq 0) ('{0} failure(s) in Script Analyzer tests' -f $result.FailedCount)
}

# Synopsis: Verify if the module is ready to be released.
task Approve {

    if ($IBHConfig.ApproveTask.Enabled)
    {
        $moduleVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

        # Only verify the git status if we locally release the module. On a
        # CI/CD system this is not required and skipped.
        if ($Env:CI -ne 'true')
        {
            $gitPendingFile = Get-IBHGitPendingFile
            assert ($gitPendingFile -eq 0) ('Module is not ready to release, {0} pending file(s) are present in the repo!' -f $gitPendingFile)

            $gitBranch = Get-IBHGitBranch
            assert ($gitBranch -eq $IBHConfig.ApproveTask.BranchName) ('Module is not ready to release, git branch should be on {0} but is {1}!  (git checkout {0})' -f $IBHConfig.ApproveTask.BranchName, $gitBranch)

            $gitBehindBy = Get-IBHGitBehindBy
            assert ($gitBehindBy -eq 0) ('Module is not ready to release, git branch is behind by {0}!  (git pull)' -f $gitBehindBy)

            $gitAheadBy = Get-IBHGitAheadBy
            assert ($gitAheadBy -eq 0) ('Module is not ready to release, git branch is ahead by {0}!  (git push)' -f $gitAheadBy)

            $gitLocalTag = Test-IBHGitLocalTag -ModuleVersion $moduleVersion
            assert $gitLocalTag ('Module is not ready to release, tag {0} does not exist or is not on the last commit!  (git tag {0})' -f $moduleVersion)

            $gitRemoteTag = Test-IBHGitRemoteTag -ModuleVersion $moduleVersion
            assert $gitRemoteTag ('Module is not ready to release, tag {0} does not exist on origin!  (git push --tag)' -f $moduleVersion)
        }

        $changeLogVersion = Test-IBHChangeLogVersion -BuildRoot $IBHConfig.BuildRoot -ModuleVersion $moduleVersion
        assert $changeLogVersion ('Module is not ready to release, CHANGELOG.md does not contain the current version (and optionally date)!  (## {0})' -f $moduleVersion)

        if (-not [System.String]::IsNullOrEmpty($IBHConfig.SolutionName))
        {
            $solutionVersion = Test-IBHSolutionVersion -BuildRoot $IBHConfig.BuildRoot -SolutionName $IBHConfig.SolutionName -ModuleVersion $moduleVersion
            assert $solutionVersion ('Solution assembly info version does not match the module version {0}!' -f $moduleVersion)
        }

        if ($IBHConfig.GalleryTask.Enabled)
        {
            $galleryNames = Get-PSRepository | Select-Object -ExpandProperty 'Name'
            assert ($galleryNames -contains $IBHConfig.GalleryTask.Name) ('Module is not ready to release, PowerShell Gallery {0} is not registered!  (Register-PSRepository -Name "{0}" ...)' -f $IBHConfig.GalleryTask.Name)
        }
    }
    else
    {
        Write-Warning 'Approve task is disabled, no approval tests before release!'
    }
}

# Synopsis: Release the module to the source code repository.
task Repository Build, Approve, {

    if ($IBHConfig.RepositoryTask.Enabled)
    {
        $token = $null
        if ($null -ne $IBHConfig.RepositoryTask.Token)
        {
            $token = $IBHConfig.RepositoryTask.Token
        }
        elseif ($null -ne $IBHConfig.RepositoryTask.TokenCallback)
        {
            $token = & $IBHConfig.RepositoryTask.TokenCallback
        }

        assert ($null -ne $token -and $token -is [System.Security.SecureString]) 'Repository Token is missing, please set one of the following variables: $IBHConfig.RepositoryTask.Token or $IBHConfig.RepositoryTask.TokenCallback'

        $publishIBHRepository = @{
            BuildRoot       = $IBHConfig.BuildRoot
            ModuleName      = $IBHConfig.ModuleName
            ModuleVersion   = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName
            RepositoryType  = $IBHConfig.RepositoryTask.Type
            RepositoryUser  = $IBHConfig.RepositoryTask.User
            RepositoryName  = $IBHConfig.RepositoryTask.Name
            RepositoryToken = $token
        }
        Publish-IBHRepository @publishIBHRepository
    }
    else
    {
        Write-Warning 'Repository task is disabled, no release to the repository!'
    }
}

# Synopsis: Release the module to the PowerShell Gallery.
task Gallery Build, Approve, {

    if ($IBHConfig.GalleryTask.Enabled)
    {
        $token = $null
        if ($null -ne $IBHConfig.GalleryTask.Token)
        {
            $token = $IBHConfig.GalleryTask.Token
        }
        elseif ($null -ne $IBHConfig.GalleryTask.TokenCallback)
        {
            $token = & $IBHConfig.GalleryTask.TokenCallback
        }

        assert ($null -ne $token -and $token -is [System.Security.SecureString]) 'Gallery Token is missing, please set one of the following variables: $IBHConfig.GalleryTask.Token or $IBHConfig.GalleryTask.TokenCallback'

        $publishIBHGallerySplat = @{
            BuildRoot     = $IBHConfig.BuildRoot
            ModuleName    = $IBHConfig.ModuleName
            ModuleVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName
            GalleryUser   = $IBHConfig.GalleryTask.User
            GalleryName   = $IBHConfig.GalleryTask.Name
            GalleryToken  = $token
        }
        Publish-IBHGallery @publishIBHGallerySplat
    }
    else
    {
        Write-Warning 'Gallery task is disabled, no release to the gallery!'
    }
}

# Synopsis: Release the module to the local file system as zip file.
task ZipFile Build, Approve, {

    if ($IBHConfig.ZipFileTask.Enabled)
    {
        $publishIBHZipFileSplat = @{
            BuildRoot     = $IBHConfig.BuildRoot
            ModuleName    = $IBHConfig.ModuleName
            ModuleVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName
        }
        Publish-IBHZipFile @publishIBHZipFileSplat
    }
    else
    {
        Write-Warning 'ZipFile task is disabled, no release to the local file system!'
    }
}

# Synopsis: Deploy a beta version as revision to the local module repository.
task Deploy Build, {

    # Get the module version
    $sourceVersion = Get-IBHModuleVersion -BuildRoot $IBHConfig.BuildRoot -ModuleName $IBHConfig.ModuleName

    # Get the latest installed module version
    $targetVersion = Get-ChildItem -Path $IBHConfig.DeployTask.ModulePaths -Directory |
                         Where-Object { $_.Name -eq $IBHConfig.ModuleName } |
                             Get-ChildItem -Directory |
                                 ForEach-Object { [System.Version] $_.Name } |
                                     Sort-Object -Descending |
                                         Select-Object -First 1

    # No version found, start with 0.0.0
    if ([System.String]::IsNullOrEmpty($targetVersion))
    {
        $targetVersion = [System.Version] '0.0.0'
    }

    # Increase the revision by one
    $targetVersion = [System.Version] ('{0}.{1}.{2}.{3}' -f $targetVersion.Major, $targetVersion.Minor, $targetVersion.Build, ($targetVersion.Revision + 1))

    # Define the output path
    $Host.UI.WriteLine()
    foreach ($modulePath in $IBHConfig.DeployTask.ModulePaths)
    {
        $sourcePath = '{0}\{1}\*' -f $IBHConfig.BuildRoot, $IBHConfig.ModuleName
        $targetPath = '{0}\{1}\{2}' -f $modulePath, $IBHConfig.ModuleName, $targetVersion
        $targetFile = '{0}\{1}.psd1' -f $targetPath, $IBHConfig.ModuleName

        $Host.UI.WriteLine(('  {0} {1} -> {2}' -f $IBHConfig.ModuleName, $targetVersion, $targetPath))

        # Create the output folder
        New-Item -Path $targetPath -ItemType 'Directory' -Force | Out-Null

        # Deploy the module with recursive copy
        Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force

        # Path the module definition
        $definition = Get-Content -Path $targetFile
        $definition = $definition -replace "ModuleVersion = '$sourceVersion'", "ModuleVersion = '$targetVersion'"
        $definition | Set-Content -Path $targetFile -Encoding 'UTF8'
    }
    $Host.UI.WriteLine()
}

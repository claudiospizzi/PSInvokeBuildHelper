[![PowerShell Gallery - InvokeBuildHelper](https://img.shields.io/badge/PowerShell_Gallery-InvokeBuildHelper-0072C6.svg)](https://www.powershellgallery.com/packages/InvokeBuildHelper)
[![GitHub - Release](https://img.shields.io/github/release/claudiospizzi/InvokeBuildHelper.svg)](https://github.com/claudiospizzi/InvokeBuildHelper/releases)
[![AppVeyor - master](https://img.shields.io/appveyor/ci/claudiospizzi/InvokeBuildHelper/master.svg)](https://ci.appveyor.com/project/claudiospizzi/InvokeBuildHelper/branch/master)

# InvokeBuildHelper PowerShell Module

Common build tasks for the [Invoke-Build](https://github.com/nightroman/Invoke-Build) PowerShell module.

## Introduction

This module includes a script with common build tasks for a PowerShell module. A manifest module using script files is the main target. The module can include some C# .NET based libraries, they will be build with Release options before the build script runs. The core build script with all tasks can be found here:

* [InvokeBuildHelper/Scripts/InvokeBuildHelperTasks.ps1](https://github.com/claudiospizzi/InvokeBuildHelper/blob/master/InvokeBuildHelper/Scripts/InvokeBuildHelperTasks.ps1)

## Features

### Build Script

Even the module exports multiple command with the *IBH* prefix, only the build
script should be used. The following example of a `.build.ps1` script can be
used, if the repository is hosted on GitHub and the module is published to the
official PowerShell Gallery:

```powershell
# Import build tasks
. InvokeBuildHelperTasks

# Build configuration
$IBHConfig.VerifyTask.Enabled   = $false
$IBHConfig.RepositoryTask.Token = Use-VaultSecureString -TargetName 'GitHub Token'
$IBHConfig.GalleryTask.Token    = Use-VaultSecureString -TargetName 'PowerShell Gallery Key'
```

### Build Tasks

* **Default (.)**  
    The default task will verify, build and test the module. This task is intended to be used during the development of the target module.

* **Release**  
    Release the module to the repository and the gallery. This task is used to publish a new module version.

* **Verify**  
    Verify the build system itself, like the InvokeBuild and InvokeBuildHelper module version.

* **Build**  
    Build the C# solutions, if any exists. This includes clean, compile and deploy.

* **Test**  
    Test the module with pester and script analyzer. This includes schema tests, module unit tests and script analyzer rules.

* **Clean**  
    Planned task for C# solution clean. (NOT IMPLEMENTED)

* **Compile**  
    Planned task for C# solution compile. (NOT IMPLEMENTED)

* **Deploy**  
    Planned task for C# solution deploy. (NOT IMPLEMENTED)
  
* **Pester**  
    Run all pester unit tests for the PowerShell module.

* **Schema**  
    Test the PowerShell module schema.

* **Analyze**  
    Invoke the script analyzer for the PowerShell module.

* **Approve**  
    Verify if the module is ready to be released.

* **Repository**  
    Release the module to the source code repository.

* **Gallery**  
    Release the module to the PowerShell Gallery.

* **Deploy**  
    Deploy a beta version as revision to the local module repository.

### Configuration

The following configuration is set by default or generated on the fly for the
build system. An demo value is shown in this example for generated properties.
Every configuration can be overwritten after importing the build script
`InvokeBuildHelperTasks` in the `.build.ps1` scripts.

```powershell
# Path to the module root folder (auto generated)
$IBHConfig.BuildRoot = 'C:\GitHub\InvokeBuildHelper'

# Name of the module to build (auto generated)
$IBHConfig.ModuleName = 'InvokeBuildHelper'

# Verify Task: Option to enable or disable the verification tests (default)
$IBHConfig.VerifyTask.Enabled = $true

# Verify Task: Minimum version of the InvokeBuild module (default)
$IBHConfig.VerifyTask.InvokeBuildVersion = '5.5.5'

# Verify Task: Url to the PowerShell Gallery to get the latest InvokeBuildHelper version (default)
$IBHConfig.VerifyTask.ModulePackageUrl = "https://www.powershellgallery.com/api/v2/FindPackagesById()?id='InvokeBuildHelper'"

# Schema Task: List of text file extension (default)
$IBHConfig.SchemaTask.TextFileExtension = '.gitignore', '.gitattributes', '.ps1', '.psm1', '.psd1', '.ps1xml', '.txt', '.xml', '.cmd', '.json', '.md'

# Analyze Task: Rules to process by the PowerShell Script Analyzer (default)
$IBHConfig.AnalyzeTask.ScriptAnalyzerRules = Get-ScriptAnalyzerRule

# Approve Task: Option to enable or disable the release approval tests (default)
$IBHConfig.ApproveTask.Enabled = $true

# Approve Task: Target branch for the release (default)
$IBHConfig.ApproveTask.BranchName = 'master'

# Repository Task: Option to enable or disable the release to the repository (default)
$IBHConfig.RepositoryTask.Enabled = $true

# Repository Task: By default, the repository is a GitHub repo (default)
$IBHConfig.RepositoryTask.Type = 'GitHub'

# Repository Task: The name of the user (auto generated)
$IBHConfig.RepositoryTask.User = 'claudiospizzi'

# Repository Task: The name of the repository (auto generated)
$IBHConfig.RepositoryTask.Name = 'InvokeBuildHelper'

# Repository Task: The secret token to access the GitHub api (default)
$IBHConfig.RepositoryTask.Token = ''

# Gallery Task: Option to enable or disable the release to the gallery (default)
$IBHConfig.GalleryTask.Enabled = $true

# Gallery Task: Name of the PowerShell Gallery user, assume it's the same as GitHub (auto generated)
$IBHConfig.GalleryTask.User = 'claudiospizzi'

# Gallery Task: Name of the PowerShell Gallery repository (default)
$IBHConfig.GalleryTask.Name = 'PSGallery'

# Gallery Task: The secret token to access the PowerShell Gallery (default)
$IBHConfig.GalleryTask.Token = ''

# Deploy Task: The module path where the beta revision is deployed (auto generated)
$IBHConfig.DeployTask.ModulePath = 'C:\Users\ClaudioSpizzi\Documents\WindowsPowerShell\Modules'
```

### C# Libraries

The InvokeBuildHelper module supports building C# .NET class library. It's
recommended to use the target framework .NET Standard 2.1. Normally, only one
class library is used with the `.Library` suffix. The following example shows
how to create a new class library project:

```cmd
dotnet new classlib -f netstandard2.1 -o InvokeBuildHelper.Library
```

## Versions

Please find all versions in the [GitHub Releases] section and the release notes
in the [CHANGELOG.md] file.

## Installation

Use the following command to install the module from the [PowerShell Gallery],
if the PackageManagement and PowerShellGet modules are available:

```powershell
# Download and install the module
Install-Module -Name 'InvokeBuildHelper'
```

Alternatively, download the latest release from GitHub and install the module
manually on your local system:

1. Download the latest release from GitHub as a ZIP file: [GitHub Releases]
2. Extract the module and install it: [Installing a PowerShell Module]

## Requirements

The following minimum requirements are necessary to use this module, or in other
words are used to test this module:

* Windows PowerShell 5.1
* Windows 10 (for the File Explorer Namespace functions)

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code] with the [PowerShell Extension]
* [Pester], [PSScriptAnalyzer] and [psake] PowerShell Modules

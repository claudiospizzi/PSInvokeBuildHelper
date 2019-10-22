[![PowerShell Gallery - InvokeBuildHelper](https://img.shields.io/badge/PowerShell_Gallery-InvokeBuildHelper-0072C6.svg)](https://www.powershellgallery.com/packages/InvokeBuildHelper)
[![GitHub - Release](https://img.shields.io/github/release/claudiospizzi/InvokeBuildHelper.svg)](https://github.com/claudiospizzi/InvokeBuildHelper/releases)
[![AppVeyor - master](https://img.shields.io/appveyor/ci/claudiospizzi/InvokeBuildHelper/master.svg)](https://ci.appveyor.com/project/claudiospizzi/InvokeBuildHelper/branch/master)

# InvokeBuildHelper PowerShell Module

Common build tasks for the Invoke-Build PowerShell module.

## Introduction

This module includes a script with common build tasks for a PowerShell module. A manifest module using script files is the main target. The module can include some C# .NET based libraries, they will be build with Release options before the build script runs. The core build script with all tasks can be found here:

* [InvokeBuildHelper/Scripts/InvokeBuildHelperTasks.ps1](https://github.com/claudiospizzi/InvokeBuildHelper/blob/master/InvokeBuildHelper/Scripts/InvokeBuildHelperTasks.ps1)


## Features

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

* **Compile**

* **Deploy**
    

* **Pester**

* **Schema**

* **Analyze**

* **Approve**

* **Repository**

* **Gallery**




### Commands

* **Register-BuildTask**  
  ...

### Build Tasks



ToDo: Build Task Image!!



* ****

* ****

* ****

* **Approve**

* **Repository**

* **Gallery**



### Configuration

The following configuration is set by default or generated on the fly for the build system. An demo value is shown in this example for generated properties. Every configuration can be overwritten after importing the `InvokeBuildHelperTasks` in the `.build.ps1` scripts.

```powershell
# Path to the module root folder
$IBHConfig.BuildRoot = 'C:\GitHub\InvokeBuildHelper'

# Name of the module to build
$IBHConfig.ModuleName = 'InvokeBuildHelper'

# Verify Task: Option to enable or disable the verification tests
$IBHConfig.VerifyTask.Enabled = $true

# Analyze Task: Rules to process by the PowerShell Script Analyzer
$IBHConfig.AnalyzeTask.ScriptAnalyzerRules = Get-ScriptAnalyzerRule

# Approve Task: Option to enable or disable the release approval tests
$IBHConfig.ApproveTask.Enabled = $true

# Approve Task: Target branch for the release
$IBHConfig.ApproveTask.BranchName = 'master'

# Gallery Task: Option to enable or disable the release to the repository
$IBHConfig.RepositoryTask.Enabled = $true

# Repository Task: By default, the repository is a GitHub repo
$IBHConfig.RepositoryTask.Type = 'GitHub'

# Repository Task: The name of the user
$IBHConfig.RepositoryTask.User = 'claudiospizzi'

# Repository Task: The name of the repository
$IBHConfig.RepositoryTask.Name = 'InvokeBuildHelper'

# Repository Task: The secret token to access the GitHub api (if not specified, the
# Credential vault will be searched for the token)
$IBHConfig.RepositoryTask.Token = ''

# Gallery Task: Option to enable or disable the release to the gallery
$IBHConfig.GalleryTask.Enabled = $true

# Gallery Task: Name of the PowerShell Gallery user, assume it's the same as GitHub
$IBHConfig.GalleryTask.User = 'claudiospizzi'

# Gallery Task: Name of the PowerShell Gallery repository
$IBHConfig.GalleryTask.Name = 'PSGallery'

# Gallery Task: The secret token to access the PowerShell Gallery (if not specified,
# the Credential vault will be searched for the token)
$IBHConfig.GalleryTask.Token = ''
```

## Versions

Please find all versions in the [GitHub Releases] section and the release notes
in the [CHANGELOG.md] file.

## Installation

Use the following command to install the module from the [PowerShell Gallery],
if the PackageManagement and PowerShellGet modules are available:

```powershell
# Download and install the module
Install-Module -Name 'WindowsFever'
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
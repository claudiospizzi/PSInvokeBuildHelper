﻿@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'InvokeBuildHelper.psm1'

    # Version number of this module.
    ModuleVersion = '3.2.3'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = '5BE076AB-3B8E-42D5-8123-459B2439D82D'

    # Author of this module
    Author = 'Claudio Spizzi'

    # Company or vendor of this module
    # CompanyName = ''

    # Copyright statement for this module
    Copyright = 'Copyright (c) 2019 by Claudio Spizzi. Licensed under MIT license.'

    # Description of the functionality provided by this module
    Description = 'Common build tasks for the Invoke-Build PowerShell module.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(
        'InvokeBuild'
        'Pester'
        'PSScriptAnalyzer'
    )

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @(
        'InvokeBuildHelper.Xml.Types.ps1xml'
    )

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @(
        'InvokeBuildHelper.Xml.Format.ps1xml'
    )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        # Core
        'Invoke-BuildIsolated'
        'Set-ModuleVersion'
        'Find-ModuleManifest'
        # Helper
        'Get-IBHConfig'
        'Get-IBHGitAheadBy'
        'Get-IBHGitBehindBy'
        'Get-IBHGitPendingFile'
        'Get-IBHGitBranch'
        'Get-IBHGitBranchPrimary'
        'Get-IBHGitHubRepo'
        'Get-IBHGitHubUser'
        'Get-IBHModuleVersion'
        'Get-IBHModuleReleaseNote'
        'Get-IBHFileEncoding'
        'Test-IBHChangeLogVersion'
        'Test-IBHGitLocalTag'
        'Test-IBHGitRemoteTag'
        'Test-IBHSolutionVersion'
        'Invoke-IBHModuleSchemaTest'
        'Invoke-IBHPesterUnitTest'
        'Invoke-IBHPesterIntegrationTest'
        'Invoke-IBHScriptAnalyzerTest'
        'Publish-IBHGallery'
        'Publish-IBHRepository'
        'Publish-IBHZipFile'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @(
        'ib'
        'ibv'
        'InvokeBuildHelperTasks'
    )

    # DSC resources to export from this module
    DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('PSModule', 'Invoke-Build', 'Helper', 'Task')

            # A URL to the license for this module.
            LicenseUri = 'https://raw.githubusercontent.com/claudiospizzi/PSInvokeBuildHelper/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/claudiospizzi/PSInvokeBuildHelper'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/claudiospizzi/PSInvokeBuildHelper/blob/master/CHANGELOG.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}

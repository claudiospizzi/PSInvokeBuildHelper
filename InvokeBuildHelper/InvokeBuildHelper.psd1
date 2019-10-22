@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'InvokeBuildHelper.psm1'

    # Version number of this module.
    ModuleVersion = '0.1.0'

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
        'SecurityFever'
    )

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @(
        'Resources\InvokeBuildHelper.Types.ps1xml'
    )

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @(
        'Resources\InvokeBuildHelper.Formats.ps1xml'
    )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-IBHConfig'
        'Get-IBHGitAheadBy'
        'Get-IBHGitBehindBy'
        'Get-IBHGitBranch'
        'Get-IBHGitHubRepo'
        'Get-IBHGitHubUser'
        'Get-IBHModuleVersion'
        'Get-IBHModuleReleaseNote'
        'Test-IBHChangeLogVersion'
        'Test-IBHGitLocalTag'
        'Test-IBHGitRemoteTag'
        'Invoke-IBHModuleSchemaTest'
        'Invoke-IBHPesterUnitTest'
        'Invoke-IBHScriptAnalyzerTest'
        'Publish-IBHRepository'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @(
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
            LicenseUri = 'https://raw.githubusercontent.com/claudiospizzi/InvokeBuildHelper/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/claudiospizzi/InvokeBuildHelper'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/claudiospizzi/InvokeBuildHelper/blob/master/CHANGELOG.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}

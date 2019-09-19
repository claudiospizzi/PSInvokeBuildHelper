<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .
#>
function Get-BuildConfig
{
    [CmdletBinding()]
    param
    (
        # Root path of the build script
        [Parameter(Mandatory = $true)]
        [System.String]
        $BuildRoot
    )

    $config = [PSCustomObject] @{
        BuildRoot           = $BuildRoot
        ModuleName          = Get-BuildModuleName -BuildRoot $BuildRoot
        ScriptAnalyzerRules = Get-ScriptAnalyzerRule
        # ModulePath = Join-Path -Path $BuildRoot -ChildPath $moduleName
    }

    return $config

    # Write-Verbose 'Build Config:'
    # foreach ($propertyName in $result.PSObject.Properties.Name)
    # {
    #     Write-Verbose ('  {0} = {1}' -f $propertyName, $result.$propertyName)
    # }

    # Write-Output $result

    # $config = [PSCustomObject] [Ordered] @{
    #     BuildRoot     = $BuildRoot
    #     ModuleName    = 
    #     SolutionNames = [System.String[]] (Get-ChildItem -Path $BuildRoot -Directory | Where-Object { Test-Path -Path ('{0}\{1}.sln'-f $_.FullName, $_.Name) } | Select-Object -ExpandProperty 'Name')
    # }

    # $gitProviderQuery = {
    #     $gitOriginUrl = git config --get remote.origin.url
    #     if ($gitOriginUrl -match '^https:\/\/github\.com\/.*$')
    #     {
    #         return 'GitHub'
    #     }
    #     throw "Configuration property GitProvider not found!"
    # }

    # $gitAccountQuery = {
    #     $gitOriginUrl = git config --get remote.origin.url
    #     if ($gitOriginUrl -match '^https:\/\/github\.com\/(?<GitAccount>[a-zA-Z0-9-_]*)\/[a-zA-Z0-9-_]*\.git$')
    #     {
    #         return $Matches['GitAccount']
    #     }
    #     throw "Configuration property GitAccount not found!"
    # }

    # $gitRepositoryQuery = {
    #     $gitOriginUrl = git config --get remote.origin.url
    #     if ($gitOriginUrl -match '^https:\/\/github\.com\/[a-zA-Z0-9-_]*\/(?<GitRepository>[a-zA-Z0-9-_]*)\.git$')
    #     {
    #         return $Matches['GitRepository']
    #     }
    #     throw "Configuration property GitRepository not found!"
    # }

    # $result = [PSCustomObject] [Ordered] @{
    #     BuildRoot     = $BuildRoot
    #     ModuleName    = Resolve-BuildConfigProperty -Config $Config -Name 'ModuleName' -Default { Get-ChildItem -Path $BuildRoot -Directory | Where-Object { Test-Path -Path ('{0}\{1}.psd1'-f $_.FullName, $_.Name) } | Select-Object -ExpandProperty 'Name' -First 1 }
    #     SolutionNames = Resolve-BuildConfigProperty -Config $Config -Name 'SolutionName' -Default { Get-ChildItem -Path $BuildRoot -Directory | Where-Object { Test-Path -Path ('{0}\{1}.sln'-f $_.FullName, $_.Name) } | Select-Object -ExpandProperty 'Name' } -AllowNullOrEmpty
        
    #     GitEnabled    = Resolve-BuildConfigProperty -Config $Config -Name 'GitEnabled' -Default $true
    #     GitProvider   = Resolve-BuildConfigProperty -Config $Config -Name 'GitProvider' -Default $gitProviderQuery
    #     GitAccount    = Resolve-BuildConfigProperty -Config $Config -Name 'GitAccount' -Default $gitAccountQuery
    #     GitRepository = Resolve-BuildConfigProperty -Config $Config -Name 'GitRepository' -Default $gitRepositoryQuery
    #     GitToken      =
    # }


#     $ModuleNames    = 'SecurityFever'

#     $SourceNames    = 'SecurityFever'

#     $GalleryEnabled = $true
#     $GalleryKey     = Use-VaultSecureString -TargetName 'PowerShell Gallery Key (claudiospizzi)'

#     $GitHubEnabled  = $true
#     $GitHubRepoName = 'claudiospizzi/SecurityFever'
#     $GitHubToken    = Use-VaultSecureString -TargetName 'GitHub Token (claudiospizzi)'
# }


    # # Option to disbale the build script verification
    # $VerifyBuildSystem   = $true

    # # Module configuration: Location and option to enable the merge
    # $ModulePath          = Join-Path -Path $PSScriptRoot -ChildPath 'Modules'
    # $ModuleNames         = ''
    # $ModuleMerge         = $false

    # # Source configuration: Visual Studio projects to compile
    # $SourcePath          = Join-Path -Path $PSScriptRoot -ChildPath 'Sources'
    # $SourceNames         = ''
    # $SourcePublish       = ''

    # # Path were the release files are stored
    # $ReleasePath         = Join-Path -Path $PSScriptRoot -ChildPath 'bin'

    # # Configure the Pester test execution
    # $PesterPath          = Join-Path -Path $PSScriptRoot -ChildPath 'tst'
    # $PesterFile          = 'pester.xml'

    # # Configure the Script Analyzer rules
    # $ScriptAnalyzerPath  = Join-Path -Path $PSScriptRoot -ChildPath 'tst'
    # $ScriptAnalyzerFile  = 'scriptanalyzer.json'
    # $ScriptAnalyzerRules = Get-ScriptAnalyzerRule

    # # Define if the module is published to the PowerShell Gallery
    # $GalleryEnabled      = $false
    # $GalleryName         = 'PSGallery'
    # $GallerySource       = 'https://www.powershellgallery.com/api/v2/'
    # $GalleryPublish      = 'https://www.powershellgallery.com/api/v2/package/'
    # $GalleryKey          = ''

    # # Define if the module is published to the GitHub Releases section
    # $GitHubEnabled       = $false
    # $GitHubRepoName      = ''
    # $GitHubToken         = ''


}

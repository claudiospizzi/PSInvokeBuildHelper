<#
    .SYNOPSIS
        The module schema test definition.

    .DESCRIPTION
        Invoke tests based on Pester to verify if the module is valid. This
        includes the meta files for VS Code, built system, git repository but
        also module specific files.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
param
(
    # Root path of the project.
    [Parameter(Mandatory = $true)]
    [System.String]
    $BuildRoot,

    # Name of the module.
    [Parameter(Mandatory = $true)]
    [System.String]
    $ModuleName,

    # List of text file extension.
    [Parameter(Mandatory = $true)]
    [System.String[]]
    $TextFileExtension,

    # List of paths to exclude.
    [Parameter(Mandatory = $true)]
    [System.String[]]
    [AllowEmptyCollection()]
    $ExcludePath
)

Describe 'Module Schema' {

    Context 'File Structure' {

        $fileNames = @(
            @{ RelativePath = '.vscode\launch.json' }
            @{ RelativePath = '.vscode\settings.json' }
            @{ RelativePath = '.vscode\tasks.json' }
            @{ RelativePath = "$ModuleName\en-US\about_$ModuleName.help.txt" }
            @{ RelativePath = "$ModuleName\$ModuleName.psd1" }
            @{ RelativePath = "$ModuleName\$ModuleName.psm1" }
            @{ RelativePath = "$ModuleName\$ModuleName.Xml.Format.ps1xml" }
            @{ RelativePath = "$ModuleName\$ModuleName.Xml.Types.ps1xml" }
            @{ RelativePath = '.build.ps1' }
            @{ RelativePath = '.debug.ps1' }
            @{ RelativePath = '.gitignore' }
            @{ RelativePath = 'CHANGELOG.md' }
            @{ RelativePath = 'LICENSE' }
            @{ RelativePath = 'README.md' }
        )

        It 'Should have the file <RelativePath>' -TestCases $fileNames {

            param ($RelativePath)

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath $RelativePath

            # Act
            $actual = Test-Path -Path $path

            # Assert
            $actual | Should -BeTrue
        }
    }

    Context 'File Encoding & Formatting' {

        # Get all text files based on their extensions. Then filter out all
        # paths not relevant for the schema test.
        $fileNames =
            Get-ChildItem -Path $BuildRoot -File -Recurse |
                Where-Object { $TextFileExtension -contains $_.Extension } |
                    ForEach-Object { @{ Path = $_.FullName; RelativePath = $_.FullName.Replace($BuildRoot, '') } }
        $fileNames = $fileNames | Where-Object { $_.RelativePath -notlike "*\$ModuleName\Assemblies\*" }       # External assemblies, sometimes XML files
        $fileNames = $fileNames | Where-Object { $_.RelativePath -notmatch '^\\?out\\.*' }                     # Used by the InvokeBuildHelper tasks
        $fileNames = $fileNames | Where-Object { $_.RelativePath -notmatch '^\\?bin\\.*' }                     # Used by the InvokeBuildHelper tasks
        $fileNames = $fileNames | Where-Object { $_.RelativePath -notmatch '^\\?([\w.-_]*\\)?bin\\.*' }        # Used by the Visual Studio solutions
        $fileNames = $fileNames | Where-Object { $_.RelativePath -notmatch '^\\?([\w.-_]*\\)?obj\\.*' }        # Used by the Visual Studio solutions
        $fileNames = $fileNames | Where-Object { $_.RelativePath -notmatch '^\\?([\w.-_]*\\)?packages\\.*' }   # Used by the Visual Studio solutions
        $fileNames = $fileNames | Where-Object { $relativePath = $_.RelativePath; @($ExcludePath | Where-Object { $relativePath -like $_ }).Count -eq 0 }

        It 'Should use a valid encoding for file <RelativePath>' -TestCases $fileNames {

            param ($Path)

            # Arrange
            $expected = [System.Text.Encoding]::UTF8, [System.Text.Encoding]::ASCII

            # Act
            $actual = Get-IBHFileEncoding -Path $Path

            # Assert
            $actual | Should -BeIn $expected -Because 'only ASCII and UTF8 encodings are supported'
        }

        It 'Should use spaces for indentation (not tabs) for file <RelativePath>' -TestCases $fileNames {

            param ($Path)

            # Arrange
            $failedLines = @()

            # Act
            $content = Get-Content -Path $Path
            for ($i = 0; $i -lt $content.Count; $i++)
            {
                if ($content[$i] -match '^\s*\t')
                {
                    $failedLines += ($i + 1)
                }
            }

            # Assert
            $failedLines.Count | Should -Be 0 -Because "the line(s) $($failedLines -join ', ') should not contain a tab indentation"
        }

        It 'Should use no trailing spaces on lines for file <RelativePath>' -TestCases $fileNames.Where({ $_.RelativePath -notin '\README.md', '/README.md' }) {

            param ($Path)

            # Arrange
            $failedLines = @()

            # Act
            $content = Get-Content -Path $Path
            for ($i = 0; $i -lt $content.Count; $i++)
            {
                if ($content[$i] -match '\s+$')
                {
                    $failedLines += ($i + 1)
                }
            }

            # Assert
            $failedLines.Count | Should -Be 0 -Because "the line(s) $($failedLines -join ', ') should not contain trailing spaces"
        }
    }

    Context 'VS Code Configuration' {

        It 'Should have a valid .vscode\launch.json' {

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath '.vscode\launch.json'

            # Act
            $launch = Get-Content -Path $path | ConvertFrom-Json

            # Assert
            $launch.'version'                                              | Should -Be '0.2.0'
            $launch.'configurations'[0].'name'                             | Should -Be 'PowerShell Debug Script'
            $launch.'configurations'[0].'type'                             | Should -Be 'PowerShell'
            $launch.'configurations'[0].'request'                          | Should -Be 'launch'
            $launch.'configurations'[0].'script'                           | Should -Be '${workspaceFolder}\.debug.temp.ps1'
            $launch.'configurations'[0].'cwd'                              | Should -Be '${workspaceFolder}'
            $launch.'configurations'[0].'createTemporaryIntegratedConsole' | Should -BeTrue
        }

        It 'Should have a valid .vscode\settings.json' {

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath '.vscode\settings.json'

            # Act
            $settings = Get-Content -Path $path | ConvertFrom-Json

            # Assert
            $settings.'files.trimTrailingWhitespace'                               | Should -BeTrue
            $settings.'[markdown]'.'files.trimTrailingWhitespace'                  | Should -BeFalse
            $settings.'[powershell]'.'files.encoding'                              | Should -Be 'utf8bom'
            $settings.'files.exclude'.'**/.git'                                    | Should -BeTrue
            $settings.'files.exclude'.'**/.vs'                                     | Should -BeTrue
            $settings.'files.exclude'.'**/obj'                                     | Should -BeTrue
            $settings.'files.exclude'.'**/bin'                                     | Should -BeTrue
            $settings.'files.exclude'.'**/out'                                     | Should -BeTrue
            $settings.'files.exclude'.'**/packages'                                | Should -BeTrue
            $settings.'files.exclude'.'**/*.user'                                  | Should -BeTrue
            $settings.'search.exclude'.'**/.git'                                   | Should -BeTrue
            $settings.'search.exclude'.'**/.vs'                                    | Should -BeTrue
            $settings.'search.exclude'.'**/obj'                                    | Should -BeTrue
            $settings.'search.exclude'.'**/bin'                                    | Should -BeTrue
            $settings.'search.exclude'.'**/out'                                    | Should -BeTrue
            $settings.'search.exclude'.'**/packages'                               | Should -BeTrue
            $settings.'search.exclude'.'**/*.user'                                 | Should -BeTrue
            $settings.'powershell.debugging.createTemporaryIntegratedConsole'      | Should -BeTrue
            $settings.'powershell.codeFormatting.addWhitespaceAroundPipe'          | Should -BeTrue
            $settings.'powershell.codeFormatting.autoCorrectAliases'               | Should -BeFalse
            $settings.'powershell.codeFormatting.avoidSemicolonsAsLineTerminators' | Should -BeTrue
            $settings.'powershell.codeFormatting.trimWhitespaceAroundPipe'         | Should -BeFalse
            $settings.'powershell.codeFormatting.useConstantStrings'               | Should -BeFalse
            $settings.'powershell.codeFormatting.whitespaceBetweenParameters'      | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceInsideBrace'            | Should -BeTrue
            $settings.'powershell.codeFormatting.alignPropertyValuePairs'          | Should -BeTrue
            $settings.'powershell.codeFormatting.ignoreOneLineBlock'               | Should -BeTrue
            $settings.'powershell.codeFormatting.newLineAfterCloseBrace'           | Should -BeTrue
            $settings.'powershell.codeFormatting.newLineAfterOpenBrace'            | Should -BeTrue
            $settings.'powershell.codeFormatting.openBraceOnSameLine'              | Should -BeFalse
            $settings.'powershell.codeFormatting.pipelineIndentationStyle'         | Should -Be 'IncreaseIndentationAfterEveryPipeline'
            $settings.'powershell.codeFormatting.useCorrectCasing'                 | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceAfterSeparator'         | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceAroundOperator'         | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceBeforeOpenBrace'        | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceBeforeOpenParen'        | Should -BeTrue
        }

        It 'Should have a valid .vscode\tasks.json' {

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath '.vscode\tasks.json'

            # Act
            $tasks = Get-Content -Path $path | ConvertFrom-Json

            # Assert
            $tasks.version                  | Should -Be '2.0.0'
            $tasks.tasks[0].label           | Should -Be 'Test'
            $tasks.tasks[0].command         | Should -Be 'pwsh'
            $tasks.tasks[0].args[0]         | Should -Be '-NoProfile'
            $tasks.tasks[0].args[1]         | Should -Be '-Command'
            $tasks.tasks[0].args[2]         | Should -Be 'Invoke-Build -Task Test'
            $tasks.tasks[0].group.kind      | Should -Be 'test'
            $tasks.tasks[0].group.isDefault | Should -BeTrue
            $tasks.tasks[1].label           | Should -Be 'Build'
            $tasks.tasks[1].command         | Should -Be 'pwsh'
            $tasks.tasks[1].args[0]         | Should -Be '-NoProfile'
            $tasks.tasks[1].args[1]         | Should -Be '-Command'
            $tasks.tasks[1].args[2]         | Should -Be 'Invoke-Build -Task Build'
            $tasks.tasks[1].group.kind      | Should -Be 'build'
            $tasks.tasks[1].group.isDefault | Should -BeTrue
        }
    }

    Context 'Git Configuration' {

        It 'Should have a valid .gitignore' {

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath '.gitignore'

            # Act
            $gitignore = Get-Content -Path $path

            # Assert
            $gitignore | Should -Contain '**/Assemblies/*.dll'
            $gitignore | Should -Contain '[Bb]in/'
            $gitignore | Should -Contain '[Oo]bj/'
            $gitignore | Should -Contain '[Oo]ut/'
            $gitignore | Should -Contain '.vs/'
            $gitignore | Should -Contain '**/packages/*'
            $gitignore | Should -Contain '.debug.*.ps1'
        }
    }

    Context 'Module Loader' {

        It 'Should load the module without any errors' {

            # Arrange
            $path = '{0}\{1}\{1}.psd1' -f $BuildRoot, $ModuleName

            # Act & Assert
            { Import-Module -Name $path -Force -ErrorAction Stop } | Should -Not -Throw
        }
    }

    Context 'Module File README.md' {

        It 'Should not reference the old psake PowerShell build module' {

            # Act
            $actual = Get-Content -Path "$BuildRoot\README.md" -Raw

            # Assert
            $actual | Should -Not -Match ' \[psake\] '
        }
    }

    Context 'Module Definition' {

        # Get the name of all helper files
        $helperFiles =
            Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'Helpers' |
                Get-ChildItem -Include '*.ps1' -File -Recurse |
                    Sort-Object -Property 'BaseName' |
                        ForEach-Object { @{ Name = $_.BaseName } }

        # Get the name of all function files
        $functionFiles =
            Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'Functions' |
                Get-ChildItem -Include '*.ps1' -File -Recurse |
                    Sort-Object -Property 'BaseName' |
                        ForEach-Object { @{ Name = $_.BaseName } }

        # Get the list of all exported functions
        $functionExportNames =
            Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" |
                ForEach-Object { $_['FunctionsToExport'] } |
                    Sort-Object |
                        ForEach-Object { @{ Name = $_ } }

        It "Should define the FormatsToProcess to the file $ModuleName.Xml.Format.ps1xml" {

            # Act
            $actual = Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" | ForEach-Object { $_['FormatsToProcess'] }

            # Assert
            $actual | Should -Contain "$ModuleName.Xml.Format.ps1xml"
        }

        It "Should define the TypesToProcess to the file $ModuleName.Xml.Types.ps1xml" {

            # Act
            $actual = Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" | ForEach-Object { $_['TypesToProcess'] }

            # Assert
            $actual | Should -Contain "$ModuleName.Xml.Types.ps1xml"
        }

        It 'Should export function <Name>' -TestCases $functionFiles -Skip:($functionFiles.Count -eq 0) {

            param ($Name)

            # Act
            $actual = Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" | ForEach-Object { $_['FunctionsToExport'] }

            # Assert
            $actual | Should -Contain $Name
        }

        It 'Should have the script file for the function <Name>' -TestCases $functionExportNames -Skip:($functionExportNames.Count -eq 0) {

            param ($Name)

            # Act
            $actual = Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'Functions' | Get-ChildItem -Filter "$Name.ps1" -File -Recurse

            # Assert
            $actual.Count | Should -Be 1
        }

        It 'Should not export helper functions <Name>' -TestCases $helperFiles -Skip:($helperFiles.Count -eq 0) {

            param ($Name)

            # Act
            $actual = Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" | ForEach-Object { $_['FunctionsToExport'] }

            # Assert
            $actual | Should -Not -Contain $Name
        }
    }

    Context 'Module Function' {

        $scriptFiles = @()
        $scriptFiles += Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'Helpers' | Get-ChildItem -Include '*.ps1' -File -Recurse
        $scriptFiles += Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'Functions' | Get-ChildItem -Include '*.ps1' -File -Recurse

        foreach ($scriptFile in $scriptFiles)
        {
            Context $scriptFile.FullName.Replace("$BuildRoot\", 'File ') {

                #
            }
        }


        # Use AST / Parser
        # [System.Management.Automation.Language.Parser]::ParseInput($MyInvocation.MyCommand.ScriptContents, [ref]$null, [ref]$null)

        # Ensure function matches filename

        # Ensure function help:
        # - SYNOPSIS, DESCRIPTION, EXAMPLE
        # - INPUT (if defined)
        # - OUTPUT (if deinfed)
        # - NOTES (Author, Repo, License)
        # - LINK (to the repository, combine with git remote)
        # - Parameter Help
    }

    Context 'DSC Resource' {

        $scriptFiles =
            Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'DSCResources' |
                Get-ChildItem -Include '*.psm1' -File |
                    ForEach-Object { @{ Name = $_.Name; BaseName = $_.BaseName } }

        $nestedModules =
            Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" |
                ForEach-Object { $_['NestedModules'] } |
                    Where-Object { $_ -like 'DSCResources*' } |
                        ForEach-Object { @{ NestedModule = $_ } }

        $dscResourcesToExport =
            Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" |
                ForEach-Object { $_['DscResourcesToExport'] } |
                    Where-Object { -not [System.String]::IsNullOrWhiteSpace($_) } |
                        ForEach-Object { @{ DscResourcesToExport = $_ } }

        It 'Should have a NestedModules definition for the DSC resource file DSCResources\<Name>' -TestCases $scriptFiles -Skip:($scriptFiles.Count -eq 0) {

            param ($Name, $BaseName)

            # Assert
            $nestedModules.NestedModule | Should -Contain "DSCResources\$Name"
        }

        It 'Should have a DscResourcesToExport definition for the DSC resource file DSCResources\<FileName>' -TestCases $scriptFiles -Skip:($scriptFiles.Count -eq 0) {

            param ($Name, $BaseName)

            # Assert
            $dscResourcesToExport.DscResourcesToExport | Should -Contain $BaseName
        }

        It 'Should have a DSC resource file for the NestedModules definition <NestedModule>' -TestCases $nestedModules -Skip:($nestedModules.Count -eq 0) {

            param ($NestedModule)

            # Assert
            Test-Path -Path "$BuildRoot\$ModuleName\$NestedModule" | Should -BeTrue
        }

        It 'Should have a DscResourcesToExport definition for the NestedModules definition <NestedModule>' -TestCases $nestedModules -Skip:($nestedModules.Count -eq 0) {

            param ($NestedModule)

            # Arrange
            $nestedModuleName = $NestedModule.Split('\')[-1].Replace('.psm1', '')

            # Assert
            $dscResourcesToExport.DscResourcesToExport | Should -Contain $nestedModuleName
        }

        It 'Should have a DSC resource file for the DscResourcesToExport definition <DscResourcesToExport>' -TestCases $dscResourcesToExport -Skip:($dscResourcesToExport.Count -eq 0) {

            param ($DscResourcesToExport)

            # Assert
            Test-Path -Path "$BuildRoot\$ModuleName\DSCResources\$DscResourcesToExport.psm1" | Should -BeTrue
        }

        It 'Should have a NestedModules definition for the DscResourcesToExport definition <DscResourcesToExport>' -TestCases $dscResourcesToExport -Skip:($dscResourcesToExport.Count -eq 0) {

            param ($DscResourcesToExport)

            # Assert
            $nestedModules.NestedModule | Should -Contain "DSCResources\$DscResourcesToExport.psm1"
        }
    }
}

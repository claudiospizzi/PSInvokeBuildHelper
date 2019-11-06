<#
    .SYNOPSIS
        The module schema test definition.

    .DESCRIPTION
        Invoke tests based on Pester to verify if the module is valid. This
        includes the meta files for VS Code, built system, git repository but
        also module specific files.
#>
[CmdletBinding()]
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
    $TextFileExtension
)

Describe 'Module Schema' {

    Context 'File Structure' {

        $fileNames = @(
            @{ RelativePath = '.vscode\launch.json' }
            @{ RelativePath = '.vscode\settings.json' }
            @{ RelativePath = '.vscode\tasks.json' }
            @{ RelativePath = "$ModuleName\en-US\about_$ModuleName.help.txt" }
            @{ RelativePath = "$ModuleName\Resources\$ModuleName.Formats.ps1xml" }
            @{ RelativePath = "$ModuleName\Resources\$ModuleName.Types.ps1xml" }
            @{ RelativePath = "$ModuleName\$ModuleName.psd1" }
            @{ RelativePath = "$ModuleName\$ModuleName.psm1" }
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

        $fileNames = Get-ChildItem -Path $BuildRoot -File -Recurse |
                         Where-Object { $TextFileExtension -contains $_.Extension -and
                                        $_.FullName -notlike "$BuildRoot*\out\*" -and
                                        $_.FullName -notlike "$BuildRoot*\bin\*" -and
                                        $_.FullName -notlike "$BuildRoot*\obj\*" -and
                                        $_.FullName -notlike "$BuildRoot\*\packages\*" } |
                             ForEach-Object { @{ Path = $_.FullName; RelativePath = $_.FullName.Replace($BuildRoot, '') } }

        It 'Should not use UTF-16 LE encoding for file <RelativePath>' -TestCases $fileNames {

            param ($Path)

            # Act
            $zeroByteCount = @([System.IO.File]::ReadAllBytes($Path) -eq 0).Length

            # Assert
            $zeroByteCount | Should -Be 0 -Because 'the text file should not contain 0x00 bytes'
        }

        It 'Should not use BOM for UTF-8 encoding for file <RelativePath>' -TestCases $fileNames {

            param ($Path)

            # Act
            $bytes = [System.IO.File]::ReadAllBytes($Path)
            $isBOM = $bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191

            # Assert
            $isBOM | Should -BeFalse -Because 'the text file should not contain the UTF-8 BOM header'
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

        It 'Should use no trailing spaces on lines for file <RelativePath>' -TestCases $fileNames.Where({ $_.RelativePath -ne '\README.md' }) {

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
            $launch.'configurations'[0].'name'                             | Should -Be 'PowerShell Interactive'
            $launch.'configurations'[0].'type'                             | Should -Be 'PowerShell'
            $launch.'configurations'[0].'request'                          | Should -Be 'launch'
            $launch.'configurations'[0].'cwd'                              | Should -Be '${workspaceFolder}'
            $launch.'configurations'[0].'createTemporaryIntegratedConsole' | Should -BeTrue
            $launch.'configurations'[1].'name'                             | Should -Be 'PowerShell Debug Script'
            $launch.'configurations'[1].'type'                             | Should -Be 'PowerShell'
            $launch.'configurations'[1].'request'                          | Should -Be 'launch'
            $launch.'configurations'[1].'script'                           | Should -Be '${workspaceFolder}\.debug.ps1'
            $launch.'configurations'[1].'cwd'                              | Should -Be '${workspaceFolder}'
            $launch.'configurations'[1].'createTemporaryIntegratedConsole' | Should -BeTrue

        }

        It 'Should have a valid .vscode\settings.json' {

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath '.vscode\settings.json'

            # Act
            $settings = Get-Content -Path $path | ConvertFrom-Json

            # Assert
            $settings.'files.trimTrailingWhitespace'                          | Should -BeTrue
            $settings.'[markdown]'.'files.trimTrailingWhitespace'             | Should -BeFals
            $settings.'files.exclude'.'**/.git'                               | Should -BeTrue
            $settings.'files.exclude'.'**/.vs'                                | Should -BeTrue
            $settings.'files.exclude'.'**/obj'                                | Should -BeTrue
            $settings.'files.exclude'.'**/bin'                                | Should -BeTrue
            $settings.'files.exclude'.'**/out'                                | Should -BeTrue
            $settings.'files.exclude'.'**/packages'                           | Should -BeTrue
            $settings.'files.exclude'.'**/*.user'                             | Should -BeTrue
            $settings.'search.exclude'.'**/.git'                              | Should -BeTrue
            $settings.'search.exclude'.'**/.vs'                               | Should -BeTrue
            $settings.'search.exclude'.'**/obj'                               | Should -BeTrue
            $settings.'search.exclude'.'**/bin'                               | Should -BeTrue
            $settings.'search.exclude'.'**/out'                               | Should -BeTrue
            $settings.'search.exclude'.'**/packages'                          | Should -BeTrue
            $settings.'search.exclude'.'**/*.user'                            | Should -BeTrue
            $settings.'powershell.debugging.createTemporaryIntegratedConsole' | Should -BeTrue
            $settings.'powershell.codeFormatting.alignPropertyValuePairs'     | Should -BeTrue
            $settings.'powershell.codeFormatting.ignoreOneLineBlock'          | Should -BeTrue
            $settings.'powershell.codeFormatting.newLineAfterCloseBrace'      | Should -BeTrue
            $settings.'powershell.codeFormatting.newLineAfterOpenBrace'       | Should -BeTrue
            $settings.'powershell.codeFormatting.openBraceOnSameLine'         | Should -BeFalse
            $settings.'powershell.codeFormatting.pipelineIndentationStyle'    | Should -Be 'IncreaseIndentationAfterEveryPipeline'
            $settings.'powershell.codeFormatting.useCorrectCasing'            | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceAfterSeparator'    | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceAroundOperator'    | Should -BeTrue
            $settings.'powershell.codeFormatting.WhitespaceAroundPipe'        | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceBeforeOpenBrace'   | Should -BeTrue
            $settings.'powershell.codeFormatting.whitespaceBeforeOpenParen'   | Should -BeTrue
            $settings.'powershell.codeFormatting.WhitespaceInsideBrace'       | Should -BeTrue
        }

        It 'Should have a valid .vscode\tasks.json' {

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath '.vscode\tasks.json'

            # Act
            $tasks = Get-Content -Path $path | ConvertFrom-Json

            # Assert
            $tasks.version                  | Should -Be '2.0.0'
            $tasks.command                  | Should -Be '"& { Invoke-Build -Task $args }"'
            $tasks.type                     | Should -Be 'shell'
            $tasks.options.shell.executable | Should -Be 'powershell.exe'
            $tasks.options.shell.args[0]    | Should -Be '-NoProfile'
            $tasks.options.shell.args[1]    | Should -Be '-Command'
            $tasks.presentation.echo        | Should -BeFalse
            $tasks.presentation.reveal      | Should -Be 'always'
            $tasks.presentation.focus       | Should -BeFalse
            $tasks.presentation.panel       | Should -Be 'new'
            $tasks.tasks[0].label           | Should -Be 'Test'
            $tasks.tasks[0].group.kind      | Should -Be 'test'
            $tasks.tasks[0].group.isDefault | Should -BeTrue
            $tasks.tasks[1].label           | Should -Be 'Build'
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

    Context 'Module Definition' {

        # Get the name of all helper files
        $helperFiles = Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'Helpers' |
                           Get-ChildItem -Include '*.ps1' -File -Recurse |
                               Sort-Object -Property 'BaseName' |
                                   ForEach-Object { @{ Name = $_.BaseName } }

        # Get the name of all function files
        $functionFiles = Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'Functions' |
                             Get-ChildItem -Include '*.ps1' -File -Recurse |
                                 Sort-Object -Property 'BaseName' |
                                     ForEach-Object { @{ Name = $_.BaseName } }

        # Get the list of all exported functions
        $functionExportNames = Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" |
                                   ForEach-Object { $_['FunctionsToExport'] } |
                                       Sort-Object |
                                           ForEach-Object { @{ Name = $_ } }

        It 'Should not export helper functions <Name>' -TestCases $helperFiles -Skip:($helperFiles.Count -eq 0) {

            param ($Name)

            # Act
            $actual = Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" |
                          ForEach-Object { $_['FunctionsToExport'] }

            # Assert
            $actual | Should -Not -Contain $Name
        }

        It 'Should export function <Name>' -TestCases $functionFiles -Skip:($functionFiles.Count -eq 0) {

            param ($Name)

            # Act
            $actual = Import-PowerShellDataFile -Path "$BuildRoot\$ModuleName\$ModuleName.psd1" |
                          ForEach-Object { $_['FunctionsToExport'] }

            # Assert
            $actual | Should -Contain $Name
        }

        It 'Should have the script file for the function <Name>' -TestCases $functionExportNames -Skip:($functionExportNames.Count -eq 0) {

            param ($Name)

            # Act
            $actual = Get-ChildItem -Path "$BuildRoot\$ModuleName" -Filter 'Functions' |
                          Get-ChildItem -Filter "$Name.ps1" -File -Recurse

            # Assert
            $actual.Count | Should -Be 1
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

}

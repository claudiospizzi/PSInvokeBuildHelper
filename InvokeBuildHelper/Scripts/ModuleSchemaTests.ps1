<#
    .SYNOPSIS
        The module schema test definition.

    .DESCRIPTION
        Invoke tests based on Pester to verify if the module is valid. This
        includes the meta files for VS Code, built system, git repo but also
        module specific files.
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
    $ModuleName
)

Describe 'Module Schema' {

    Context 'Files' {

        $fileTestCases = @(
            @{ RelativePath = '.vscode\launch.json' }
            @{ RelativePath = '.vscode\settings.json' }
            @{ RelativePath = '.vscode\tasks.json' }
            @{ RelativePath = "$ModuleName\en-US\about_$ModuleName.help.txt" }
            @{ RelativePath = "$ModuleName\Resources\$ModuleName.Formats.ps1xml" }
            @{ RelativePath = "$ModuleName\Resources\$ModuleName.Types.ps1xml" }
            @{ RelativePath = "$ModuleName\$ModuleName.psd1" }
            @{ RelativePath = "$ModuleName\$ModuleName.psm1" }
            @{ RelativePath = '.build.ps1' }
            @{ RelativePath = '.gitignore' }
            @{ RelativePath = 'CHANGELOG.md' }
            @{ RelativePath = 'LICENSE' }
            @{ RelativePath = 'README.md' }
        )

        It 'Should have the file <RelativePath>' -TestCases $fileTestCases {

            param ($RelativePath)

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath $RelativePath

            # Act
            $actual = Test-Path -Path $path

            # Assert
            $actual | Should -BeTrue
        }
    }

    Context 'VS Code' {

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
            $settings.'[markdown]'.'files.trimTrailingWhitespace'             | Should -BeFalse
            $settings.'files.exclude'.'**/.git'                               | Should -BeTrue
            $settings.'files.exclude'.'out'                                   | Should -BeTrue
            $settings.'search.exclude'.'out'                                  | Should -BeTrue
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

    Context 'Git' {

        It 'Should have a valid .gitignore' {

            # Arrange
            $path = Join-Path -Path $BuildRoot -ChildPath '.gitignore'

            # Act
            $gitignore = Get-Content -Path $path

            # Assert
            $gitignore | Should -Contain '/out/'
        }
    }
}

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [System.String]
    $Path,

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
            $path = Join-Path -Path $Path -ChildPath $RelativePath

            # Act
            $actual = Test-Path -Path $path

            # Assert
            $actual | Should -BeTrue
        }
    }
}

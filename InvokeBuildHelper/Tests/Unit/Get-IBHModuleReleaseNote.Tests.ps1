
BeforeAll {

    Find-ModuleManifest -Path $PSScriptRoot | Import-Module -Force
}

Describe 'Get-IBHModuleReleaseNote' {

    It 'Should throw an error if the version does not exist' {

        # Arrange
        $path    = "$PSScriptRoot\..\..\.."
        $version      = '999.0.0'
        $errorMessage = 'Release notes not found in CHANGELOG.md for version {0}' -f $version

        # Act & Assert
        { Get-IBHModuleReleaseNote -BuildRoot $path -ModuleVersion $version } | Should -Throw $errorMessage
    }

    It 'Should return the valid release notes if the version exists' {

        # Arrange
        $path    = "$PSScriptRoot\..\..\.."
        $version = '1.0.0'

        # Act
        $releaseNote = Get-IBHModuleReleaseNote -BuildRoot $path -ModuleVersion $version

        # Assert
        $releaseNote | Should -Be @('Release Notes:', '* Added: Initial version')
    }
}

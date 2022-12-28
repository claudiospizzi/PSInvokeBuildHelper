
BeforeAll {

    Find-ModuleManifest -Path $PSScriptRoot | Import-Module -Force
}

Describe 'Get-IBHModuleReleaseNote' {

    Context 'Unreleased' {

        BeforeAll {
            Find-ModuleManifest -Path $PSScriptRoot | Import-Module -Force

            Mock 'Get-Content' -ModuleName 'InvokeBuildHelper' -ParameterFilter { $Path -eq 'C:\GitHub\InvokeBuildHelper\CHANGELOG.md' } {

                '# Changelog'
                ''
                'All notable changes to this project will be documented in this file.'
                ''
                'The format is mainly based on [Keep a Changelog](http://keepachangelog.com/)'
                'and this project adheres to [Semantic Versioning](http://semver.org/).'
                ''
                '## Unreleased'
                ''
                '* Added: Initial version'
            }
        }

        It 'Should throw an error if the version does not exist' {

            # Arrange
            $path         = 'C:\GitHub\InvokeBuildHelper'
            $version      = '1.0.0'
            $errorMessage = 'Release notes not found in CHANGELOG.md for version {0}' -f $version

            # Act & Assert
            { Get-IBHModuleReleaseNote -BuildRoot $path -ModuleVersion $version } | Should -Throw $errorMessage
        }
    }

    Context 'First Release' {

        BeforeAll {

            Mock 'Get-Content' -ModuleName $moduleName -ParameterFilter { $Path -eq 'C:\GitHub\InvokeBuildHelper\CHANGELOG.md' } {

                '# Changelog'
                ''
                'All notable changes to this project will be documented in this file.'
                ''
                'The format is mainly based on [Keep a Changelog](http://keepachangelog.com/)'
                'and this project adheres to [Semantic Versioning](http://semver.org/).'
                ''
                '## 1.0.0 - 2019-10-19'
                ''
                '* Added: Initial version'
            }
        }

        It 'Should throw an error if the version does not exist' {

            # Arrange
            $path         = 'C:\GitHub\InvokeBuildHelper'
            $version      = '2.0.0'
            $errorMessage = 'Release notes not found in CHANGELOG.md for version {0}' -f $version

            # Act & Assert
            { Get-IBHModuleReleaseNote -BuildRoot $path -ModuleVersion $version } | Should -Throw $errorMessage
        }

        It 'Should return the valid release notes if the version exists' {

            # Arrange
            $path    = 'C:\GitHub\InvokeBuildHelper'
            $version = '1.0.0'

            # Act
            $releaseNote = Get-IBHModuleReleaseNote -BuildRoot $path -ModuleVersion $version

            # Assert
            $releaseNote | Should -Be @('Release Notes:', '* Added: Initial version')
        }
    }

    Context 'Multiple Releases' {

        BeforeAll {

            Mock 'Get-Content' -ModuleName $moduleName -ParameterFilter { $Path -eq 'C:\GitHub\InvokeBuildHelper\CHANGELOG.md' } {

                '# Changelog'
                ''
                'All notable changes to this project will be documented in this file.'
                ''
                'The format is mainly based on [Keep a Changelog](http://keepachangelog.com/)'
                'and this project adheres to [Semantic Versioning](http://semver.org/).'
                ''
                '## Unreleased'
                ''
                '* Fixed: Funny bug'
                ''
                '## 2.0.0 - 2019-10-19'
                ''
                '* Changed: Incredible new feature'
                '* Removed: Boring old feature'
                ''
                '## 1.0.0 - 2019-01-02'
                ''
                '* Added: Initial version'
            }
        }

        It 'Should throw an error if the version does not exist' {

            # Arrange
            $path         = 'C:\GitHub\InvokeBuildHelper'
            $version      = '3.0.0'
            $errorMessage = 'Release notes not found in CHANGELOG.md for version {0}' -f $version

            # Act & Assert
            { Get-IBHModuleReleaseNote -BuildRoot $path -ModuleVersion $version } | Should -Throw $errorMessage
        }

        It 'Should return the valid release notes if the version exists' {

            # Arrange
            $path    = 'C:\GitHub\InvokeBuildHelper'
            $version = '2.0.0'

            # Act
            $releaseNote = Get-IBHModuleReleaseNote -BuildRoot $path -ModuleVersion $version

            # Assert
            $releaseNote | Should -Be @('Release Notes:', '* Changed: Incredible new feature', '* Removed: Boring old feature')
        }
    }
}

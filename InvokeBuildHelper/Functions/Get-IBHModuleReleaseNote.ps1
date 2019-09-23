# function Get-IBHModuleReleaseNote
# {
#     $changelogFile = Join-Path -Path $PSScriptRoot -ChildPath 'CHANGELOG.md'

#     $releaseNotes = @('Release Notes:')

#     $isCurrentVersion = $false

#     foreach ($line in (Get-Content -Path $changelogFile))
#     {
#         if ($line -like "## $Version - ????-??-??")
#         {
#             $isCurrentVersion = $true
#         }
#         elseif ($line -like '## *')
#         {
#             $isCurrentVersion = $false
#         }

#         if ($isCurrentVersion -and ($line.StartsWith('* ') -or $line.StartsWith('- ')))
#         {
#             $releaseNotes += $line
#         }
#     }

#     Write-Output $releaseNotes
# }

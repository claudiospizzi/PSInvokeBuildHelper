<#
    .SYNOPSIS
        The script analyzer test definition.

    .DESCRIPTION
        Invoke the Script Analyzer tests and show the result as Pester output.
        For every issue a failed test will be shown. If a rule passes for all
        files, one passing test will be shown.
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

    # Script analyzer rules to test.
    [Parameter(Mandatory = $true)]
    [System.Object[]]
    $Rule
)

# Invoke the script analyzer
$issues = Invoke-ScriptAnalyzer -Path "$BuildRoot\$ModuleName" -IncludeRule $Rule -Recurse

Describe 'Script Analyzer' {

    foreach ($currentRule in $rule)
    {
        Context "$($currentRule.RuleName) ($($currentRule.Severity))" {

            $currentIssues = $issues.Where({ $_.RuleName -eq $currentRule.RuleName })

            if ($currentIssues.Count -eq 0)
            {
                It 'Should pass the rule for all files' {

                    $currentIssues.Count | Should -Be 0
                }
            }
            else
            {
                foreach ($currentIssue in $currentIssues)
                {
                    It ('Should pass the rule for \{0}:{1},{2}' -f $currentIssue.ScriptPath.Replace($BuildRoot, '').TrimStart('\'), $currentIssue.Line, $currentIssue.Column) {

                        throw $currentIssue.Message
                    }
                }
            }
        }
    }
}

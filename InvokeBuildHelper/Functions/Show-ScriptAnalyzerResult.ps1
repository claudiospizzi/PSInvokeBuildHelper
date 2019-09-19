<#
    .SYNOPSIS
        Convert the script analyzer issues to pester formatted like output.

    .DESCRIPTION
        .
#>
function Show-ScriptAnalyzerResult
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Issue,

        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Rule
    )

    $colorMap = @{
        'Information' = 'Blue'
        'Warning'     = 'Yellow'
        'Error'       = 'Red'
    }

    Write-Host ("`nDescribing {0}" -f $Path) -ForegroundColor Green

    foreach ($currentRule in $Rule)
    {
        Write-Host ("`n  Context {0} ({1})" -f $currentRule.RuleName, $currentRule.Severity) -ForegroundColor Green

        $currentIssues = $Issue.Where({$_.RuleName -eq $currentRule.RuleName})

        if ($currentIssues.Count -eq 0)
        {
            Write-Host "    [+] Should pass the rule for all files" -ForegroundColor DarkGreen
        }
        else
        {
            foreach ($currentIssue in $currentIssues)
            {
                Write-Host ("    [-] Should pass the rule for {0}:{1},{2}`n      {3}" -f $currentIssue.ScriptPath.Replace($Path, '').TrimStart('\'), $currentIssue.Line, $currentIssue.Column, $currentIssue.Message) -ForegroundColor ($colorMap[$currentRule.Severity.ToString()])
            }
        }

        Start-Sleep -Milliseconds 15
    }
}

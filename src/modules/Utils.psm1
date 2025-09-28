# Utility functions for XML diff analysis
# Provides logging, formatting, and helper functions

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Info' { Write-Verbose $logMessage -Verbose }
        'Warning' { Write-Warning $logMessage }
        'Error' { Write-Error $logMessage }
    }
}

function Format-XmlString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$XmlString
    )

    try {
        $xmlDoc = [xml]$XmlString
        $stringWriter = New-Object System.IO.StringWriter
        $xmlWriter = New-Object System.Xml.XmlTextWriter($stringWriter)
        $xmlWriter.Formatting = [System.Xml.Formatting]::Indented
        $xmlDoc.WriteContentTo($xmlWriter)
        return $stringWriter.ToString()
    }
    catch {
        Write-Error "Failed to format XML: $_"
        return $XmlString
    }
}

function Convert-DiffToHtml {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$DiffResult,

        [Parameter(Mandatory = $true)]
        [string]$RequestXml,

        [Parameter(Mandatory = $true)]
        [string]$PocResponse,

        [Parameter(Mandatory = $true)]
        [string]$NonPocResponse
    )

    $css = @"
<style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .header { background-color: #f5f5f5; padding: 10px; margin-bottom: 20px; }
    .section { margin-bottom: 20px; }
    .diff-item { border-left: 4px solid #ddd; padding: 10px; margin: 10px 0; }
    .diff-type-Different { border-left-color: #ffd700; }
    .diff-type-Missing { border-left-color: #ff4444; }
    .diff-type-Additional { border-left-color: #4CAF50; }
    .xml-content { background-color: #f8f8f8; padding: 10px; white-space: pre; font-family: monospace; }
    .metadata { color: #666; font-size: 0.9em; }
    .no-diff { color: #4CAF50; }
</style>
"@

    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>XML Diff Analysis Report</title>
    $css
</head>
<body>
    <div class="header">
        <h1>XML Diff Analysis Report</h1>
        <div class="metadata">
            Generated: $($DiffResult.Metadata.Timestamp)<br>
            Service-PoC: http://localhost:7072/quotes/api/poc<br>
            Service-NonPoC: http://localhost:7072/quotes/api/non-poc
        </div>
    </div>

    <div class="section">
        <h2>Request XML</h2>
        <div class="xml-content">$(Format-XmlString $RequestXml)</div>
    </div>

    <div class="section">
        <h2>Differences Found: $($DiffResult.Differences.Count)</h2>
"@

    if ($DiffResult.Differences.Count -eq 0) {
        $html += @"
        <div class="no-diff">No differences found between the responses.</div>
"@
    }
    else {
        foreach ($diff in $DiffResult.Differences) {
            $html += @"
        <div class="diff-item diff-type-$($diff.Type)">
            <strong>Type:</strong> $($diff.Type)<br>
            <strong>Path:</strong> $($diff.Path)<br>
"@
            if ($null -ne $diff.ReferenceValue) {
                $html += "<strong>PoC Value:</strong> $([System.Web.HttpUtility]::HtmlEncode($diff.ReferenceValue))<br>"
            }
            if ($null -ne $diff.DifferenceValue) {
                $html += "<strong>NonPoC Value:</strong> $([System.Web.HttpUtility]::HtmlEncode($diff.DifferenceValue))<br>"
            }
            $html += "</div>`n"
        }
    }

    $html += @"
    </div>

    <div class="section">
        <h2>Service-PoC Response</h2>
        <div class="xml-content">$(Format-XmlString $PocResponse)</div>
    </div>

    <div class="section">
        <h2>Service-NonPoC Response</h2>
        <div class="xml-content">$(Format-XmlString $NonPocResponse)</div>
    </div>
</body>
</html>
"@

    return $html
}

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Level - $Message"
    
    switch ($Level) {
        'Info' { Write-Host $logMessage }
        'Warning' { Write-Warning $logMessage }
        'Error' { Write-Error $logMessage }
    }
}

Export-ModuleMember -Function Format-XmlString, Convert-DiffToHtml, Write-Log
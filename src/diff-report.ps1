#!/usr/bin/env pwsh
#Requires -Version 7.5
<#
.SYNOPSIS
    Performs XML diff analysis between responses from two insurance quote web services.

.DESCRIPTION
    This script sends an XML request to two insurance quote web services (Service-PoC and Service-NonPoC),
    receives their responses, and performs a detailed diff analysis. The differences are presented in a
    human-readable HTML report, with special attention to preserving decimal/monetary values exactly.

.PARAMETER RequestXmlPath
    Path to the XML file containing the insurance quote request.

.PARAMETER OutputPath
    Optional. Path where the HTML diff report should be saved. If not specified, outputs to the console.

.PARAMETER OrderSignificant
    Optional. Switch to indicate whether the order of XML elements is significant for comparison.

.EXAMPLE
    .\diff-report.ps1 -RequestXmlPath .\request.xml
    Sends the request and outputs the diff report to the console.

.EXAMPLE
    .\diff-report.ps1 -RequestXmlPath .\request.xml -OutputPath .\diff-report.html
    Sends the request and saves the diff report to diff-report.html.
#>

#Requires -Modules @{ ModuleName='Logging'; ModuleVersion='1.0.0' }

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$RequestXmlPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [switch]$OrderSignificant
)

# Import required modules
$moduleRoot = Join-Path $PSScriptRoot "modules"
Import-Module (Join-Path $moduleRoot "XmlDiff.psm1") -Force
Import-Module (Join-Path $moduleRoot "Utils.psm1") -Force
Import-Module (Join-Path $moduleRoot "DiffReport.psm1") -Force

# Execute the diff report
try {
    Invoke-DiffReport -RequestXmlPath $RequestXmlPath -OutputPath $OutputPath -OrderSignificant:$OrderSignificant
}
catch {
    Write-Log $_.Exception.Message -Level Error
    throw
}

try {
    # Resolve the request XML path
    $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($RequestXmlPath)
    
    # Read and validate request XML
    if (-not (Test-Path $resolvedPath)) {
        throw "Request XML file not found: $RequestXmlPath"
    }

    $requestXml = Get-Content $resolvedPath -Raw
    try {
        [xml]$null = $requestXml # Validate XML syntax
    }
    catch {
        throw New-Object System.Exception "Invalid request XML", $_.Exception
    }

    # Call both services
    $pocResponse = Invoke-ServiceCall -Endpoint $pocEndpoint -RequestXml $requestXml
    $nonPocResponse = Invoke-ServiceCall -Endpoint $nonPocEndpoint -RequestXml $requestXml

    # Perform diff analysis
    Write-Log "Performing diff analysis"
    $diffResult = Compare-XmlContent -ReferenceXml $pocResponse -DifferenceXml $nonPocResponse -OrderSignificant:$OrderSignificant

    # Generate HTML report
    Write-Log "Generating diff report"
    $htmlReport = Convert-DiffToHtml -DiffResult $diffResult -RequestXml $requestXml -PocResponse $pocResponse -NonPocResponse $nonPocResponse

    # Output report
    if ($OutputPath) {
        $htmlReport | Set-Content -Path $OutputPath -Encoding UTF8
        Write-Log "Report saved to: $OutputPath"
    }
    else {
        return $htmlReport
    }
}
catch {
    Write-Log $_.Exception.Message -Level Error
    throw
}
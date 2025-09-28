#!/usr/bin/env pwsh
#Requires -Version 7.5
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

param (
    [Parameter()]
    [switch]$CI = $false
)

# Configure Pester
$config = New-PesterConfiguration
$config.Run.Path = Join-Path $PSScriptRoot "tests"
$config.Output.Verbosity = if ($CI) { "Detailed" } else { "Normal" }
$config.TestResult.Enabled = $false
$config.TestResult.OutputPath = "test-results.xml"
$config.TestResult.OutputFormat = "NUnitXml"
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = Join-Path $PSScriptRoot "src/modules/*.psm1"
$config.CodeCoverage.OutputPath = "coverage.xml"

# Start mock service if not already running
$mockService = Join-Path $PSScriptRoot "src/mock-service.ps1"
$mockServiceProcess = Start-Process pwsh -ArgumentList "-NoProfile -NonInteractive -File `"$mockService`"" -PassThru

try {
    # Give the mock service a moment to start
    Start-Sleep -Seconds 2

    # Run the tests
    $result = Invoke-Pester -Configuration $config

    # Report results
    if ($result.FailedCount -gt 0) {
        Write-Host "Tests failed! See above for detailed error messages." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "All tests passed!" -ForegroundColor Green
        exit 0
    }
}
finally {
    # Clean up mock service
    if ($mockServiceProcess) {
        Stop-Process -Id $mockServiceProcess.Id -Force -ErrorAction SilentlyContinue
    }
}
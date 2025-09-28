#!/usr/bin/env pwsh
#Requires -Version 7.5

# Import helper modules
$moduleRoot = Join-Path $PSScriptRoot "modules"
Import-Module (Join-Path $moduleRoot "Utils.psm1") -Force

# Define endpoints
$prefix = "http://localhost:7072/quotes/api"
$endpoints = @{
    "poc" = "$prefix/poc"
    "non-poc" = "$prefix/non-poc"
}

# Mock response templates
$pocResponseTemplate = Get-Content (Join-Path $PSScriptRoot ".." "examples" "service-poc-response.xml") -Raw
$nonPocResponseTemplate = Get-Content (Join-Path $PSScriptRoot ".." "examples" "service-non-poc-response.xml") -Raw

# Start the HTTP listener
$listener = New-Object System.Net.HttpListener
$endpoints.Values | ForEach-Object { $listener.Prefixes.Add("$_/") }
$listener.Start()

Write-Host "Mock service started at $prefix"
Write-Host "Press Ctrl+C to stop the server"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # Log the request
        Write-Log "Received request: $($request.Url.LocalPath)"

        # Handle the request based on the endpoint
        $responseXml = switch -Wildcard ($request.Url.LocalPath) {
            "*/poc*" { $pocResponseTemplate }
            "*/non-poc*" { $nonPocResponseTemplate }
            default {
                $response.StatusCode = 404
                "<?xml version='1.0'?><error>Endpoint not found</error>"
            }
        }

        # Set response headers
        $response.ContentType = "application/xml"
        $response.ContentEncoding = [System.Text.Encoding]::UTF8

        # Write the response
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseXml)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()

        Write-Log "Response sent for: $($request.Url.LocalPath)"
    }
}
finally {
    # Cleanup
    $listener.Stop()
    $listener.Close()
}
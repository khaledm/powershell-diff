# DiffReport module for XML comparison and reporting
# Contains the core functionality for the diff-report tool

function Invoke-DiffReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RequestXmlPath,

        [Parameter(Mandatory = $false)]
        [string]$OutputPath,

        [Parameter(Mandatory = $false)]
        [switch]$OrderSignificant
    )

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
    $pocResponse = Invoke-ServiceCall -Endpoint $script:pocEndpoint -RequestXml $requestXml
    $nonPocResponse = Invoke-ServiceCall -Endpoint $script:nonPocEndpoint -RequestXml $requestXml

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

function Invoke-ServiceCall {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,
        
        [Parameter(Mandatory = $true)]
        [string]$RequestXml
    )

    try {
        Write-Log "Sending request to $Endpoint"
        
        # Make the service call
        $response = Invoke-RestMethod -Uri $Endpoint -Method Post -Body $RequestXml -ContentType 'application/xml'
        
        if ($null -eq $response) {
            throw "Service returned null response"
        }

        if ($null -eq $response.OuterXml) {
            throw "Service response is missing XML content"
        }

        Write-Log "Received response from $Endpoint"
        return $response.OuterXml
    }
    catch {
        $errorMsg = "Service call failed: $($_.Exception.Message)"
        Write-Log $errorMsg -Level Error
        throw New-Object System.Exception "Service $Endpoint is unavailable or returned an error", $_.Exception
    }
}

# Module initialization
$script:pocEndpoint = "http://localhost:7072/quotes/api/poc"
$script:nonPocEndpoint = "http://localhost:7072/quotes/api/non-poc"

# Export functions
Export-ModuleMember -Function Invoke-DiffReport
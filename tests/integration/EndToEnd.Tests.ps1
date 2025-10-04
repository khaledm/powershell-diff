BeforeAll {
    $script:scriptPath = "$PSScriptRoot\..\..\src\diff-report.ps1"
    $script:sampleRequestPath = "$PSScriptRoot\test-data\sample-request.xml"
}

BeforeAll {
    # Create test data directory and sample request file
    New-Item -Path "$PSScriptRoot\test-data" -ItemType Directory -Force
    @'
<?xml version="1.0" encoding="UTF-8"?>
<QuoteRequest>
    <Customer>
        <Name>John Doe</Name>
        <Age>30</Age>
    </Customer>
    <Coverage>
        <Type>Full</Type>
        <Amount>50000.00</Amount>
    </Coverage>
</QuoteRequest>
'@ | Set-Content -Path $sampleRequestPath
}

Describe 'End-to-End Diff Scenario Tests' {
    It 'Should generate HTML diff report for successful responses' {
        $result = & $scriptPath -RequestXmlPath $sampleRequestPath
        $result | Should -Not -BeNullOrEmpty
        $result | Should -FileContentMatch '<html'
        $result | Should -FileContentMatch '</html>'
        $result | Should -FileContentMatch 'Diff Analysis Report'
    }

    It 'Should include metadata in the report' {
        $result = & $scriptPath -RequestXmlPath $sampleRequestPath
        $result | Should -FileContentMatch 'Generated:'
        $result | Should -FileContentMatch 'Service-PoC:'
        $result | Should -FileContentMatch 'Service-NonPoC:'
    }
}

Describe 'Error Scenario Tests' {
    It 'Should handle service unavailability gracefully' {
        Mock Invoke-RestMethod { throw 'Connection refused' }
        $result = & $scriptPath -RequestXmlPath $sampleRequestPath -ErrorAction SilentlyContinue
        $Error[0].Exception.Message | Should -Match 'service.*unavailable'
    }

    It 'Should handle invalid XML response' {
        Mock Invoke-RestMethod { return '<Invalid>XML' }
        $result = & $scriptPath -RequestXmlPath $sampleRequestPath -ErrorAction SilentlyContinue
        $Error[0].Exception.Message | Should -Match 'invalid XML'
    }

    It 'Should handle identical responses' {
        $mockResponse = @'
<?xml version="1.0" encoding="UTF-8"?>
<QuoteResponse>
    <Premium>1234.56</Premium>
    <Coverage>Full</Coverage>
</QuoteResponse>
'@
        Mock Invoke-RestMethod { return [xml]$mockResponse }
        $result = & $scriptPath -RequestXmlPath $sampleRequestPath
        $result | Should -FileContentMatch 'No differences found'
    }

    It 'Should handle large XML documents' {
        $largeXml = '<?xml version="1.0" encoding="UTF-8"?><Root>' + 
                    ('<Item><Value>Test</Value></Item>' * 1000) + 
                    '</Root>'
        $largePath = "$PSScriptRoot\test-data\large-request.xml"
        $largeXml | Set-Content -Path $largePath
        
        $result = & $scriptPath -RequestXmlPath $largePath
        $result | Should -Not -BeNullOrEmpty
        Remove-Item -Path $largePath
    }
}

AfterAll {
    Remove-Item -Path "$PSScriptRoot\test-data" -Recurse -Force
}
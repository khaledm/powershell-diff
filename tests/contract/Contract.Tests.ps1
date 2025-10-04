BeforeAll {
    $script:pocEndpoint = 'http://localhost:7072/quotes/api/poc'
    $script:nonPocEndpoint = 'http://localhost:7072/quotes/api/non-poc'
    $script:sampleRequest = @'
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
'@
}

Describe 'Service-PoC Contract Tests' {
    It 'Should accept valid XML and return valid response' {
        $response = Invoke-RestMethod -Uri $pocEndpoint -Method Post -Body $sampleRequest -ContentType 'application/xml'
        $response | Should -Not -BeNullOrEmpty
        $response.QuoteResponse | Should -Not -BeNullOrEmpty
        $response.QuoteResponse.Premium | Should -Not -BeNullOrEmpty
        $response.QuoteResponse.Premium | Should -BeOfType [Decimal]
    }

    It 'Should preserve decimal values exactly' {
        $response = Invoke-RestMethod -Uri $pocEndpoint -Method Post -Body $sampleRequest -ContentType 'application/xml'
        $premium = [decimal]$response.QuoteResponse.Premium
        $premium.ToString('G29') | Should -Match '^\d+\.\d{2}$'
    }

    It 'Should handle invalid XML gracefully' {
        $invalidXml = '<Invalid>XML'
        { Invoke-RestMethod -Uri $pocEndpoint -Method Post -Body $invalidXml -ContentType 'application/xml' } | 
            Should -Throw
    }
}

Describe 'Service-NonPoC Contract Tests' {
    It 'Should accept valid XML and return valid response' {
        $response = Invoke-RestMethod -Uri $nonPocEndpoint -Method Post -Body $sampleRequest -ContentType 'application/xml'
        $response | Should -Not -BeNullOrEmpty
        $response.QuoteResponse | Should -Not -BeNullOrEmpty
        $response.QuoteResponse.Premium | Should -Not -BeNullOrEmpty
        $response.QuoteResponse.Premium | Should -BeOfType [Decimal]
    }

    It 'Should preserve decimal values exactly' {
        $response = Invoke-RestMethod -Uri $nonPocEndpoint -Method Post -Body $sampleRequest -ContentType 'application/xml'
        $premium = [decimal]$response.QuoteResponse.Premium
        $premium.ToString('G29') | Should -Match '^\d+\.\d{2}$'
    }

    It 'Should handle invalid XML gracefully' {
        $invalidXml = '<Invalid>XML'
        { Invoke-RestMethod -Uri $nonPocEndpoint -Method Post -Body $invalidXml -ContentType 'application/xml' } | 
            Should -Throw
    }
}
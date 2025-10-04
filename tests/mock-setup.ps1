# Mock service response XML
$script:pocResponseXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<QuoteResponse>
    <PolicyNumber>POC12345</PolicyNumber>
    <Premium>
        <Base>1250.00</Base>
        <Discounts>
            <SafeDriver>125.00</SafeDriver>
            <MultiCar>75.00</MultiCar>
        </Discounts>
        <Total>1050.00</Total>
    </Premium>
</QuoteResponse>
'@

$script:nonPocResponseXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<QuoteResponse>
    <PolicyNumber>NONPROC12345</PolicyNumber>
    <Premium>
        <Base>1275.00</Base>
        <Discounts>
            <SafeDriver>127.50</SafeDriver>
            <MultiCar>76.50</MultiCar>
        </Discounts>
        <Total>1071.00</Total>
    </Premium>
</QuoteResponse>
'@

# Mock Invoke-RestMethod
Mock Invoke-RestMethod {
    param($Uri, $Method, $Body, $ContentType)
    
    # Validate request
    if ($Method -ne 'Post') {
        throw "Method must be POST"
    }
    
    if ($ContentType -ne 'application/xml') {
        throw "Content type must be application/xml"
    }

    if ([string]::IsNullOrWhiteSpace($Body)) {
        throw "Request body is required"
    }

    try {
        # Validate request XML
        $null = [xml]$Body
    }
    catch {
        throw "Invalid request XML: $_"
    }

    # Create response based on endpoint
    $responseXml = if ($Uri -like "*poc") {
        $script:pocResponseXml
    }
    else {
        $script:nonPocResponseXml
    }

    # Return parsed XML with OuterXml property
    $response = [xml]$responseXml
    Add-Member -InputObject $response -MemberType ScriptProperty -Name "OuterXml" -Value { 
        return $this.InnerXml 
    } -Force

    return $response
} -ModuleName DiffReport
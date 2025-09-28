BeforeAll {
    $srcPath = (Get-Item $PSScriptRoot).Parent.FullName
    $modulesPath = Join-Path $srcPath "modules"
    $examplesPath = Join-Path (Get-Item $srcPath).Parent.FullName "examples"
    $exampleRequestPath = Join-Path $examplesPath "request.xml"
    $script:diffReportPath = Join-Path $PSScriptRoot "diff-report.ps1"

    # Import modules for mocking
    Import-Module (Join-Path $modulesPath "XmlDiff.psm1") -Force
    Import-Module (Join-Path $modulesPath "Utils.psm1") -Force

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
        param($Uri)
        if ($Uri -like "*poc") {
            [xml]$script:pocResponseXml
        }
        else {
            [xml]$script:nonPocResponseXml
        }
    }
}

Describe "End-to-End XML Diff Testing" {
    Context "Basic functionality" {
        BeforeAll {
            # Create a temp file for output
            $script:outputPath = Join-Path $TestDrive "diff-report.html"
        }

        It "Generates HTML report successfully" {
            # Execute the script
            { & $script:diffReportPath -RequestXmlPath $exampleRequestPath -OutputPath $script:outputPath } | 
                Should -Not -Throw

            # Verify output file exists
            $script:outputPath | Should -Exist
        }

        It "Report contains expected differences" {
            $report = Get-Content $script:outputPath -Raw

            # Check for expected differences in policy numbers
            $report | Should -Match "POC12345.*NONPROC12345"
            
            # Check for monetary value differences
            $report | Should -Match "1250\.00.*1275\.00" # Base premium
            $report | Should -Match "1050\.00.*1071\.00" # Total premium
        }

        It "Makes expected service calls" {
            # Execute script again
            & $script:diffReportPath -RequestXmlPath $exampleRequestPath -OutputPath $script:outputPath

            # Verify both services were called
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -like "*poc" }
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -like "*non-poc" }
        }
    }

    Context "Error handling" {
        It "Handles missing request XML gracefully" {
            { & $script:diffReportPath -RequestXmlPath "nonexistent.xml" } |
                Should -Throw -ExpectedMessage "*not found*"
        }

        It "Handles invalid request XML gracefully" {
            # Create invalid XML file
            $invalidXmlPath = Join-Path $TestDrive "invalid.xml"
            Set-Content -Path $invalidXmlPath -Value "This is not XML"

            { & $script:diffReportPath -RequestXmlPath $invalidXmlPath } |
                Should -Throw -ExpectedMessage "*Invalid request XML*"
        }

        It "Handles service failures gracefully" {
            # Mock service failure
            Mock Invoke-RestMethod { throw "Service unavailable" }

            { & $script:diffReportPath -RequestXmlPath $exampleRequestPath } |
                Should -Throw -ExpectedMessage "*Service * is unavailable*"
        }
    }
}
# XML Diff Analysis Tool Quickstart

This PowerShell script analyzes differences between XML responses from two web services providing insurance quotes. It ensures accurate comparison, especially for decimal/monetary values.

## Prerequisites

- PowerShell 7.5.x or later
- Access to service endpoints:
  - Service-PoC: http://localhost:7072/quotes/api/poc
  - Service-NonPoC: http://localhost:7072/quotes/api/non-poc

## Usage

```powershell
.\diff-report.ps1 -RequestXmlPath <path-to-request.xml>
```

The script will:
1. Send the XML request to both service endpoints
2. Validate the responses
3. Generate an HTML diff report highlighting differences

## Output

- An HTML report showing differences between the two responses
- Preserves decimal/monetary values exactly for accurate comparison
- Includes metadata (timestamp, service versions, request context)

## Error Handling

The script handles various scenarios:
- Service unavailability
- Invalid XML responses
- Schema validation failures
- Network timeouts

## Example

```powershell
# Send a test quote request
.\diff-report.ps1 -RequestXmlPath .\sample-quote-request.xml
```
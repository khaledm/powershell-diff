# Example Results

This document shows example outputs from the XML diff tool when comparing insurance quote responses.

## Sample Request

See [request.xml](request.xml) for a complete example of the request XML format. The request XML follows a standard insurance quote request structure with customer details, vehicle information, coverage options, and endorsements.

## Sample Responses

The tool compares responses from two services:

1. [PoC Service Response](service-poc-response.xml)
2. [Non-PoC Service Response](service-non-poc-response.xml)

## Key Differences

In this example, the services return responses with several differences:

1. QuoteId format:
   - PoC: `Q12345`
   - Non-PoC: `Q12345-ALT`

2. Risk Assessment:
   - PoC RiskScore: `85`
   - Non-PoC RiskScore: `82`

3. Vehicle Categorization:
   - PoC: `STANDARD`
   - Non-PoC: `MID_RANGE`

4. Premium Calculations:
   - Base Premium:
     - PoC: `1250.00`
     - Non-PoC: `1275.00` (+2%)
   - Safe Driver Discount:
     - PoC: `-125.00`
     - Non-PoC: `-127.50` (same 10% rate)
   - Loyalty Discount:
     - PoC: `-75.00`
     - Non-PoC: `-76.50` (same 6% rate)
   - Risk Factor:
     - PoC: `50.00`
     - Non-PoC: `55.00` (+10%)
   - Total Premium:
     - PoC: `1100.00`
     - Non-PoC: `1126.00` (+2.36%)
   - Monthly Payment:
     - PoC: `91.67`
     - Non-PoC: `93.83` (+2.36%)

## HTML Report

The tool generates an HTML report highlighting these differences. The report includes:

1. Side-by-side comparison of XML structures
2. Highlighted differences with exact values
3. Decimal precision preservation for all monetary amounts
4. Navigation links for quick access to specific sections

Example report screenshot showing premium differences:

```text
+------------------------+-------------------------+
|       PoC Quote       |      Non-PoC Quote      |
+------------------------+-------------------------+
| Base Premium: 1250.00 | Base Premium: 1275.00   |
| Risk Score: 85        | Risk Score: 82          |
| Total: 1100.00       | Total: 1126.00          |
+------------------------+-------------------------+
```

## Report Features

1. Color coding:
   - Green: Added elements/attributes
   - Red: Removed elements/attributes
   - Yellow: Modified values

2. Collapsible sections for better navigation

3. Preserved formatting:
   - XML structure indentation
   - Decimal place accuracy
   - Original data types
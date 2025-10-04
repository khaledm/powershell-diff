# XML Diff Module

The XML Diff module (`XmlDiff.psm1`) is the core comparison engine of the XML Diff Analysis Tool. It provides accurate and deterministic XML comparison with special handling for decimal/monetary values.

## Design Principles

1. **XML Response Integrity**
   - No modification of source XML during comparison
   - Preserves complete structure and content
   - Handles all XML data types correctly

2. **Deterministic Analysis**
   - Same inputs always produce identical results
   - Version-controlled comparison logic
   - Documented comparison rules

3. **Comprehensive Coverage**
   - Element presence/absence
   - Value changes (with decimal precision)
   - Attribute modifications
   - Structural differences
   - Order significance (optional)

## Core Functions

### Compare-XmlContent

The main function for comparing two XML documents.

```powershell
function Compare-XmlContent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReferenceXml,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DifferenceXml,

        [Parameter(Mandatory = $false)]
        [switch]$OrderSignificant
    )
}
```

#### Parameters

- `ReferenceXml`: The baseline XML content to compare against
- `DifferenceXml`: The XML content being compared to the reference
- `OrderSignificant`: Whether element order matters in the comparison

#### Returns

Returns a diff result object containing:
- Change type (Added, Removed, Modified)
- Path to changed element
- Original and new values
- Context information

#### Example

```powershell
$refXml = @"
<Premium>
    <Base>1250.00</Base>
    <Total>1050.00</Total>
</Premium>
"@

$diffXml = @"
<Premium>
    <Base>1275.00</Base>
    <Total>1071.00</Total>
</Premium>
"@

$result = Compare-XmlContent -ReferenceXml $refXml -DifferenceXml $diffXml
```

## Implementation Details

### Decimal Handling

The module uses specific techniques to preserve decimal/monetary values:

1. Direct string comparison for exact precision
2. Custom decimal parsing for value comparisons
3. No floating-point conversion to avoid rounding errors

### Node Comparison Algorithm

1. Compare node types (element, attribute, text)
2. Compare names and namespaces
3. Compare values with type-specific handlers
4. Recursively compare child nodes
5. Track position if order significant

### Error Handling

The module implements robust error handling:

1. XML parsing validation
2. Type checking and conversion
3. Structural integrity verification
4. Memory usage optimization

## Performance Considerations

1. Large Document Handling
   - Streaming XML reading for large files
   - Memory-efficient comparison
   - Progress reporting for long operations

2. Optimization Techniques
   - Early termination on mismatch
   - Hash-based quick comparisons
   - Parallel processing where safe

## Testing

The module includes comprehensive tests:

1. Unit Tests
   - Basic XML comparison
   - Decimal precision
   - Order significance
   - Error cases

2. Performance Tests
   - Large document benchmarks
   - Memory usage monitoring
   - Timing statistics

## Example Scenarios

### Basic Comparison
```powershell
# Compare two simple XML fragments
$diff = Compare-XmlContent -ReferenceXml "<value>1.23</value>" -DifferenceXml "<value>1.24</value>"
```

### Order-Sensitive Comparison
```powershell
# Compare XML where order matters
$diff = Compare-XmlContent -ReferenceXml $xml1 -DifferenceXml $xml2 -OrderSignificant
```

### Large Document Comparison
```powershell
# Compare large XML files with progress reporting
$diff = Compare-XmlContent -ReferenceXml $largeXml1 -DifferenceXml $largeXml2
```

## Dependencies

- PowerShell 7.5.x
- System.Xml namespace
- Utils module for logging

## See Also

- [Utils Module](utils.md)
- [Diff Report Module](diff-report.md)
- [Testing Guide](../testing.md)
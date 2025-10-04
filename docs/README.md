# XML Diff Analysis Tool Documentation

## Quick Start

The XML Diff Analysis Tool is a PowerShell module that helps you compare XML responses from two web services with special attention to preserving decimal/monetary values.

### Installation

1. Clone the repository:
```powershell
git clone https://github.com/khaledm/powershell-diff.git
cd powershell-diff
```

2. Import the modules:
```powershell
Import-Module .\src\modules\XmlDiff.psm1
Import-Module .\src\modules\Utils.psm1
Import-Module .\src\modules\DiffReport.psm1
```

### Basic Usage

1. Create your request XML (see [examples/request.xml](../examples/request.xml))

2. Run the diff report:
```powershell
.\src\diff-report.ps1 -RequestXmlPath .\request.xml -OutputPath diff-report.html
```

3. View the HTML report in your browser

## Documentation Index

- [Architecture Overview](architecture.md)
- [API Reference](api-reference.md)
- [Testing Guide](testing.md)
- [Examples](examples.md)

### Module Documentation

- [XML Diff Module](modules/xml-diff.md)
- [Utils Module](modules/utils.md)
- [Diff Report Module](modules/diff-report.md)

## Key Features

1. Accurate XML Comparison
   - Full structure analysis
   - Decimal/monetary value preservation
   - Order-sensitive comparison option

2. Comprehensive Reporting
   - HTML visualization
   - Machine-readable output
   - Detailed change tracking

3. Robust Error Handling
   - Service communication errors
   - XML validation
   - Diff analysis issues

4. Testing Support
   - Mock services included
   - Example data provided
   - Performance benchmarks

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

[MIT License](../LICENSE)
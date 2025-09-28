# XML Diff Module for PowerShell 7.5.x
# Handles accurate comparison of XML documents with special focus on preserving decimal/monetary values

function Compare-XmlContent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ReferenceXml,

        [Parameter(Mandatory = $true)]
        [string]$DifferenceXml,

        [Parameter(Mandatory = $false)]
        [switch]$OrderSignificant
    )

    try {
        # Parse XML documents
        $refDoc = [xml]$ReferenceXml
        $diffDoc = [xml]$DifferenceXml
    }
    catch {
        throw New-Object System.Exception "Invalid XML provided", $_.Exception, 'InvalidXml'
    }

    $differences = [System.Collections.ArrayList]::new()
    $metadata = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ReferenceSize = $ReferenceXml.Length
        DifferenceSize = $DifferenceXml.Length
    }

    # Compare XML nodes recursively
    $result = @{
        Differences = $differences
        Metadata = $metadata
        AreIdentical = $true
    }

    Compare-XmlNodes -RefNode $refDoc.DocumentElement -DiffNode $diffDoc.DocumentElement -Path "" -Result $result -OrderSignificant:$OrderSignificant
    
    return $result
}

function Compare-XmlNodes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$RefNode,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$DiffNode,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [hashtable]$Result,

        [Parameter(Mandatory = $false)]
        [switch]$OrderSignificant
    )

    # Compare attributes
    Compare-XmlAttributes -RefNode $RefNode -DiffNode $DiffNode -Path $Path -Result $Result

    # Compare child nodes
    $refChildren = @($RefNode.ChildNodes)
    $diffChildren = @($DiffNode.ChildNodes)

    if ($OrderSignificant) {
        Compare-XmlNodesOrdered -RefChildren $refChildren -DiffChildren $diffChildren -Path $Path -Result $Result
    }
    else {
        Compare-XmlNodesUnordered -RefChildren $refChildren -DiffChildren $diffChildren -Path $Path -Result $Result
    }
}

function Compare-XmlAttributes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$RefNode,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$DiffNode,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [hashtable]$Result
    )

    # Get all attributes from both nodes
    $refAttrs = @($RefNode.Attributes)
    $diffAttrs = @($DiffNode.Attributes)

    # Check for missing attributes
    foreach ($attr in $refAttrs) {
        $diffAttr = $DiffNode.GetAttribute($attr.Name)
        if ($null -eq $diffAttr) {
            $Result.Differences.Add(@{
                Type = "Missing"
                Path = "$Path[@$($attr.Name)]"
                ReferenceValue = $attr.Value
                DifferenceValue = $null
            }) | Out-Null
            $Result.AreIdentical = $false
        }
        elseif ($attr.Value -ne $diffAttr) {
            $Result.Differences.Add(@{
                Type = "Different"
                Path = "$Path[@$($attr.Name)]"
                ReferenceValue = $attr.Value
                DifferenceValue = $diffAttr
            }) | Out-Null
            $Result.AreIdentical = $false
        }
    }

    # Check for additional attributes
    foreach ($attr in $diffAttrs) {
        if (-not $RefNode.HasAttribute($attr.Name)) {
            $Result.Differences.Add(@{
                Type = "Additional"
                Path = "$Path[@$($attr.Name)]"
                ReferenceValue = $null
                DifferenceValue = $attr.Value
            }) | Out-Null
            $Result.AreIdentical = $false
        }
    }
}

function Compare-XmlNodesOrdered {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode[]]$RefChildren,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode[]]$DiffChildren,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [hashtable]$Result
    )

    $maxLength = [Math]::Max($RefChildren.Count, $DiffChildren.Count)
    
    for ($i = 0; $i -lt $maxLength; $i++) {
        if ($i -ge $RefChildren.Count) {
            # Additional node in diff
            $Result.Differences.Add(@{
                Type = "Additional"
                Path = "$Path/$($DiffChildren[$i].Name)"
                ReferenceValue = $null
                DifferenceValue = $DiffChildren[$i].OuterXml
            }) | Out-Null
            $Result.AreIdentical = $false
        }
        elseif ($i -ge $DiffChildren.Count) {
            # Missing node from diff
            $Result.Differences.Add(@{
                Type = "Missing"
                Path = "$Path/$($RefChildren[$i].Name)"
                ReferenceValue = $RefChildren[$i].OuterXml
                DifferenceValue = $null
            }) | Out-Null
            $Result.AreIdentical = $false
        }
        else {
            $newPath = "$Path/$($RefChildren[$i].Name)"
            
            if ($RefChildren[$i].NodeType -eq [System.Xml.XmlNodeType]::Text) {
                if ($RefChildren[$i].Value -ne $DiffChildren[$i].Value) {
                    $Result.Differences.Add(@{
                        Type = "Different"
                        Path = $newPath
                        ReferenceValue = $RefChildren[$i].Value
                        DifferenceValue = $DiffChildren[$i].Value
                    }) | Out-Null
                    $Result.AreIdentical = $false
                }
            }
            else {
                Compare-XmlNodes -RefNode $RefChildren[$i] -DiffNode $DiffChildren[$i] -Path $newPath -Result $Result -OrderSignificant
            }
        }
    }
}

function Compare-XmlNodesUnordered {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode[]]$RefChildren,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode[]]$DiffChildren,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [hashtable]$Result
    )

    # Create hashtable for O(1) lookup
    $diffMap = @{}
    foreach ($node in $DiffChildren) {
        if ($node.NodeType -eq [System.Xml.XmlNodeType]::Element) {
            $key = $node.Name + "|" + ($node.Attributes | ForEach-Object { "$($_.Name)=$($_.Value)" } | Sort-Object) -join "|"
            if (-not $diffMap.ContainsKey($key)) {
                $diffMap[$key] = [System.Collections.ArrayList]::new()
            }
            $diffMap[$key].Add($node) | Out-Null
        }
    }

    foreach ($refNode in $RefChildren) {
        if ($refNode.NodeType -eq [System.Xml.XmlNodeType]::Element) {
            $key = $refNode.Name + "|" + ($refNode.Attributes | ForEach-Object { "$($_.Name)=$($_.Value)" } | Sort-Object) -join "|"
            
            if ($diffMap.ContainsKey($key) -and $diffMap[$key].Count -gt 0) {
                $matchNode = $diffMap[$key][0]
                $diffMap[$key].RemoveAt(0)
                $newPath = "$Path/$($refNode.Name)"
                Compare-XmlNodes -RefNode $refNode -DiffNode $matchNode -Path $newPath -Result $Result
            }
            else {
                $Result.Differences.Add(@{
                    Type = "Missing"
                    Path = "$Path/$($refNode.Name)"
                    ReferenceValue = $refNode.OuterXml
                    DifferenceValue = $null
                }) | Out-Null
                $Result.AreIdentical = $false
            }
        }
    }

    # Check for any remaining nodes in diff (additional)
    foreach ($nodeList in $diffMap.Values) {
        foreach ($node in $nodeList) {
            $Result.Differences.Add(@{
                Type = "Additional"
                Path = "$Path/$($node.Name)"
                ReferenceValue = $null
                DifferenceValue = $node.OuterXml
            }) | Out-Null
            $Result.AreIdentical = $false
        }
    }
}

Export-ModuleMember -Function Compare-XmlContent
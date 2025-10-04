BeforeAll {
    Import-Module $PSScriptRoot\..\..\src\modules\XmlDiff.psm1 -Force
}

Describe 'XML Diff Logic Tests' {
    It 'Should detect value differences while preserving decimal precision' {
        $xml1 = @'
<Response>
    <Value>123.45</Value>
    <Decimal>9876.54</Decimal>
</Response>
'@
        $xml2 = @'
<Response>
    <Value>123.46</Value>
    <Decimal>9876.54</Decimal>
</Response>
'@
        $result = Compare-XmlContent -ReferenceXml $xml1 -DifferenceXml $xml2
        $result.Differences.Count | Should -Be 1
        $result.Differences[0].Path | Should -Be '/Response/Value'
        $result.Differences[0].ReferenceValue | Should -Be '123.45'
        $result.Differences[0].DifferenceValue | Should -Be '123.46'
    }

    It 'Should detect structural differences' {
        $xml1 = @'
<Response>
    <Element1>Value</Element1>
    <Element2>Value</Element2>
</Response>
'@
        $xml2 = @'
<Response>
    <Element1>Value</Element1>
    <Element3>Value</Element3>
</Response>
'@
        $result = Compare-XmlContent -ReferenceXml $xml1 -DifferenceXml $xml2
        $result.Differences.Count | Should -Be 2
        $result.Differences[0].Type | Should -Be 'Missing'
        $result.Differences[1].Type | Should -Be 'Additional'
    }

    It 'Should handle attribute differences' {
        $xml1 = @'
<Response attr1="value1" attr2="123.45"/>
'@
        $xml2 = @'
<Response attr1="value2" attr2="123.45"/>
'@
        $result = Compare-XmlContent -ReferenceXml $xml1 -DifferenceXml $xml2
        $result.Differences.Count | Should -Be 1
        $result.Differences[0].Path | Should -Be '/Response[@attr1]'
        $result.Differences[0].ReferenceValue | Should -Be 'value1'
        $result.Differences[0].DifferenceValue | Should -Be 'value2'
    }

    It 'Should detect order changes when significant' {
        $xml1 = @'
<Response>
    <Items>
        <Item id="1">First</Item>
        <Item id="2">Second</Item>
    </Items>
</Response>
'@
        $xml2 = @'
<Response>
    <Items>
        <Item id="2">Second</Item>
        <Item id="1">First</Item>
    </Items>
</Response>
'@
        $result = Compare-XmlContent -ReferenceXml $xml1 -DifferenceXml $xml2 -OrderSignificant
        $result.Differences.Count | Should -Be 1
        $result.Differences[0].Type | Should -Be 'Order'
    }

    It 'Should handle identical XML content' {
        $xml = @'
<Response>
    <Value>123.45</Value>
    <Nested>
        <Element attr="value">Text</Element>
    </Nested>
</Response>
'@
        $result = Compare-XmlContent -ReferenceXml $xml -DifferenceXml $xml
        $result.Differences.Count | Should -Be 0
        $result.AreIdentical | Should -Be $true
    }

    It 'Should handle invalid XML' {
        $validXml = '<Response><Value>123.45</Value></Response>'
        $invalidXml = '<Invalid>XML'
        { Compare-XmlContent -ReferenceXml $validXml -DifferenceXml $invalidXml } | Should -Throw -ErrorId 'InvalidXml'
    }
}
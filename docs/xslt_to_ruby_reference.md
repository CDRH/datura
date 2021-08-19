## XSLT to Ruby

Moving from XML stylesheets to ruby can seem daunting, but actually it's fun!

- [if, choose, when, otherwise](#if-choose-when-otherwise)
- [Equals and Other Comparisons](#equals-and-other-comparisons)
- [for-each()](#for-each)
- [substring-after()](#substring-after)
- [substring-before()](#substring-before)
- [text()](#text)

### If, choose, when, otherwise

if

```xml
<xsl:if test="condition">[your code here]</xsl:if>
```

Ruby

```ruby
if condition
  [your code here]
end

# or if you want to live dangerously

[your code here] if condition
```

choose, when, otherwise

```xml
<xsl:choose>
  <xsl:when test="condition">...</xsl:when>
  <xsl:when test="condition2">...</xsl:when>
  <xsl:otherwise>...</xsl:otherwise>
</xsl:choose>
```

Ruby

```ruby
if condition1
  ...
elsif condition2
  ...
else
  ...
end
```

Leave out `elsif` if you have no second condition

### Equals and Other Comparisons

Common Ruby operators:

| Name       | Ruby |
|-----------|------|
| Equal     |  ==  |
| Not equal |  !=  |
| Less than, etc |  <, <=  |
| Greater than, etc | >, >= |
| 

Ruby

```xml
<xsl:variable name="fish" select="//some_xpath/text()"/>
<xsl:if test="$fish = 'trout'">[some code]</xsl:if>
```

```ruby
fish = @xml.get_text("//some_xpath")
if fish == "trout"
  [some code]
end
```

### for-each()

Given this xml snippet:
```xml
<people>
  <author @role="primary">
    <persName><lastName>Cather</lastName></persName>
  </author>
  <author @role="editor">
    <persName><lastName>Somebody</lastName></persName>
  </author>
</people>
```

```xml
<xsl:for-each select="//author">
  <xsl:value-of select="persName/lastName"/>
  <xsl:text> the </xsl:text>
  <xsl:value-of select="@role">
<xsl:for-each>
```

```ruby
authors = @xml.xpath("//author")
authors.each do |author|
  lastname = author.get_text("persName/lastName")
  role = author["role"]
  puts "#{lastname} the #{role}"
end
```

### substring-after()

```
substring-after("Something|like this", "|")
```

```ruby
"Something|like this".split("|").last
```

Note:  `.last` will work great if your string only separated into two pieces. If you split on something like spaces and you need one of the words from the middle, you will have to work harder to get it out.

### substring-before()

Xpath: 

```
substring-before(string, '[Willa Cather]')
```

Ruby

```ruby
string.split([Willa Cather]).first
```

Alternatively, you can use regex

```ruby
string.split(/regex goes here/).first
```

### text()

Xpath

```
ele/text()
```

Ruby

```ruby
ele.text
```

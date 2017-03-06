## Xpath

### substring-before()

Xpath: 

substring-before(string, '[Willa Cather]')

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

## XSLT
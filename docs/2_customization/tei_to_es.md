## Customizing TEI to Elasticsearch

** If you are looking to customize another format to Elasticsearch, [documentation will be coming soon](TODO docs) **

** If you would like to customize TEI to HTML or Solr, [documentation will be coming soon](TODO docs) **


If you are already familiar with XSLT / XPath, you may be interested in comparing Ruby / Nokogiri equivalents with XSLT behavior.

- [Common Ruby Equivalents for Xpath and XSLT](xslt_to_ruby_reference.md) 

### Overriding in Ruby

The following document may be easier to follow if you have a working knowledge of the following in Ruby:

- variables
- arrays
- hashes
- string methods
- (optional) classes and inheritance

In general, the data repository is set up so that you may override ANYTHING inside a class or module in the `scripts/ruby` (sub)directories by putting it in your collection's script directory.  You need only have the class / module name at the top and the exact name of the method you are overriding and the rest of the original file's contents will not be altered.  This is how we will customize the TEI to Elasticsearch transformation.

If a file does not already exist at `collections/[your_collection]/scripts/tei_to_es.rb`, create one that looks like this:

```ruby
class TeiToEs
end
```

There are two types of overrides that you can do in this file:

- xpaths
- the json being sent to Elasticsearch
- field behavior

You may also

- add new xpaths
- add new fields
- access the @options from the config files
- read in additional XML files (annotations, references, etc)

I'll go through them in sections.

- [Tools](#tools)
  - [Variables](#variables)
  - [Using Nokogiri](#using-nokogiri)
- [Overriding Xpaths](#overriding-xpaths)
  - [Override XPath Basic](#override-xpath-basic)
  - [Override XPath List](#override-xpath-list)
  - [Override XPath Hash](#override-xpath-hash)
- [Overriding Fields](#overriding-fields)
  - [Getting XPath Contents](#getting-xpath-contents)
  - [Override Field Basic](#override-field-basic)
  - [Override Field If Then](#override-field-if-then)
  - [Override Field Nested](#override-field-nested)

### Tools

If you require more flexibility than simply changing some similar xpaths or getting a list of items, the following may interest you.

#### Variables

In the `tei_to_es.rb` file, you have access to a couple variables.

- `@filename`
- `@id`
- `@json`
- `@options`
- `@parent_xml`
- `@xml`
- `@xpaths`

##### @filename

This is the name of the file this (sub)document is pulling from without an extension

##### @id

Often associated with the filename, this is created with the `get_id` method in TeiToEs whose default behavior may be overridden.

##### @json

This is the JSON structure being built to sent to elasticsearch. You may directly manipulate it as you would a traditional hash, but keep in mind that its contents may not be populated yet.  You will need to look at the `scripts/ruby/lib/tei_to_es/request.rb` file to see the conventional json build order.

Typically I would recommend altering this in the `postprocessing` step, if you need to work with the json directly, but every collection is different so feel free to poke around with it and use it directly!

##### @options

The `@options` are created from combining the config files and any parameters you passed into via the command line.  You can see all the options being used by adding `-v` when you post.  This means that anything you add to the config file can be accessed when generating the ES request.  For example, you might add:

```yaml
# public.yml
default:
  copyright_info: Your statement here
```

```ruby
# tei_to_es.rb
def rights
  @options["copyright_info"]
end
```

##### @parent_xml

Just ignore this.

Kidding, kind of.  You will likely only need to work with this if you are using `tei_to_es_personography.rb` or a similarly named file.  [Please see the documentation on subdocuments](TODO docs).

##### @xml

This is your document's XML as a [Nokogiri](https://github.com/sparklemotion/nokogiri) object.  You can use methods like `get_text` which are built into this repository, or you can operate on the object directly [using Nokogiri](#using-nokogiri).

If you really wanted to, you would be able to add / alter the XML itself, if that would somehow help you in your quest.  It will not alter the actual TEI documents on the filesystem unless if you intentionally write to a file, but you will not be able to accidentally do that, so no worries.

##### @xpaths

This is the hash which contains all of the xpaths your document should be using.  Typically you will use it to access either the default xpaths in `scripts/ruby/lib/tei_to_es/xpaths.rb` or any you've overridden / added.

```ruby
@xpaths["titles"]["main"]
```

#### Using Nokogiri

There may be times that you can't accomplish everything that you want to do using some of the built in data tools like `get_list` and `get_text`.  For example, if you're selecting a person's name and need to parse attributes, roles, subnodes to build an object.  Then it's time to remember that `@xml` is a [Nokogiri::XML::Element](http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Element)

### Overriding XPaths

At `scripts/ruby/lib/tei_to_es/xpaths.rb` you can find a list of all the default xpaths being used by the default fields.  If you run your collection with no customization, the script will do the best it can with these defaults.  But let's say that your xml file doesn't have the publisher information in the same place as the default.

#### Override XPath Basic

```ruby
# default xpath

"publisher" => /TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]"
```

You would add the following code to your collection's `tei_to_es.rb` file:

```ruby
def override_xpaths
  xpaths = {}

  # your xpaths here
  xpaths["publisher"] = "/TEI/teiHeader/fileDesc/publicationStmt/publisher[1]"

  return xpaths
end
```

Now your collection will use your xpath but otherwise behave the same way as before.  That is, if it was returning a list of publishers previously, it will still attempt to return a list.  In our example, we know there is only `[1]` (the first) publisher being returned, so it's a good idea to specify that again in our override.

#### Override XPath List

But let's say we need to override something that has several options!  How would we change this?

```ruby
"creators" => [
  "/TEI/teiHeader/fileDesc/titleStmt/author",
  "//persName[@type = 'author']"
],
```

If we want to ADD to the list:

```ruby
xpaths["creators"] << "//another/xpath/for/collection"
```

If we want to ONLY have our new xpath in the list, we will have to make sure that it still looks like the array that ruby is expecting, since the old "creators" was an array:

```ruby
xpaths["creators"] = ["//our/new/xpath"]
```

If we want to add multiple new xpaths, we can do that, too!

```ruby
xpaths["creators"] = ["new/xpath", "another_xpath", "one_more/xpath"]
```

Since "creators" was already a list of xpaths we should be able to add any number of them!

#### Override XPath Hash

Another type of complicated xpath is demonstrated by "formats" and "titles".

```ruby
"titles" => {
  "main" => "/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'][1]",
  "alt" => "/TEI/teiHeader/fileDesc/titleStmt/title[1]"
}
```

If you want to override just one or both of them, it would look like this:

```ruby
# overrides only the "alt" title, does not change "main"
xpaths["titles"]["alt"] = "/your/new/xpath"
```

### Overriding Fields

`scripts/ruby/lib/tei_to_es/fields.rb` has a list of functions which generate fields used by elasticsearch.  You can override them to add new behavior.  Inside these overrides you can access information stored in the config file by using the `@options` object.  You may also do comparisons, check content of xpaths, and more!

#### Getting XPath Contents

The following are helpers created to make your life easier:

- get_text
- get_list

`get_text` will take one or many xpaths and condense their contents into a string.  `get_list` will return an array of their contents.  Here is an example of how they can be used:

```xml
<TEI>
  <person>Jadzia Dax</person>
  <person>Geordi LaForge</person>
</TEI>
```

```ruby
get_list "/TEI/person"
#=> ["Jadzia Dax", "Geordi LaForge"]

get_text "/TEI/person"
#=> "Jadzia Dax; Geordi LaForge"
```

`get_text` and `get_list` accept a few parameters.

- xpath(s) : a string or array of strings
- keep_tags (optional): defaults to false, pass in true if you want to convert italics, bold, underline to HTML
- xml (optional) : defaults to entire document XML, but you can pass in a different XML object if you like (example: you need to read an annotations file in and get information for your current document)

`get_text` only:

- delimiter (optional) : the separator between multiple items for get_text

This looks like the following:

```ruby
get_list xpaths, [keep_tags], [xml]
get_text xpaths, [keep_tags], [xml], [delimiter]
```

By default, `get_text` and `get_list` will strip out XML from the results of the xpath.  If you would like to preserve italics, bold, and underlining, pass in the "keep_tags" parameter to convert them from TEI to HTML:

```xml
<TEI>
  <body>She wrote the book <hi rend="italics">My 100 Year Old Moth</hi></body>
```

```ruby
get_text @xpaths["text"], true
#=> "She wrote the book <em>My 100 Year Old Moth</em>"
```

You can also customize the delimiter when `get_text` encounters multiple results (which defaults to using ";")

```ruby
get_text "/TEI/person", false, ","
#=> "Jadzia Dax, Geordi LaForge"

get_text @xpaths["people"], false, " &"
#=> "Jadzia Dax & Geordi LaForge"
```

Now that you know how to set xpaths and get their values, let's move to the part where you override field behavior.

#### Override Field Basic

You can override any of the fields found in `/scripts/ruby/lib/tei_to_es/fields.rb` by copying them into your `tei_to_es.rb` file and changing what they return.

Here is a very basic example which changes a hardcoded string response:

```ruby
# default version

def self.rights
  # Note: override by collection as needed
  "All Rights Reserved"
end

# collection version

def self.rights
  "For rights information, visit collectionname.unl.edu/rights"
end
```

Oh shoot, but your collection actually has information encoded in the TEI document itself which varies from file to file!  Not to worry, you can override the field and use one of your xpaths!

```ruby
# collection version

def self.rights
  get_text @xpaths["rights_holder"]
end
```

#### Override Field If Then

There might be circumstances where what you want to be in a field might depend on the contents of multiple xpaths.  Here is a basic example for checking that type of thing.

```ruby
def self.title
  title = get_text @xpaths["titles"]["main"]
  if title.empty?
    title = get_text @xpaths["titles"]["alt"]
  end
  return title
end
```

In the above example, the results for the main title's xpath are saved to "title."  If the results are empty, then instead title is assigned the value of the "alt" title.  You could also add a few lines of code to default to "No title" or similar if neither the main nor the alt return results.

You could also check one of the `@options` from the config file to determine what to return.  You may find `@id` useful as well. What follows is a rather contrived example, but you may find it useful.

```yaml
default:
  uri: actualsite.unl.edu
  display: true
development:
  uri: cdrhdev.unl.edu
```

```ruby
def self.somefield
  if @options["display"]
    return "#{@options["uri"]}/#{@id}"
  else
    return "Site unavailable"
  end
end
```

Note for devs:  You may also access the raw `@xml` object, `@id`, and `@file`.  `@file` is an instance of FileTei which inherits from FileType, so feel free to use methods and information related to those classes.

#### Override Field Nested

This is the most difficult type of override you'll likely encounter.  Some of elasticsearch's fields are "nested," meaning that you can add descriptive information about something.  For example:

```json
"id": "cat.8219",
"authors": [
  {
    "name": "Willa, Cather",
    "role": "Author",
    "id": "cat.per0001"
  },
  {
    "name": "So and So",
    "role": "Editor",
    "id": "cat.per0218"
  }
]
```

Fields like creator, contributors, and person fall into this nested category.  The following will walk you through how one of these fields is built, using one of the more complicated versions.

```ruby
  # 1
  def self.contributors
    # we're ready to start customizing this field
  end

  # 2
  def self.contributors
    # ultimately there are going to be multiple authors
    # so start with an array
    people = []
  end

  # 3
  def self.contributors
    people = []
    # @xpaths["contributors"] returns an array of xpaths
    # so iterate through each xpath one by one
    @xpaths["contributors"].each do |xpath|

    end
  end

  # 4
  def self.contributors
    people = []
    @xpaths["contributors"].each do |xpath|
      # for simpler fields, we can usually use get_list
      # to get the contents of multiple xpaths and results
      # but in this case, we have to call the .xpath method
      # directly on the main @xml object because we want
      # to get an XML object we can work with, not just a string
      # since this is a nested field and we need more info
      # (eles == elements)
      eles = @xml.xpath(xpath)
    end
  end

  # 5
  def self.contributors
    people = []
    @xpaths["contributors"].each do |xpath|
      eles = @xml.xpath(xpath)
      eles.each do |ele|
        # iterate through all of the XML elements returned
        # so we can begin to manipulate a single one!
      end
    end
  end
```

Okay, now for the fun part!  We are finally ready to work with an element.  Let's say it looks something like this:

```xml
<persName xml:id="cat.0182" role="Encoder">Weakly, Laura</persName>
```

In order to get at the attributes and contents, we can use the following:

```ruby
ele.text #=> text contents
ele["id"] #=> attribute value
```

Armed with that knowledge, plus the notion that we want to return a hash with keys "name", "id", and "role", the whole thing now looks like this:

```ruby
  # 6
  def self.contributors
    people = []
    @xpaths["contributors"].each do |xpath|
      eles = @xml.xpath(xpath)
      eles.each do |ele|
        # push the hash you're creating onto the people array
        people << { "name" => ele.text, "id" => ele["id"], "role" => ele["role"] }
      end
    end
    # return the array at the bottom of the method!
    return people
  end
```

As mentioned previously, this is likely the most difficult of the types of overrides you may need to do, so hopefully the majority of your field requirements are much less complicated!

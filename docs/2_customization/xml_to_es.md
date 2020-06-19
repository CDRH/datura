## Customizing XML to Elasticsearch

**NOTE: Currently this repository only accommodates HTML, TEI, webs (web scraped HTML), and VRA.  The process to customize them should be nearly identical, so for the purposes of this documentation, we will be working with TEI.**

If you are already familiar with XSLT / XPath, you may be interested in comparing Ruby / Nokogiri equivalents with XSLT behavior.

- [Common Ruby Equivalents for Xpath and XSLT](xslt_to_ruby_reference.md)

### Overriding in Ruby

The following document may be easier to follow if you have a working knowledge of the following in Ruby:

- variables
- arrays
- hashes
- string methods
- (optional) classes and inheritance

In general, the data repository is set up so that you may override ANYTHING inside a class or module in the `scripts/ruby` (sub)directories by putting it in your collection's script directory.  You need only have the class / module name at the top and the exact name of the method you are overriding and the rest of the original file's contents will not be altered.  This is how we will customize the TEI to Elasticsearch transformation.  If you are customizing a VRA script, just sub that into the filenames and classes below.

If a file does not already exist at `scripts/overrides/tei_to_es.rb`, create one that looks like this:

```ruby
class TeiToEs
end
```

There are several types of overrides that you can do in this class:

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

This is the name of the file this (sub)document is pulling from without an extension.

##### @id

Often associated with the filename, this is created with the `get_id` method in TeiToEs whose default behavior may be overridden.  The @id is generally NOT the filename when you're dealing with subdocuments, like from a personography file.

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

To see the entire list of `@options` available to your collection, run this command:

```
print_options -e [environment]
```

##### @parent_xml

Just ignore this.  This is only relevant if you are working with subdocuments, like from a personography file, encyclopedia, or perhaps if you wanted to split a single file book's chapters into individual search items.  [Please see the documentation on subdocuments TODO docs]().

##### @xml

This is your document's XML as a [Nokogiri](https://github.com/sparklemotion/nokogiri) object.  You can use methods like `get_text` which are built into this repository, or you can operate on the object directly.

If you really wanted to, you would be able to add / alter the XML itself, if that would somehow help you in your quest.  It will not alter the actual TEI documents on the filesystem unless if you really know what you're doing and intentionally try to alter the original files.  There's no risk of that happening accidentally, so feel free to alter the XML object as preprocessing if you need to!

##### @xpaths

This is the hash which contains all of the xpaths your document should be using.  Typically you will use it to access either the default xpaths in `scripts/ruby/lib/tei_to_es/xpaths.rb` or any you've overridden / added.

```ruby
@xpaths["title"]
```

#### Using Nokogiri

There may be times that you can't accomplish everything that you want to do using some of the built in tools provided by datura. For example, if you're selecting a person's name and need to parse the parent node's attributes to build an object.  Then it's time to remember that `@xml` is a [Nokogiri::XML::Element](http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Element)

For the most part, however, you should be able to accomplish your goals using
the methods in [Getting XPath Contents](#getting-xpath-contents).

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
  # create an empty container for your overrides
  xpaths = {}
  # add the publisher xpath
  xpaths["publisher"] = "/TEI/teiHeader/fileDesc/publicationStmt/publisher[1]"

  # the last line should always be your new xpaths
  xpaths
end
```

You may also define your xpaths like this, which is a bit simpler. However,
using this system may make it more difficult to override fields such as
`source` with nested xpaths. This is a case where it will be helpful if you
understand Ruby syntax for Hashes!

```ruby
def override_xpaths
  {
    "publisher" => "/TEI/teiHeader/fileDesc/publicationStmt/publisher[1]"
  }
end
```

Now your collection will use your xpath but otherwise behave the same way as before.  That is, if it was returning a list of publishers previously, it will still attempt to return a list.  In our example, we know there is only `[1]` (the first) publisher being returned, so it's a good idea to specify that again in our override.

#### Override XPath List

But let's say we need to override something that has several options!  How would we change this?

```ruby
{
  "creator" => [
    "/TEI/teiHeader/fileDesc/titleStmt/author",
    "//persName[@type = 'author']",
    "/TEI/teiHeader/fileDesc/sourceDesc/bibl/author",
    "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/author",
    "//correspDesc/correspAction[@type='sentBy']/persName"
  ],
}
```

Well, if you don't need all those options, you can just entirely redefine it:

```ruby
{
  "creator" => "//our/new/xpath"
}
```

You can also add a whole list of xpaths, possibly including some of the
xpaths that will otherwise be overridden:

```ruby
{
  "creator" => [
    "//persName[@type='author']",
    "//our/new/xpath",
  ]
}
```

#### Override XPath Hash

Another type of complicated xpath is demonstrated by the `source` field. Assuming
that you only need to change a few values in source, you may want to only alter
them, but you are, of course, able to overwrite the entire source hash if desired.

```ruby
xpaths = {}
# overwrite ALLLLL the source fields
xpaths["source"] = {
  # field => xpath
}

# overwrite just some of the fields
xpaths["source"]["author"] = "new/xpath"
xpaths["source"]["title"] = "new/xpath"
}

xpaths
```

### Overriding Fields

Datura's `lib/datura/to_es/tei_to_es/fields.rb` has a list of functions which generate fields used by elasticsearch.  You can override them to add new behavior.  Inside these overrides you can access information stored in the config file by using the `@options` object.  You may also do comparisons, check content of xpaths, and more!

#### Getting XPath Contents

The following are helpers created to make your life easier:

- get_text
  - grab the text of one or many xpaths
- get_list
  - create a list of text from one or many xpaths
- get_elements
  - get the xml elements from one or many xpaths

Here's how they might be used:
```xml
<TEI>
  <person dept="science">Jadzia Dax</person>
  <person dept="engineering">Geordi LaForge</person>
</TEI>
```

```ruby
get_list("/TEI/person")
#=> ["Jadzia Dax", "Geordi LaForge"]

get_text("/TEI/person")
#=> "Jadzia Dax; Geordi LaForge"

get_element('/TEI/person')
#=> <person dept="science"Jadzia Dax</person>, <person dept="engineering">Geordi LaForge</person>
```

By default, all of the above methods operate on the `@xml` object, which is
typically the specific TEI file. However, you may ask them to operate on a different
file or sub-set with the `xml` keyword. This may be helpful if you are working
with other documents, such as authority files, or if you are working within
elements in your TEI document, such as pages or personography entries.

```
# let's say that you need to pull in a title from an authority file
# named `@works`:

work_id = get_text("/ref/@id")
get_text("//works/work[@id='#{work_id}'']", xml: @works)
```

`get_text` and `get_list`  parameters:

- keep_tags (optional): defaults to false, pass in true if you want to convert italics, bold, underline to HTML
- xml (optional) : defaults to entire document XML, or pass in your own XML object

`get_text` only:

- delimiter (optional) : defaults to ";", the separator between multiple items

This looks like the following:

```ruby
get_list(xpaths, keep_tags: [keep_tags], xml: [xml])
get_text(xpaths, keep_tags: [keep_tags], xml: [xml], delimiter: [delimiter])
```

By default, `get_text` and `get_list` will strip out XML from the results of the xpath.  If you would like to preserve italics, bold, and underlining, pass in the "keep_tags" parameter to convert them from TEI to HTML:

```xml
<TEI>
  <body>She wrote the book <hi rend="italics">My 100 Year Old Moth</hi></body>
```

```ruby
get_text(@xpaths["text"], keep_tags: true)
#=> "She wrote the book <em>My 100 Year Old Moth</em>"
```

You can also customize the delimiter when `get_text` encounters multiple results (which defaults to using ";")

```ruby
get_text("/TEI/person", delimiter: ",")
#=> "Jadzia Dax, Geordi LaForge"

get_text(@xpaths["people"], delimiter: " &")
#=> "Jadzia Dax & Geordi LaForge"
```

You can use `get_elements` to access additional attributes and information from xpaths.

```ruby
people = get_elements("/TEI/person")
#=> <person dept="science"Jadzia Dax</person>, <person dept="engineering">Geordi LaForge</person>

people.each do |p|
  puts p.text     # use .text or get_text("/", xml: p)
  puts p["dept"]  # fancy way to grab immediate attribute
end
#=> Jadzia Dax
#=> science
#=> Geordi LaForge
#=> engineering
```

Now that you know how to set xpaths and get their values, let's move to the part where you override field behavior.

#### Override Field Basic

You can override any of the fields found in datura's `/lib/datura/to_es/tei_to_es/fields.rb` by copying them into your `tei_to_es.rb` file and changing what they return.

Here is a very basic example which changes to a hardcoded string response:

```ruby
# default version

def rights
  get_text(@xpaths["rights"])
end

# collection version

def rights
  "For rights information, visit collectionname.unl.edu/rights"
end
```

Oh shoot, but your collection actually has information encoded in the TEI document itself which varies from file to file!  Not to worry, you can override the field AND use one of your xpaths!

```ruby
# collection version

def rights
  if (file has some criteria)
    get_text(@xpaths["rights"])
  else
    "CC 4.0 License"
  end
end
```

#### Override Field If Then

There might be circumstances where what you want to be in a field might depend on the contents of multiple xpaths or options, etc.

```yaml
default:
  uri: actualsite.unl.edu
  display: true
development:
  uri: cdrhdev.unl.edu
```

```ruby
def somefield
  if @options["display"]
    "#{@options["uri"]}/#{@id}"
  else
    "Site unavailable"
  end
end
```

Note for devs:  You may also access the raw `@xml` object, `@id`, and `@file`.  `@file` is an instance of FileTei which inherits from FileType, so feel free to use available attributes / methods related to that class.

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

Fields like creator, contributor, and person fall into this nested category.  The following will walk you through how one of these fields is built, using one of the more complicated versions.

```ruby
  # 1
  def contributor
    # we're ready to start customizing this field
  end

  # 2
  def contributor
    # let's start by grabbing whatever we've got at the xpath
    contribs = get_elements(@xpaths["contributor"])
  end

  # 3
  def contributor
    # we need to do something with each contributor in order to pull
    # out information like identifier and role, so we add `.map` to iterate

    contribs = get_elements(@xpaths["contributor"]).map do |ele|

    end
  end

  # 4
  def contributor
    # with each contributor element, we can grab the "id" and "role"
    # attributes with ["id"] and the text with .text
    contribs = get_elements(@xpaths["contributor"]).map do |ele|
      {
        "id" => ele["id"],
        "name" => Datura::Helpers.normalize_space(ele.text),
        "role" => Datura::Helpers.normalize_space(ele["role"])
      }
    end
  end

  # 5
  def contributor
    contribs = get_elements(@xpaths["contributor"]).map do |ele|
      {
        "id" => ele["id"],
        "name" => Datura::Helpers.normalize_space(ele.text),
        "role" => Datura::Helpers.normalize_space(ele["role"])
      }
    end
    # finally, we take our list of contributors and crush down any
    # that are not unique. We don't need one person's name showing up 3 times,
    # after all!
    contribs.uniq
  end
```

Hopefully the majority of your field requirements are much less complicated than
needing to recreate / imitate these nested fields!

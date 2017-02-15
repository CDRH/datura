## Customizing tei_to_es.rb

In each project, there should be a file in `scripts/tei_to_es.rb`.  It can be used to override xpaths and behavior found in `scripts/ruby/lib/tei_to_es.rb` and can be considered to be taking the place of the old XSLT stylesheets.  At bare minimum, the file should look like the following:

```
module TeiToEs
end
```

There are two types of overrides that you can do in this file:

- xpaths
- field behavior

You may also

- add new xpaths
- add new fields
- access the @options from the config files

I'll go through them in sections.

### XPaths

At `scripts/ruby/lib/tei_to_es/xpaths.rb` you can find a list of all the default xpaths being used by the default fields.  If you run your project with no customization, the script will do the best it can with these defaults.  But let's say that your xml file doesn't have the publisher information in the same place as the default.

#### Override XPath Basic

```ruby
# default xpath

"publisher" => /TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]"
```

You would add the following code to your project's `tei_to_es.rb` file:

```ruby
@xpaths["publisher"] = "/TEI/teiHeader/fileDesc/publicationStmt/publisher[1]"
```

Now your project will use your xpath but otherwise behave the same way as before.  That is, if it was returning a list of publishers previously, it will still attempt to return a list.  In our example, we know there is only `[1]` (the first) publisher being returned, so it's a good idea to specify that again in our override.

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
@xpaths["creators"] << "//another/xpath/for/project"
```

If we want to ONLY have our new xpath in the list, we will have to make sure that it still looks like the array that ruby is expecting, since the old "creators" was an array:

```ruby
@xpaths["creators"] = ["//our/new/xpath"]
```

If we want to add multiple new xpaths, we can do that, too!

```ruby
@xpaths["creators"] = ["new/xpath", "another_xpath", "one_more/xpath"]
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
@xpaths["titles"]["alt"] = "/your/new/xpath"
```

### Fields

`scripts/ruby/lib/tei_to_es/fields.rb` has a list of functions which generate fields used by elasticsearch.  You can override them to add new behavior.

```ruby
# default version

def self.rights
  # Note: override by project as needed
  "All Rights Reserved"
end

# override in your project's tei_to_es.rb to use information from each TEI file

def self.rights
  get_text @xpaths["rights_holder"]
end
```

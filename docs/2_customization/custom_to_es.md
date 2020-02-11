# Custom Formats to Elasticsearch

Datura provides minimal support for formats other than TEI, VRA,
HTML, and CSV through basic infrastructure to support overrides.

## The Basics

If you want to add a custom format such as YAML, XLS spreadsheets, or if you
want to add some highly customized version of HTML or CSV in addition to an
existing batch of CSVs, you need to create a directory in source with a unique name.

*The name you select should not be `authority` or `annotations`*. Those names
are reserved for projects which require authority files such as gazateers and
scholarly notes about items.

Let's say you need to index `.txt` files. Once you have created the directory
`source/txt` and populated it with a few files, you can run the Datura scripts
with:

```
post -f txt
```

That will start off the process of grabbing the files and reading them.
Unfortunately, since Datura has no idea what sort of format to prepare for, nor
how many items you might need per format (for example, a PDF might be one item
per file while a tab-separated doc could be dozens or hundreds per file).

Additionally, once Datura reads in a file, it doesn't know how or what
information to extract, so it looks like it's time to start writing your own
code!

## Reading Your Format and Prepping for Launch

### read_file

In [file_custom.rb](/lib/datura/file_types/file_custom.rb), Datura reads in a
file as text and makes a new CustomToEs object from it. You may wish to
override the following to accommodate your format:

```
class FileCustom < FileType
  def read_file
    File.read(@file_location)
  end
end
```

Currently, this is just straight up attempting to read a file's text. However,
if you are working with XML / HTML, JSON, CSV, YAML, etc, there is likely a
better, format-specific parser that will give you more control. For example,
you might change `read_file` to:

```
# note: may need to require libraries / modules
require "yaml"

class FileCustom < FileType
  def read_file
    YAML.load_file(@file_location)
  end
end
```

### subdocs

The next thing you will need to address if your format needs to be split into
multiple documents (such as personography files, spreadsheets, database dumps,
etc), is how to split up a file. By default, Datura assumes your file is one
item. If that is not the case, override `subdocs`:

```
def subdocs
  Array(@file)
end
```

Change that to something which will return an array of items. For example, from
our YAML example, you might have:

```
def subdocs
  @file["texts"]
end
```
Or for an XML file:
```
def subdocs
  @file.xpath("//grouping")
end
```

### build_es_documents

You're almost done with `file_custom.rb`. You just need to kick off a class
that will handle the transformation per sub-document. For simplicity's sake, if
this is a totally new format that Elasticsearch hasn't seen before, I recommend
leaving this method alone. You can move onto the next step,
[CustomToEs](#customtoes).

If you want to try to piggyback off of an existing Datura class, then you may
need to override this method. Instead of calling `CustomToEs.new()` in it, you
would instead need to add a `require_relative` path at the top of the file to
your new class, and then call `YournewclassToEs.new()` from `build_es_documents`.

In your new class, you could presumably do something like

```
class YournewclassToEs < XmlToEs
  # now you have access to XmlToEs helpers for xpaths, etc
end
```

## CustomToEs

The files in the [custom_to_es](/lib/datura/to_es/custom_to_es) directory and
[custom_to_es.rb](/lib/datura/to_es/custom_to_es.rb) give you the basic
structure you need to create your own version of these files. Since
Datura has no way of knowing what format might come its way, the majority of the
methods in `custom_to_es/fields.rb` are empty.

The only thing you **MUST** override is `get_id`.

Create a file in your overrides directory called `custom_to_es.rb` and add the
following:

```
class CustomToEs

  def get_id
    # include code here that returns an id
    # it could be the @filename(false) to get a filename without extension
    # or it could be `@item["identifier"] to get the value of a column, etc

    # you may want to prepend a collection abbreviation to your id, like
    # "nei.#{some_value}"
  end

end
```

You can also add preprocessing or postprocess here by overriding `create_json`.

It is expected that you will override most of the methods in `fields.rb`. For
example, you might set a category like:

```
def category
  # your code here, referencing @item if necessary
end
```

One more note: due to how `CustomToEs` is created, it is expecting a subdoc
and the original file. This is because it accommodates for something like a
personography file, where you may want to deal with an individual person as
`@item` but need to reference `@file` to get information about the repository
or rightsholder, etc. If your format does not use sub-documents, then you
may simply refer to `@item` throughout and ignore `@file`, which should be
identical.

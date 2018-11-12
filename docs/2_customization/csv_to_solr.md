## Customizing CSV to Solr

### No Customization

If you have control over a collection's data from the beginning and will be using a CSV, it is highly recommended that you name the CSV columns the same as the Solr schema's fields, underscores and all.  Then all you need to do is run the `post.rb` script and you'll be home free!

### Overrides

Understandably, not all projects can ingest their CSVs into Solr without some tinkering, even if it's just that dates need to be reformatted.

Check out the example collection's CSV overrides in `collections/example/scripts/overrides/file_csv.rb`.

```
class FileCsv
  def row_to_solr(doc, headers, row)
    doc.add_child("<field name='id'>#{row['id']}</field>") if row['id']
    doc.add_child("<field name='title'>#{row['title']}</field>") if row['title']
    doc.add_child("<field name='category'>#{row['category']}</field>") if row['category']
    doc.add_child("<field 
    [etc]
    return doc
  end
end
```

This method is looking at one single row of the CSV at a time.  There are three arguments available in `row_to_solr`:

- doc (the xml document you are building for Solr)
- headers (an array of the column headers)
- row (a single row of the csv)

You may iterate through by header, or on an index of the CSV fields, but it's recommended that you use `row['column_name']` to access values, for clarity.

Variables available from FileType are accessible from FileCsv, like `@options` and `@file_location`, if you should need to manipulate an item with more finesse.

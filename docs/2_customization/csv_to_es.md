## Customizing CSV to Elasticsearch

The CSV (comma-separated values) transformation works similarly as the XML to Elasticsearch transformer but with one BIG difference:

__Each row of the CSV is treated as its own "document"__

This is because when we read an XML file, we're assuming that for the most part, that file represents one letter, one novel, etc. When that's not true, we have to take an extra step to split the XML file up into sub-documents.

However, since CSVs are by their very nature a bunch of different rows of information, we're assuming that each row should be treated as its own entity.

### Getting started

If you export a spreadsheet to a CSV file and stick it in the `source/csv` directory, you will need to run the following in order to transform or post your CSV.

```
post -f csv
```

The CSV will be split up by row, each of which will become a new CsvToEs instance.

By default, each of the API fields will look for a column name which matches them exactly. A couple fields have more specific behavior, such as `creator`, which will try to split up values in that field by semi-colon to accommodate multiple creators.

If you look in `lib/datura/to_es/csv_to_es`, you'll see `fields.rb` and `request.rb`. The only one you'll need to worry about is `fields.rb`.  In `fields.rb` you will find a method for each of the API fields.

If you need to customize one, you will want to copy it into your own data repo's overrides as `csv_to_es.rb`.  For example, let's override `category`.

```ruby
# your data repo /script/overrides/csv_to_es.rb

class CsvToEs

  def category
    @row["source_type"]
  end

end
```

Above, we're using `@row` to refer to our current row of the spreadsheet, and then `["source_type"]` refers to the column. You can add whatever sort of Ruby code you like here to return a value.

### Fancier configuration

At any point, you have access to the entire CSV and not just your row by using `@csv`. Hopefully you don't need to do this often, but it's possible that you may need to get information from a different row for your current record.

You can also get the user `@options` if you need to get the requested environment, etc.

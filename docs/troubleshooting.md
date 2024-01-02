## Troubleshooting

### Verbose Mode

Run your command against with `-v` flag. This prints out all the options the script is using and provides further debug lines

### Where is the problem occurring?

Is the problem in reading files, transforming them to Elasticsearch JSON, transforming them to HTML, or when posting?

### Configuration

Make sure your configuration information is correct, and make sure you are overriding everything in `data/config/*` including the `private.yml` file

### Elasticsearch / Solr Indexes

Is the index you are pointing to the correct one?  Do you have an index with the correct schema data?  Have you used the `es_set_schema.rb` script yet for your collection's name?

### Permissions

Do you have the correct permissions to run all of the files?  Check that the TEI / VRA / etc are all readable and that you can write to any directories like `html-generated`

### XSLT

If you type `saxon` into the command line and hit enter, does it find the command?  Saxon will need to be able to run from the command line.  See the [saxon docs](saxon.md) for setup information.

### Tests

Run the tests, is everything passing?  If something is failing there, then you may be able to determine if a recent commit has broken something, or narrow down the problem further.

### Common errors

- `Incorrect HTTP method` and/or `405 error`: Check to make sure that you are using the correct version of Elasticsearch that goes with the repository, and the correct version of the API schema. The new version of Datura with the 2.0 API schema must use ES8 or higher.
- JSON parsing error. These frequently occur in repositories that use CSV data that is pulled from Airtable. Python scripts creating the CSV spreadsheets often introduce single quotes into fields, which is not legal JSON and not parsable by Ruby's JSON module. Methods must be used in the python scripts to make these fields legal JSON, such as `json.dumps`.

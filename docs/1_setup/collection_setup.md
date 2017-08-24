## Set up New API collection

### Step 1:  Create a new collection directory

Copy the example collection to a new directory with your collection's name:

```
cp -r collections/example collections/[your_collection]
```

If you want more information about the directory structure and included files, please see the [file system](../4_developers/file_structure.md) docs.

For now, delete the existing files out of the `tei` directory.  At this point, add any of the following to the corresponding directories:

- csvs and spreadsheets in csv
- Dublin Core in dc
- TEI XML in tei
- VRA Core in vra
- yaml in yml

You may want to delete any of the above directories which your collection will not be using in order to declutter your data repository.

### Step 2:  Commit your changes to git and Github

The data repository's `.gitignore` file is set up to make sure that files in tei, dc, etc, are being tracked, but any generated files are not.  `git init` to create a new repository, add your files, and push to a remote!

TODO point at more specific directions later for this

[Looks like it's time to configure your new collection](config.md)

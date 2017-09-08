## Set up New API collection

### Step 1:  Create a new collection directory

Copy the example collection to a new directory with your collection's name:

```
cp -r collections/example collections/[your_collection]
```

If you want more information about the directory structure and included files, please see the [file system](../4_developers/file_structure.md) docs.

Compare the type of data you want to upload to the directory structure.  Remove any existing example files in these directories and add your own content:

- csvs and spreadsheets in `csv`
- Dublin Core in `dc`
- TEI XML in `tei`
- VRA Core in `vra`
- yaml in `yml`

Delete any directories you don't plan on using!  You can always add it back later, when you suddenly find a spreadsheet you have to upload!

### Step 2:  Commit your changes to git and Github

The data repository's `.gitignore` file is set up to make sure that files in tei, dc, etc, are being tracked, as well as the generated HTML (by environment), but any additional generated files are not.  `git init` to create a new repository, add your files, and push to a remote!

Use [GitHub's instructions (external link)](https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/) instructions, if you are not sure how to add a new repository.  You can change the address to look somewhere besides GitHub if you like.

[Looks like it's time to configure your new collection](config.md)

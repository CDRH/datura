## Set up New API collection

### Step 1:  Create a new collection directory

Install datura by creating a new directory with a `Gemfile` with
`gem "datura", git: 'https://github.com/CDRH/datura', branch: "dev"` 
Make a file `.ruby-version` with the ruby version required by Datura (currently 3.1.2).
Run `bundle install` and make sure Datura install successfulle.
Then run:

```
setup
```

This will create several directories, a .gitignore file, and a configuration file for your collection.

### Step 2:  Add your documents

In `source` you'll notice two directories: `tei` and `drafts`.  Any format stored at the base of `source` should be considered transformable, though you may choose not to post it to production indexes.  `drafts` contains files such as templates, invalid XML files, and anything else which is in such an in-progress state that it should be for human eyes only (and not the scripts).

Please organize any files you have for this collection in subdirectories in `source`:

```
- annotations
- authority
- csv
- dc
- tei
- vra
```

The `source/drafts` directory should be organized similarly for clarity's sake, but since no scripts pull information from it, feel free to organize it however makes the most sense for your collection!

### Step 3:  Commit your changes to git and Github

The collection's `.gitignore` file is set up to make sure that files in tei, dc, etc, are being tracked, as well as the generated HTML (by environment), but any additional generated files are not.  `git init` to create a new repository, add your files, and push to a remote!

Use [GitHub's instructions (external link)](https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/) instructions, if you are not sure how to add a new repository.  You can change the address to look somewhere besides GitHub if you like.

### What's next?

[Looks like it's time to configure your new collection!](config.md)

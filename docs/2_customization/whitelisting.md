## Whitelisting Files

Some projects may not want all files to post / create HTML for all environments. For example, you may not want some documents to display in production while you are still working heavily in the development site. Instead of using branches to manage files, you can instead whitelist specific files by production.

Add the following configuration to your collection's `public` config. Add it to default if this is going to be true across all environments, or add it to a specific environment.


```
environment:
  whitelist_txt: collections/[collection_name]/config/[some_name_about_allowed_files].txt
```

Now add a file at your selected location. Add files (without extensions!) like so:

```
cat.let0001
nei.personography
wfc.jrn.001.011
```

The files must each be on their own line.

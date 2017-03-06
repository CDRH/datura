# Cather Archive index update and HTML generation instructions

## Locations

### Temporary Rosie Dev instructions

Once everything is set up, you should use cathersites for populating the index, until then, follow these temporary instructions. 

Log into the server.

```
ssh YOUR_USER@cdrhdev1.unl.edu
 ```

Change directory to the data repo:

```
cd /var/local/www/data_es/
```

At this point, you can follow the directions in the next section, "pulling git updates."

### Cathersites

You will run all update scripts from cathersites. 

```
ssh YOUR_USER@cathersites.unl.edu
```
```
cd /var/local/www/data/
```

## Pulling Git Updates

If you have made any changes to the XML on your computer, you'll need to pull them to the server. 

Change directories to your project folder

```
cd projects/cather_letters
```

(where cather_letters is the folder containing the data repo you want to update)

```
git status
```

If all is clear, run

```
git pull
```

## Populating the index and generating HTML

In order to populate the TEI you just pulled, change directories back out of the project directory: 

```
cd ../..
```

This will put you back at the data repo folder. From there, you can run the update scripts. Full documentation of running the scripts is found in [update_project.md](update_project.md) and for clearing the index in [clear_index.md](clear_index.md), but I'll spell out a few commands you'll run frequently below.

### Posting Documents

To post all the documents in one data repo, run: 

```
ruby scripts/ruby/es_post.rb data_cather -e development -x es
```

to find out the options for this script run it with a -h flag. More documentation here: [update_project.md](update_project.md)

### Producing HTML

The above command only posts the data to the index. If you'd like to run the HTML in addition, you can remove the -x es

```
ruby scripts/ruby/es_post.rb data_cather -e development
```,

In the development version, I plan on using cocoon to generate the HTML, so this should only be necessary for production. 

(Note, I have not set this up yet, change instructions if we do not use cocoon) -KMD

### Clearing Documents

To clear *all* the cather docs, run: 

```
ruby scripts/ruby/es_clear_index.rb cather -e development
```

(development is the environment, and is what you should use until the site is ready to go live)

Note that this will clear the entire index, though!

If you only want to clear one file or a set of files you can run 

```
ruby scripts/ruby/es_clear_index.rb cather -r cat.bohlke -e development
```

To clear all files that start with the string provided. For more options, see the [clear_index.md](clear_index.md) doc. 

## Adding things to/changing the index

Your first step, if you have not already, is to read the [Customizing tei_to_es.rb](tei_to_es.rb) document. 




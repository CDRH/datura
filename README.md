CDRH Files central repo
======
This will be the test central repo for CDRH files, including TEI, dublin core, spreadsheets and other files. 

This file will also contain documentation for scripts which will aid in data creation and manipulation. 

##### Overview
- [The Process](#process_link)

##### Setting Up a New Project
- [Check Requirements](#req_intro)
- [Add a Core and Schema](#core)
- [Configure Directory](#proj_config)
- [Upload TEI](#tei)

##### Indexing (Adding) Data to Solr
- [Running the Script](#post)
- [Troubleshooting](#trouble_post)

##### Managing Your Solr Data
- [Management Script](#clear)
- [Troubleshooting](#trouble_clear)

##### Developer Guide
- [Setting up Solr / Tomcat](#solr_core)
- [Apache Directory Permissions](#apache)
- [Saxon Executable](#saxon)
- [Ruby / Gems](#ruby)
- [Running Tests](#tests)
- [Main Config](#main_config)


Overview
------
TODO

Setting up a New Project
------
##### <a name="req_intro"></a> Check Requirements
Before you start, you'll want to make sure that you have access to a solr instance.  Make sure that you have your project config file set up (see the section below on adding a project) and that the path to the solr instance is correct in the main config file (data/config/config.yml).  You'll also need to make sure that you can execute the saxon xsl transformer from the command line.  See the developer section at the bottom if you have any questions.  You will also need ruby installed.

##### <a name="core"></a> Adding a Core and Schema
Navigate in the server where your Solr cores are located.  You will either need to copy an existing directory or use an example core found here (TODO put in an example of our schema, etc).  TODO put in instructions for updating the name of the core and then adding it to the solr.xml file

##### <a name="proj_config"></a> Configure Directory
You will need to add a directory for your new project in this data repository.  Under projects/, run the following with your own project name subbed in:
```
mkdir -p project_name/{config,html-generated,tei}
```
You will need to add a config file for your new project in `projects/<project_name>/config/config.yml`.  You can grab an existing project's file from `projects/<other_project>/config/config.yml` or you can grab an example project config file from `data/config/proj_config.example.yml` and rename it.

You'll need to fill in the name of this project's solr core (not the url to it, but simply the core name), as well as any information about the parameters that will be passed into the xslt that are specific to this project.
- figures
- fw (form works)
- pb  (page breaks)

Depending on the data associated with your project, you may also need to create subfolders for vra/, dublin_core/, spreadsheets/ (csv files, etc), and scripts/.

##### <a href="tei"></a> Upload TEI

Assuming that you have p5 tei, you can upload it directly to the server into the `data/projects/project_name/tei` directory with scp, ftp, or whatever you preferred method is for file transfers.  Put any vra or dublin core files into those directories (not into the tei directory).

Indexing (Adding) Data to Solr
------
##### <a href="post"></a> Running the Script

If your scripts/ruby/post_to_solr.rb script is executable, then you may run it by simply typing `./scripts/ruby/post_to_solr.rb`.  Otherwise you can manually run it with `ruby scripts/ruby/post_to_solr.rb`.

You should be able to run it from anywhere inside the data repository, but it is recommend that you run it from the root of the directory.

You have several options for running it:
```
Usage: ruby post_to_solr.rb [project] -[options]...
    -h, --help                       Computer, display script options.
    -e, --environment [input]        Environment (test, production)
    -f, --format [input]             Restrict to one format (tei, csv, dublin-core)
    -n, --no-commit                  Post files to solr but do not commit
    -r, --regex [input]              Only post files matching this regex
    -t, --transform-only             Do not post to solr or erase tmp/
    -u, --update [2015-01-01T18:24]  Transform and post only new files
    -v, --verbose                    More messages and stacktraces than ever before!
```
- help => displays the above script
- environment => defaults to test if not specified
- format => will run everything if not specified. Use if you only want to post new vra files, etc.
- no-commit => Posts all your files but does not "save." You can then manually commit changes through solr web ui
- regex => Looks for the tei / vra / dc files matching that regex and posts only those
- transform-only => Generates html snippets from tei and creates solr ready files in the tmp/ directory, does not post
- update => Only uploads files that have been changed after given time. Can also accept date (YYYY-MM-DD)
- verbose => Gives you lots of messages. Recommended if you are experiencing an issue


It should look something like this if you want to post only tei to a production environment for a whitman project:
```
./scripts/ruby/post_to_solr.rb whitman -e production -f tei
```
You just added two files on Feb 26 but you don't want to rerun everything!
```
./scripts/ruby/post_to_solr.rb neihardt -u 2015-02-26 
```
You only want to add files related to Buffalo Bill Cody's books (example title: cody.book.001.xml)
```
./scripts/ruby/post_to_solr.rb cody -r book
```
You only want to add files with a specific regex (make sure to \ escape regex characters like .*[, etc)
```
./scripts/ruby/post_to_solr.rb cody -r \.book\.00[0-9]\.xml
```

##### <a href="trouble_post"></a> Troubleshooting

- Run it again with the -v flag so that you can see extra debug lines.
- Determine where the problem is occurring.  Is it happening when reading in files, transforming, or posting to solr?
- Make sure that all of your configuration information is correct, including those in the data/config/config.yml file
- Is your solr core set up to handle the api schema?
- Do you have correct permissions to run all of the files? Check that permissions / ownership was not changed on files (and that the tei / vra / dc are all readable)
- If you type "saxon" into the command line, does it find the command?  Make sure saxon can be executed from the command line
- Run the tests and make sure that various components are working on their own. This may hone in on specific issues.
- if ./command fails to work, try running it with `ruby command` instead, or point at a specific version of ruby before running the command


Managing Your Solr Data
------
##### <a href="clear"></a> Management Script
"Management" script is a bit misleading, as this script is just meant for straight up deleting things.  It will clear an entire solr core or it will look for specific entries to remove.
```
Usage: ruby clear_index.rb [project] -[options]...
    -h, --help                       Computer, display script options.
    -e, --environment [input]        Environment (test, production)
    -f, --field [input]              The specific field regex is run on
    -r, --regex [input]              Used as criteria for removing item (books.*, etc)
```
If you wanted to clear an entire test solr core, you would say something like this:
```
./scripts/ruby/clear_index.rb whitman
```
You would need to specify production if you really meant business:
```
./scripts/ruby/clear_index.rb whitman -e production
```
You could also search for only a specific id or group of ids to erase
```
./scripts/ruby/clear_index.rb cody -r txt\.001
```
If you want to erase items from the core by a specific field, use the field flag:
```
./scripts/ruby/clear_idex.rb transmississippi -f category -r memorabilia
```
##### <a href="trouble_clear"></a> Troubleshooting
- The config files will need to be filled out correctly for this script to run
- Remember that the -r flag is regex.  Entering something like .* will look for all characters multiple times, not something that literally as ".*" in the title.

Developer Guide
------
##### <a href="solr_core"></a> Setting up Solr / Tomcat

##### <a href="apache"></a> Apache Directory Permissions

##### <a href="saxon"></a> Saxon Executable
Install your preferred edition / version of saxon on the server and put it in a memorable place, such as `/var/lib/saxon/saxon9he.jar`, but it does not matter where it is as long as the location is accessible (not your home directory or a restricted directory).

Now go to the /usr/bin directory.  You'll be adding a script that essentially acts as an alias to run saxon.  Use a text editor running under sudo / root to create a new file in /usr/bin and make sure that you name it "saxon".  Add the following code to the file.

```
#!/bin/sh
# adapted from https://coderwall.com/p/ssuaxa/how-to-make-a-jar-file-linux-executable

echo "Running saxon"
THISFILE=`which "$0" 2>/dev/null`
[ $? -gt 0 -a -f "$0" ] && THISFILE="./$0"
java=java
if test -n "$JAVA_HOME"; then
    java="$JAVA_HOME/bin/java"
fi
# pass all of the arguments through to saxon $@
# you will need to update this path to reflect the location and name of your saxon jar file
exec "$java" -jar "/var/lib/saxon/saxon9he.jar" "$@"
exit 1
```
You will need to change the path in the second to last line to your own saxon jar.  Save, quit, and then change the permissions of your file to make it executable for anybody on the system.
```
sudo chmod +x name_of_command
```
Now you should be able to type your command into the terminal and it will pass all the parameters directly to the real saxon.  This saves you some typing and hardcoding in the long run.

##### <a href="ruby"></a> Ruby / Gems
Check your version of Ruby by typing `ruby -v`.  This project currently uses ruby 2.1.3.  If you have a different version installed on your machine, it is recommended to use rvm to use multiple versions of ruby without messing up the good thing you've already got going on.  https://rvm.io/

None of the libraries used in the ruby scripts require gems -- they are all built into Ruby.  If you want to run tests, however, you will need gems.  TODO

##### <a href="tests"></a> Running Tests

##### <a href="main_config"></a> Main Config


```
sudo chmod +x name_of_command
```

Now you should be able to type your command into the terminal and it will pass all the parameters directly to the real saxon.  This saves you some typing and hardcoding in the long run.

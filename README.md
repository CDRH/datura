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
This project seeks to create an API for the CDRH's TEI projects.  The information for each project is housed in the projects directory, while scripts to transform the documents and post them to solr are in the scripts directory.  TEI files are transformed into html snippets that can be easily displayed in pages and are also uploaded to a solr core, which can then be queried.

Setting up a New Project
------
##### <a name="req_intro"></a> Check Requirements
- Access to solr instance (write / push privileges)
- Set up project config file with project's solr core name
- Confirm solr url, xsl locations, in main config file are correct
- Command line access to saxon xsl transformer
- Ruby 2.1.3
- Apache server with exposed webtree
See the developer guide at the bottom of this readme for information about the above requirements

##### <a name="core"></a> Adding a Core and Schema

The following instructions are for Solr 4.  Solr 5 instructions will be coming shortly.

Navigate in the server where your Solr cores are located.  

Copy our example core (note, tested on Solr v. 4.10.1) from `/solr_example_files/api_projectName_test` to your solr cores folder. Alternately, you can copy existing files and use our schema ([/solr_example_files/api_projectName_test/conf/schema.xml](/solr_example_files/api_projectName_test/conf/schema.xml)) as a starting point. 

Name your folder appropriately, add your project name in your /core/projectName/conf/schema.xml file:

`<schema name="api_projectName_test" version="1.5">`
  
And add your new project to your solr.xml file. (Note, these instructions will change with subsequent versions of Solr)

Restart Solr, Tomcat, or other web container, and then check your install in the Solr web admin interface to make sure everything is configured correctly.

In case of permission errors, you may have to change group: 

`sudo chown -R tomcat api_projectName_test/`

and add write permissions

`sudo chmod -R g+w api_projectName_test/`

This is why creating the data structure from an existing config may be easier, those commands listed below just in case

`mkdir -p <project_name>/{bin,data,lib,conf/xslt}` and `cp -R <existing_project>/conf/* <project_name>/conf/`

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

##### <a name="tei"></a> Upload TEI

Assuming that you have p5 tei, you can upload it directly to the server into the `data/projects/project_name/tei` directory with scp, ftp, or whatever you preferred method is for file transfers.  Put any vra or dublin core files into those directories (not into the tei directory).

Indexing (Adding) Data to Solr
------
##### <a name="post"></a> Running the Script

TODO: Add a section explaining how to add an alternate indexing script

If your scripts/ruby/post_to_solr.rb script is executable, then you may run it by simply typing `./scripts/ruby/post_to_solr.rb`.  Otherwise you can manually run it with `ruby scripts/ruby/post_to_solr.rb`.

You should be able to run it from anywhere inside the data repository, but it is recommend that you run it from the root of the directory.

You have several options for running it:
```
Usage: ruby post_to_solr.rb [project] -[options]...
    -h, --help                       Computer, display script options.
    -e, --environment [input]        Environment (test, production)
    -f, --format [input]             Restrict to one format (tei, csv, dublin-core)
    -x, --html-only                  Will not generate solr snippets, only html
    -n, --no-commit                  Post files to solr but do not commit
    -r, --regex [input]              Only post files matching this regex
    -s, --solr-only                  Will not generate html snippets
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

##### <a name="trouble_post"></a> Troubleshooting

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
##### <a name="clear"></a> Management Script
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
##### <a name="trouble_clear"></a> Troubleshooting
- The config files will need to be filled out correctly for this script to run
- Remember that the -r flag is regex.  Entering something like .* will look for all characters multiple times, not something that literally as ".*" in the title.

Developer Guide
------
##### <a name="solr_core"></a> Setting up Solr / Tomcat
If you have access to the CDRH intranet, you can find instructions for setting up solr here:  http://libinfo.unl.edu/cdrh/index.php/Solr_Setup.  Otherwise, please refer to solr's documentation about running it as a tomcat webapp.  An example of the type of schema that the CDRH is using for this project can be found here:  TODO put in a link and a document example

##### <a name="apache"></a> Apache Directory Permissions
Assuming that you place this project in your web tree, you will need to take care to protect any sensitive information you place it in that you do not want to be accessible through the browser (copywritten material, drafts, passwords, etc).  To protect the configuration files that contain information about your solr instance, you should put these lines in your main apache configuration file.  If you have an older version of Apache, you may need to specify `Order deny,allow` and `Deny from all` instead of using `Require all denied`.
```
#
# Prevent config.yml files that might be in the webtree from being viewable
#
<FilesMatch ".*config\.yml">
    Require all denied
</FilesMatch>
```
Otherwise, you should not need to do anything with apache assuming that you already had it set up with a webtree.

##### <a name="saxon"></a> Saxon Executable
Install your preferred edition / version of saxon on the server and put it in a memorable place, such as `/var/lib/saxon/saxon9he.jar`, but it does not matter where it is as long as the location is accessible (not your home directory or a restricted directory).

Now go to the /usr/bin directory.  You'll be adding a script that essentially acts as an alias to run saxon.  Use a text editor running under sudo / root to create a new file in /usr/bin and make sure that you name it "saxon".  Add the following code to the file.  Make sure that there are no "echo" lines or anything that would output to stdout in the below script, if you try tinkering with it.

```
#!/bin/sh
# adapted from https://coderwall.com/p/ssuaxa/how-to-make-a-jar-file-linux-executable

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

##### <a name="ruby"></a> Ruby / Gems
Check your version of Ruby by typing `ruby -v`.  This project currently uses ruby 2.1.3.  If you have a different version installed on your machine, it is recommended to use rvm to use multiple versions of ruby without messing up the good thing you've already got going on.  https://rvm.io/

None of the libraries used in the ruby scripts require gems -- they are all built into Ruby.  If you want to run tests, however, you will need gems.  You'll need to consult the rvm documentation to see how to install gems for your particular setup (multi-user, single-user, etc), but if you want to just see what happens, run `bundle install`.  If rvm is set up correctly, it will install the rspec testing gem on your system.

##### <a name="tests"></a> Running Tests

Older tests are located in `test_old/ruby/lib_tests` currently.  Test fixtures are located at `test_old/ruby/fixtures` and include things like tei, files that can be "touched" to update their timestamp, and a tmp directory that will be filled and wiped by specific tests.  There are currently only tests for the helper functions, etc, so you would run tests as follows:

All tests:
```
rspec test_old/ruby/lib_tests/*
```
Specific group of tests (with documentation flag for a different progress reporter)
```
rspec test_old/ruby/lib_tests/transformer_test.rb --format documentation
```
At the end of the test run, you should see something like this:
```
Finished in 6.17 seconds (files took 0.57802 seconds to load)
47 examples, 0 failures, 9 pending
```
The pending ones are expected, as they just haven't been finished but those tests should be written in the future.  Failures are what you want to watch out for!

##### <a name="main_config"></a> Main Config

The main configuration file resides at `config/config.yml` and can be created by copying the config.example.yml file found in the config directory.  You will need to change the repo_directory path to reflect the location of the project from the root of your file system.  You can probably ignore the logging settings unless if you feel very strongly about the number of files that will be saved.  You will also need to give instructions for the location of your test and production solr instances.  Make sure that you end the solr urls with a /

##### <a name="executable"></a> Executing the Script
Assuming that `ruby -v` gives you the correct version of ruby for the ruby scripts, you may run the script with `ruby scripts/ruby/post_to_solr.rb`.  If you would like to run it as a command, however, then you will need to modify the file to be executable, if it has not already been.  post_to_solr.rb and clear_index.rb both have shebangs at the top of them describing the location of Ruby in the filesystem, but if this is incorrect for your system you will need to modify the shebangs to point at your location.  To make the file executable, type the following:

```
sudo chmod +x scripts/ruby/post_to_solr.rb
```

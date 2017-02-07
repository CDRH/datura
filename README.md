CDRH Files central repo
======

This project supports the population of an API storing data extracted from XML, CSV, YML, and other file types.

## The Process

Projects are added as sub repositories. They may contain data in the following formats: TEI P5, VRA, Dublin Core, CSV, and YML.  The following output formats are supported: HTML, Solr XML, Elasticsearch (ES) JSON.

The files are parsed and formatted into documents appropriate for Solr, Elasticsearch, and HTML snippets, and then these resulting documents are posted to the appropriate locations. There are also several management scripts for creating indexes, managing the schemas, and deleting indexes.

## The Basics

If this is a brand new project, please refer to [[TODO]] these docs on how to set up a project.

To run a basic development environment, give the following a try, subbing in your project name.

```
ruby scripts/ruby/post_es.rb <project>
```

Specify an environment to use. By default the script attempts to run "development"

```
ruby scripts/ruby/post_es.rb <project> -e production
```

Run a specific set of files identified by regex.

```ruby
ruby scripts/ruby/post_es.rb <project> -r "let.*"
==> cat.let.0001.xml
==> cat.let.0002.xml
```

More options:

- processing only specific types of files (TEI vs DC)
- running files updated since a given time
- outputting docs sent to Elasticsearch / Solr
- transforming but not posting files
- and more!

Check them out by running the "help" flag:

```
ruby scripts/ruby/post_es.rb -h
```

## More Documentation for Users and Devs

- Clearing data from an index
- Updating or adding to a project and the API
- Understanding the config files
- Writing and running tests

## More Documentation for Devs

- Installation and requirements to run this repo
- Setting up a new project
- Legacy tech and setup







## Set up Solr Project

Please refer to the instructions in the General wiki for instructions to set up projects which rely on Solr 6 + Cocoon / Rails.



##### <a name="trouble_post"></a> Troubleshooting

- Run it again with the -v flag so that you can see extra debug lines.
- Determine where the problem is occurring.  Is it happening when reading in files, transforming, or posting to solr?
- Make sure that all of your configuration information is correct, including those in the data/config/config.yml file
- Is your solr core set up to handle the api schema?
- Do you have correct permissions to run all of the files? Check that permissions / ownership was not changed on files (and that the tei / vra / dc are all readable)
- If you type "saxon" into the command line, does it find the command?  Make sure saxon can be executed from the command line
- Run the tests and make sure that various components are working on their own. This may hone in on specific issues.
- if ./command fails to work, try running it with `ruby command` instead, or point at a specific version of ruby before running the command



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



## CDRH Files central repo

This will be the test central repo for CDRH files, including TEI, dublin core, spreadsheets and other files. 

This file will also contain documentation for scripts which will aid in data creation and manipulation. 

### To Transform Files and Post Them to Solr

Make sure that you have your project config file set up (see the section below on adding a project) and that the path to the solr instance is correct in the main config file (data/config/config.yml).

Verify that saxon is installed as a command line argument (executed by typing "saxon" rather than as java -jar etc).  If it is not, then see below about how to install and run saxon as a command.

Check your version of Ruby by typing `ruby -v`.  This project currently uses ruby 2.1.3.  If you have a different version installed on your machine, it is recommended to use rvm to use multiple versions of ruby without messing up the good thing you've already got going on.  https://rvm.io/

If your scripts/ruby/post_to_solr.rb script is executable, then you may run it by simply typing `./scripts/ruby/post_to_solr.rb`.  Otherwise you can manually run it with `ruby scripts/ruby/post_to_solr.rb`.

You have several options for running it:
```
Usage: ruby post_to_solr.rb [project] -[options]...
    -h, --help                       Computer, display script options.
    -e, --environment [input]        Environment (test, production)
    -f, --format [input]             Restrict to one format (tei, csv, dublin-core)
    -n, --no-commit                  Post files to solr but do not commit
    -t, --transform-only             Do not post to solr
    -v, --verbose                    More messages and stacktraces than ever before!
```
It should look something like this if you want to post only tei to a production environment for a whitman project:
```
./post_to_solr.rb whitman -e production -f tei
```


### To Add A New Project

Execute the following command with the name of your project subbed in.

```
mkdir -p myProject/{config,html,tei}
```
Depending on the data associated with your project, you may also need to create subfolders for vra/, dublin_core/, spreadsheets/, and scripts/.

Copy the config.yml file from an existing project's config directory and update it with this project's solr core name.  Run these permissions so that the config file will not be accessible from the web.  If you have not created a new solr core for the project, now would be a great time before you run a script and start getting errors back!

```
sudo chown apache projects/[project_name]/config/config.yml
sudo chmod u-rwx projects/[project_name]/config/config.yml
```

### To set up Saxon command

Install your preferred edition / version of saxon on the server and put it in a memorable place, such as `/var/lib/saxon/saxon9he.jar`, but it does not matter where it is as long as the location is accessible (not your home directory or a restricted directory).

Now go to the /usr/bin directory.  You'll be adding a script that essentially acts as an alias to run saxon.  Use a text editor running under sudo / root to create a new file in /usr/bin and make sure that you name it something like "saxon" or "xslt" or something logical.  Ours is named "saxon".  Add the following code to the file.

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

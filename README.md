## CDRH Files central repo

This will be the test central repo for CDRH files, including TEI, dublin core, spreadsheets and other files. 

This file will also contain documentation for scripts which will aid in data creation and manipulation. 

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

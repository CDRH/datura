## Saxon Executable

Install your preferred edition / version of saxon (generally from http://www.saxonica.com - we use the Home Edition) on the server and put it in a memorable place, such as `/var/lib/saxon/saxon9he.jar` (`/usr/local/var/saxon` on mac), but it does not matter where it is as long as the location is accessible (not your home directory or a restricted directory).

Now go to the `/usr/bin` directory.  You'll be adding a script that essentially acts as an alias to run saxon.  Use a text editor running under sudo / root to create a new file in `/usr/bin` (`/usr/local/bin` on mac) and make sure that you name it "saxon".  Add the following code to the file.  Make sure that there are no "echo" lines or anything that would output to stdout in the below script, if you try tinkering with it.

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
Check your version of Ruby by typing `ruby -v`.  This collection currently uses ruby 2.1.3.  If you have a different version installed on your machine, it is recommended to use rvm to use multiple versions of ruby without messing up the good thing you've already got going on.  https://rvm.io/

None of the libraries used in the ruby scripts require gems -- they are all built into Ruby.  If you want to run tests, however, you will need gems.  You'll need to consult the rvm documentation to see how to install gems for your particular setup (multi-user, single-user, etc), but if you want to just see what happens, run `bundle install`.  If rvm is set up correctly, it will install the rspec testing gem on your system.

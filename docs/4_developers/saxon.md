**Contents**
- [Install System JAR](#install-system-jar)
- [Bash Executable](#bash-executable)
- [Reference](#reference)

A system Saxon JAR is used with scripting via a [Bash executable](#bash-executable)

## Install System JAR

Here is a reference for the Saxon version that various CDRH servers are using:

- whitman: 9.7.0.2J
- cdrh and cather: 9.6.0.4J

```bash
# Make directory named for the version:
sudo mkdir /usr/local/share/saxon-(version)

# Symlink to versioned directory for quick switching in the future
sudo ln -s /usr/local/share/saxon-(version) /usr/local/share/saxon
```

Copy the Saxon JAR file (e.g. `saxon9he.jar`) from another server with `scp` or `rsync`

or

Download Saxon-HE from [Saxonica Open Source](https://sourceforge.net/projects/saxon/files/Saxon-HE/)


## Bash Executable
This bash executable passes its arguments through to and runs the Saxon JAR

`sudo vim /usr/local/bin/saxon`:
```bash
#!/usr/bin/env bash

JAVA_BIN="$(which java)"
SAXON_JAR="/usr/local/share/saxon/saxon9he.jar"

# If JAVA_HOME is defined, call java from ENV-based path
if [[ -n "${JAVA_HOME}" ]]; then
  JAVA_BIN="${JAVA_HOME}/bin/java"
fi

# Pass all bash arguments ($@) through to the Saxon JAR
exec "${JAVA_BIN}" -jar "${SAXON_JAR}" "$@"

# Exit with an error status if the exec shell exits back to this script
exit 1
```

Add the executable permission to the Bash script:<br>
`sudo chmod +x /usr/local/bin/saxon`

If you locate your Saxon JAR somewhere other than `/usr/local/share/saxon/saxon9he.jar`, make sure to update the path stored in the `SAXON_JAR` variable at the top of the script.

Now you and others may run `saxon (arguments)` from anywhere on your system to save typing and run Saxon within scripts.


## Reference
- Download / Support Info: http://saxonica.com/download/opensource.xml
- Release Announcements: https://saxonica.plan.io/news/1
- Bug Fixes: In release(version #).txt file on [SourceForge](https://sourceforge.net/projects/saxon/files/Saxon-HE/)
- Change Info: http://www.saxonica.com/documentation/#!changes/serialization/9.2-9.3
- Issues: https://saxonica.plan.io/projects/saxon/issues

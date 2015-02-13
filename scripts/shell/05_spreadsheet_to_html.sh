#!/bin/sh

#clear

PROJECTNAME=$1

if  [ $PROJECTNAME ]; then

  FILELOCATION=("/var/www/html/data/projects/"$PROJECTNAME"/spreadsheets/xml/")
  XSLTLOCATION=("/var/www/html/data/projects/"$PROJECTNAME"/spreadsheets/scripts/csvXML2HTML.xsl")
  #OUTPUT=("/var/www/html/data/projects/"$PROJECTNAME"/html/")

  for i in `ls $FILELOCATION`; do

  echo "Now converting ${i} "
	
	#java -jar /var/lib/saxon/saxon9he.jar $FILELOCATION${i} $XSLTLOCATION > $OUTPUT${i}
  java -jar /var/lib/saxon/saxon9he.jar -ext:on $FILELOCATION${i} $XSLTLOCATION
 
  done; 

  echo "Done. "
  
else

  echo "Please enter project e.g. scriptname.sh projectname"
  
fi
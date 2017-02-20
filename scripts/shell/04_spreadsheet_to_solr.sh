#!/usr/bin/env sh

#clear

PROJECTNAME=$1

if  [ $PROJECTNAME ]; then

  CSVXMLPATH=("/var/www/html/data/projects/"$PROJECTNAME"/spreadsheets/xml/")
  XSLTLOCATION=("/var/www/html/data/projects/"$PROJECTNAME"/scripts/csvXML2solr.xsl")
  OUTPUT=("/var/www/html/data/solr/"$PROJECTNAME"/")

  for i in `ls $CSVXMLPATH`; do

  echo "Now converting ${i} "
	
  java -jar /var/lib/saxon/saxon9he.jar $CSVXMLPATH${i} $XSLTLOCATION > $OUTPUT${i}
 
  done; 

  echo "Done. "
  
else

  echo "Please enter project e.g. scriptname.sh projectname"
  
fi

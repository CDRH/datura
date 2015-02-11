#!/bin/sh

#clear

PROJECTNAME=$1

if  [ $PROJECTNAME ]; then

  CSVXMLPATH=("/var/www/html/data/projects/"$PROJECTNAME"/spreadsheets/xml/")
  SOLRFILELOCATION=("/var/www/html/data/solr/"$PROJECTNAME"/")
  XSLTLOCATION=("/var/www/html/data/scripts/xslt/cdrh_csv_solr_to_html/solr_xml_to_html.xsl")
  OUTPUT=("/var/www/html/data/projects/"$PROJECTNAME"/html/")

  for i in `ls $CSVXMLPATH`; do

  echo "Now converting ${i} "
	
  java -jar /var/lib/saxon/saxon9he.jar $SOLRFILELOCATION${i} $XSLTLOCATION > $OUTPUT${i}
 
  done; 

  echo "Done. "
  
else

  echo "Please enter project e.g. scriptname.sh projectname"
  
fi
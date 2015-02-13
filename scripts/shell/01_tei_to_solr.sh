#!/bin/sh

#clear

PROJECTNAME=$1

if  [ $PROJECTNAME ]; then

  TEIPATH=("/var/www/html/data/projects/"$PROJECTNAME"/tei/")
  XSLTLOCATION="/var/www/html/data/scripts/xslt/cdrh_to_solr/solr_transform_tei.xsl"
  OUTPUT=("/var/www/html/data/solr/"$PROJECTNAME"/")

  for i in `ls $TEIPATH`; do

  echo "Now converting ${i} "
	
  java -jar /var/lib/saxon/saxon9he.jar $TEIPATH${i} $XSLTLOCATION > $OUTPUT${i}
 
  done; 

  echo "Done. "
  
else

  echo "Please enter project e.g. scriptname.sh projectname"
  
fi

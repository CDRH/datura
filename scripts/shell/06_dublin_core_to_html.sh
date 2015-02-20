#!/bin/sh

#clear

PROJECTNAME=$1

if  [ $PROJECTNAME ]; then

  FILELOCATION=("/var/www/html/data/projects/"$PROJECTNAME"/dublin_core/")
  XSLTLOCATION=("/var/www/html/data/scripts/xslt/cdrh_dc_to_html/dublin_core_to_html.xsl")
  #OUTPUT=("/var/www/html/data/projects/"$PROJECTNAME"/html-generated/")

  for i in `ls $FILELOCATION`; do

  echo "Now converting ${i} "
	
	#java -jar /var/lib/saxon/saxon9he.jar $FILELOCATION${i} $XSLTLOCATION > $OUTPUT${i}
  java -jar /var/lib/saxon/saxon9he.jar -ext:on $FILELOCATION${i} $XSLTLOCATION
 
  done; 

  echo "Done. "
  
else

  echo "Please enter project e.g. scriptname.sh projectname"
  
fi
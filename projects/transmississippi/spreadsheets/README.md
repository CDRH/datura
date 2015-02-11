I used this website to convert the csv to xml:

http://www.convertcsv.com/csv-to-xml.htm

The commands I used for XML -> Solr conversion

 java -jar ../../../scripts/lib/saxon/saxon9he.jar Jeffrey_Spencer_Collection_Index.xml csvXML2solr.xsl > ../../solr/spencer.xml

 java -jar ../../../scripts/lib/saxon/saxon9he.jar Memorabilia.xml csvXML2solr.xsl > ../../solr/memorabilia.xml

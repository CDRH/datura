## Shell scripts

### 01_tei_to_solr.sh

Converts TEI to SOLR using xslt/cdrh_to_solr/solr_transform.xsl

### 02_tei_to_html.sh

Converts TEI to HTML snippits using xslt/cdrh_tei_to_html/tei.p5.xsl

### 03_spreadsheet_to_json_and_xml.sh

Placeholder for script to convert csv to json and/or xml

### 04_spreadsheet_to_solr.sh

Currently takes csv xml and converts to solr ingest XML format.

### 05_spreadsheet_to_html.sh

Uses the solr ingest XML format (rather than the CSV XML because it's been standardized) to create an HTML snippit for CSV info. 

### TODO

Add other scripts to handle dublin core (cody) and any other formats

Add script to index into solr
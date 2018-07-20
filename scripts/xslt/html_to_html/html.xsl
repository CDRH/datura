<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/">
  <xsl:output indent="yes" omit-xml-declaration="yes"/>
  
  <!-- <xsl:param name="slug"/> -->

 
  <xsl:template match="/" exclude-result-prefixes="#all">

    <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
    <!-- The part of the url after the main document structure and before the filename. 
      Collected so we can link to files, even if they are nested, i.e. whitmanarchive/manuscripts -->
    
    <!-- Split the filename using '\.' -->
    <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
    <xsl:copy-of select="//body"/>
  </xsl:template>

</xsl:stylesheet>

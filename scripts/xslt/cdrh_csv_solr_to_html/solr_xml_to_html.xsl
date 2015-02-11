<?xml version="1.0"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace=""
  version="2.0"
  exclude-result-prefixes="xsl tei xs">
 
  
  <xsl:output method="xhtml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
  
<xsl:template match="doc">
  
  <div class="main_content">
    <xsl:value-of select="field[@name='description']"></xsl:value-of>
  </div>
  
  
  
</xsl:template>
 
  
</xsl:stylesheet>

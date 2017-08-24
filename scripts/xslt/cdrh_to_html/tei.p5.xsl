<?xml version="1.0"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0"
  exclude-result-prefixes="xsl tei xs">

<!-- ==================================================================== -->
<!--                             IMPORTS                                  -->
<!-- ==================================================================== -->

<xsl:import href="lib/html_formatting.xsl"/>
<xsl:import href="lib/personography_encyclopedia.xsl"/>
<xsl:import href="lib/cdrh.xsl"/>
<!-- If this file is living in a collections directory, the paths will be
     ../../../scripts/xslt/cdrh_tei_to_html/lib/html_formatting.xsl -->

<!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>


<!-- ==================================================================== -->
<!--                           PARAMETERS                                 -->
<!-- ==================================================================== -->

<xsl:param name="figures">true</xsl:param>  <!-- true/false Toggle figures on and off  -->
<xsl:param name="fw">true</xsl:param>       <!-- true/false Toggle fw's on and off  -->
<xsl:param name="pb">true</xsl:param>       <!-- true/false Toggle pb's on and off  -->
<xsl:param name="site_url"/>                <!-- the site url (http://codyarchive.org) -->
<xsl:param name="fig_location"></xsl:param> <!-- set figure location  -->

<!-- ==================================================================== -->
<!--                            OVERRIDES                                 -->
<!-- ==================================================================== -->

<!-- Individual collections can override matched templates from the
     imported stylesheets above by including new templates here -->
<!-- Named templates can be overridden if included in matched templates
     here.  You cannot call a named template from directly within the stylesheet tag
     but you can redefine one here to be called by an imported template -->

    <!-- The below will override the entire text matching template -->
    <!-- <xsl:template match="text">
      <xsl:call-template name="fake_template"/>
    </xsl:template> -->

    <!-- The below will override templates with the same name -->
    <!-- <xsl:template name="fake_template">
      This fake template would override fake_template if it was defined
      in one of the imported files
    </xsl:template> -->
</xsl:stylesheet>

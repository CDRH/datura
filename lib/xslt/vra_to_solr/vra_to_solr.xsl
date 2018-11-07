<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:vra="http://www.vraweb.org/vracore4.htm"
	xpath-default-namespace="http://www.vraweb.org/vracore4.htm"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<!-- ==================================================================== -->
	<!--                               IMPORTS                                -->
	<!-- ==================================================================== -->
	
	<xsl:import href="../common.xsl"/>
	<xsl:import href="lib/fields.xsl"/>

  <!-- To override, copy this file into your collection's script directory
      and change the above paths to:
      "../../.xslt/vra_to_solr/lib/fields.xsl"
  -->

	<xsl:output indent="yes" omit-xml-declaration="yes"/>
	
	<!-- ==================================================================== -->
	<!--                           PARAMETERS                                 -->
	<!-- ==================================================================== -->
	
  <xsl:param name="collection"/>
  <xsl:param name="data_base"/>
  <xsl:param name="environment">production</xsl:param>
  <xsl:param name="media_base"/>
	<xsl:param name="slug"/>          <!-- slug of collection -->
	<xsl:param name="site_url"/>
	


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
	
	
	<!-- Uncomment this to prevent personography behavior -->
	<!-- <xsl:template name="personography"/> -->
	
	<!-- Uncomment this and fill it in with your own fields
       this will not affect the personography solr entries -->
	<!-- <xsl:template name="extras">
    <field name="new_field_s">Your thing here</field>
  </xsl:template> -->


</xsl:stylesheet>

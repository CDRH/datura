<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:output indent="yes" omit-xml-declaration="yes"/>

	<xsl:param name="date"/>
	<xsl:param name="string"/>
	<xsl:include href="lib/common.xsl"/>
	
	<xsl:include href="solr_transform_tei.xsl"/>
	<!--<xsl:include href="solr_transform_vra.xsl"/>-->
	<xsl:include href="solr_transform_dc.xsl"/>

	<xsl:template match="/">
		<!-- Get the filename -->
		
		
		<xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
		
		<!-- The part of the url after the main document structure and before the filename. 
			Collected so we can link to files, even if they are nested, i.e. whitmanarchive/manuscripts -->
		<xsl:variable name="slug" select="substring-before(substring-before(substring-after(base-uri(.),'xml/documents/'),$filename),'/')"/>
		
		<!-- Split the filename using '\.' -->
		<xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
		
		<!-- check the following: 
		     root is TEI (excluding any other XML files
		-->
		
		<xsl:choose>
			<xsl:when test="/TEI">
				<xsl:call-template name="tei_template">
					<xsl:with-param name="filenamepart" select="$filenamepart"/>
					<xsl:with-param name="slug" select="$slug"/>
				</xsl:call-template>
			</xsl:when>
			
			
			<xsl:when test="/rdf:RDF">
				<xsl:call-template name="dc_template">
					<xsl:with-param name="filenamepart" select="$filenamepart"/>
					<xsl:with-param name="slug" select="$slug"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
		
		

	</xsl:template>
	
	
	


</xsl:stylesheet>

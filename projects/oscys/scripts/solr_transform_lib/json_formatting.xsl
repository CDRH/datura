<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:output indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:include href="../../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"/>
	
	<!-- ==================================
	Basic JSON Formatting 
	=================================== -->
	

	
	<!-- For formatting things in json format -->
	
	<xsl:template name="JSON_Formatter">
		<xsl:param name="json_label"/>
		<xsl:param name="json_date"/>
		<xsl:param name="json_id"/>
		<xsl:text>{</xsl:text>
		
		<!-- Label -->
		<xsl:if test="$json_label != ''">
			<xsl:text>"label":"</xsl:text>
			<xsl:call-template name="escape-string"><xsl:with-param name="s" select="$json_label"/></xsl:call-template>
			<xsl:text>"</xsl:text>
		</xsl:if>
		
		<!-- Date -->
		<xsl:if test="$json_date != ''">
			<xsl:if test="$json_label != ''">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:text>"date":"</xsl:text>
			<xsl:call-template name="escape-string"><xsl:with-param name="s" select="$json_date"/></xsl:call-template>
			<xsl:text>"</xsl:text>
		</xsl:if>
		
		
		<!--<xsl:call-template name="extractDate">
			<xsl:with-param name="date"
				select="$doc_date"/>
		</xsl:call-template>-->
		
		<!-- DateDisplay -->
		<xsl:if test="$json_date != ''">
			
				<xsl:text>,</xsl:text>
			
			<xsl:text>"dateDisplay":"</xsl:text>
			<xsl:call-template name="escape-string">
				<xsl:with-param name="s">
					<xsl:call-template name="extractDate"><xsl:with-param name="date" select="$json_date"/></xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:text>"</xsl:text>
		</xsl:if>
		
		<!-- ID -->
		<xsl:if test="$json_id != ''">
			<xsl:if test="$json_label != '' or $json_date != ''">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:text>"id":"</xsl:text>
			<xsl:call-template name="escape-string"><xsl:with-param name="s" select="$json_id"/></xsl:call-template>
			<xsl:text>"</xsl:text>
		</xsl:if>
		
		<xsl:text>}</xsl:text>
		
		
	</xsl:template>
	
	

	<!-- ==================================
	JSON Text Formatting 
	=================================== -->

<!-- Call this for formatting JSON
	
	from: https://github.com/doekman/xml2json-xslt/blob/master/xml2json.xslt
	
	<xsl:call-template name="escape-string">
			<xsl:with-param name="s" select="."/>
		</xsl:call-template>
	
	-->

	
	<!-- Main template for escaping strings; used by above template and for object-properties 
       Responsibilities: placed quotes around string, and chain up to next filter, escape-bs-string -->
	<xsl:template name="escape-string">
		<xsl:param name="s"/>
		<xsl:text></xsl:text>
		<xsl:call-template name="escape-bs-string">
			<xsl:with-param name="s" select="$s"/>
		</xsl:call-template>
		<xsl:text></xsl:text>
	</xsl:template>
	
	<!-- Escape the backslash (\) before everything else. -->
	<xsl:template name="escape-bs-string">
		<xsl:param name="s"/>
		<xsl:choose>
			<xsl:when test="contains($s,'\')">
				<xsl:call-template name="escape-quot-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/>
				</xsl:call-template>
				<xsl:call-template name="escape-bs-string">
					<xsl:with-param name="s" select="substring-after($s,'\')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escape-quot-string">
					<xsl:with-param name="s" select="$s"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Escape the double quote ("). -->
	<xsl:template name="escape-quot-string">
		<xsl:param name="s"/>
		<xsl:choose>
			<xsl:when test="contains($s,'&quot;')">
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/>
				</xsl:call-template>
				<xsl:call-template name="escape-quot-string">
					<xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="$s"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Replace tab, line feed and/or carriage return by its matching escape code. Can't escape backslash
       or double quote here, because they don't replace characters (&#x0; becomes \t), but they prefix 
       characters (\ becomes \\). Besides, backslash should be seperate anyway, because it should be 
       processed first. This function can't do that. -->
	<xsl:template name="encode-string">
		<xsl:param name="s"/>
		<xsl:choose>
			<!-- tab -->
			<xsl:when test="contains($s,'&#x9;')">
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'\t',substring-after($s,'&#x9;'))"/>
				</xsl:call-template>
			</xsl:when>
			<!-- line feed -->
			<xsl:when test="contains($s,'&#xA;')">
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'\n',substring-after($s,'&#xA;'))"/>
				</xsl:call-template>
			</xsl:when>
			<!-- carriage return -->
			<xsl:when test="contains($s,'&#xD;')">
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'\r',substring-after($s,'&#xD;'))"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>

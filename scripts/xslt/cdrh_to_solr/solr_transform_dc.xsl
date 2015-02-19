<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:output indent="yes" omit-xml-declaration="yes"/>
	
	
	<xsl:param name="date"/>
	<xsl:param name="string"/>
	<xsl:param name="site_location">http://rosie.unl.edu/transmississippi/</xsl:param>
	<xsl:param name="file_location">http://rosie.unl.edu/data/projects/</xsl:param>
	<xsl:include href="lib/common.xsl"/>
	
	<xsl:template match="/" exclude-result-prefixes="#all">
		
		<xsl:value-of select="$test"></xsl:value-of>
		
		<xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
		<!-- The part of the url after the main document structure and before the filename. 
			Collected so we can link to files, even if they are nested, i.e. whitmanarchive/manuscripts -->
		<xsl:variable name="slug" select="substring-before(substring-before(substring-after(base-uri(.),'data/projects/'),$filename),'/')"/>
		
		<!-- Split the filename using '\.' -->
		<xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
		
		<!-- Set file type, based on containing folder -->
		<!--<xsl:variable name="type">
			<xsl:variable name="path">
				<xsl:text>data/projects/</xsl:text>
				<xsl:value-of select="$slug"></xsl:value-of>
				<xsl:text>/</xsl:text>
			</xsl:variable>
			<xsl:value-of select="substring-before(substring-before(substring-after(base-uri(.),$path),$filename), '/')"/>
		</xsl:variable>-->
		
		
		<xsl:call-template name="dc_template">
			<xsl:with-param name="filenamepart" select="$filenamepart"/>
			<xsl:with-param name="slug" select="$slug"/>
		</xsl:call-template>
		
	</xsl:template>
	
	


	<xsl:template name="dc_template" xpath-default-namespace="" exclude-result-prefixes="#all">
		<xsl:param name="filenamepart"/>
		<xsl:param name="slug"/>
		
		
		<add>
			<xsl:for-each select="rdf:RDF/rdf:Description">
				<doc>
					
					<!-- ==============================
					resource identification 
					===================================-->
					
					<!-- id -->
					
					<field name="id">
						<xsl:value-of select="@about"/>
					</field>
					
					<!-- slug -->
					
					<field name="slug">
						<xsl:value-of select="$slug"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$filenamepart"/>
						<xsl:text>.xml</xsl:text>
					</field>
					
					<!-- project -->
					
					<field name="project">
						<xsl:if test="starts-with($filenamepart, 'wfc')">
							<xsl:text>The William F. Cody Archive</xsl:text>
						</xsl:if>
					</field>
					
					<!-- uri -->
					<!-- uriXML -->
					<!-- uriHTML -->
					<!-- dataType --> <!-- tei, dublin_core, csv, vra_core -->
					
					
					
					<!-- ==============================
					Dublin Core 
					===================================-->
					
					<!-- title -->
					
					<field name="title">
						<xsl:value-of select="dc:title"/>
					</field>
					
					<!-- titleSort -->
					
					<field name="titleSort">
						<xsl:call-template name="normalize_name">
							<xsl:with-param name="string">
								<xsl:value-of select="dc:title"/>
							</xsl:with-param>
						</xsl:call-template>
					</field>
					
					<!-- creator -->
					
					<field name="creator">
						<xsl:value-of select="dc:creator"/>
					</field>
					
					<!-- creators -->
					<!-- subject -->
					<!-- subjects -->
					<!-- description -->
					
					<xsl:if test="dc:description != ''">
						<field name="text">
							<xsl:value-of select="dc:description"/>
							
						</field>
					</xsl:if>
					
					<!-- publisher -->
					<!-- contributor -->
					<!-- contributors -->
					<!-- date -->
					
					<xsl:choose>
						<xsl:when test="normalize-space(dc:date) = ''"><!-- do nothing, empty--></xsl:when>
						<xsl:when test="contains(dc:date, 'circa')">
							<field name="date">
								<xsl:choose>
									<xsl:when test="contains(dc:date, 'circa ')">
										<xsl:call-template name="date_standardize">
											<xsl:with-param name="datebefore"><xsl:value-of select="substring(substring-after(dc:date, 'circa '), 1,4)"/></xsl:with-param>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="date_standardize">
											<xsl:with-param name="datebefore"><xsl:value-of select="substring(substring-after(dc:date, 'circa'), 1,4)"/></xsl:with-param>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>T01:00:00Z</xsl:text>
								
							</field>
						</xsl:when>
						<xsl:when test="string-length(dc:date) = 4">
							<field name="date">
								<xsl:value-of select="dc:date"/>
								<xsl:text>-01-02</xsl:text>
								<xsl:text>T02:00:00Z</xsl:text>
							</field>
						</xsl:when>
						<xsl:when test="translate(dc:date, '1234567890-', '') = ''">
							<field name="date">
								<xsl:call-template name="date_standardize">
									<xsl:with-param name="datebefore"><xsl:value-of select="substring(dc:date,1,4)"/></xsl:with-param>
								</xsl:call-template>
								<xsl:text>T00:00:00Z</xsl:text>
							</field>
						</xsl:when>
						<xsl:otherwise><!-- blank for no date --></xsl:otherwise>
					</xsl:choose>
					
					<!-- dateDisplay -->
					
					<field name="dateDisplay">
						<xsl:choose>
							<xsl:when test="contains(dc:date, 'circa')">
								<xsl:value-of select="dc:date"/>
							</xsl:when>
							<xsl:when test="string-length(dc:date) = 4">
								<xsl:value-of select="dc:date"/>
							</xsl:when>
							<xsl:when test="translate(dc:date, '1234567890-', '') = ''">
								<xsl:call-template name="extractDate">
									<xsl:with-param name="date"
										select="dc:date"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise><!-- blank for no date --></xsl:otherwise>
						</xsl:choose>
					</field>
					
					<!-- type -->
					<!-- format -->
					
					<field name="format">
						<xsl:text>image</xsl:text>
					</field>
					
					<!-- medium -->
					<!-- extent -->
					<!-- language -->
					<!-- relation -->
					<!-- coverage -->
					<!-- source -->
					
					<field name="source">
						<xsl:value-of select="dc:source"/>
					</field>
					
					<!-- rightsHolder -->
					<!-- rights -->
					
					<field name="sourceURI">
						<xsl:value-of select="dc:rights"/>
					</field>
					
					<!-- rightsURI -->
					
					
					<!-- ==============================
					Other Elements 
					===================================-->
					
					<!-- principalInvestigator -->
					<!-- principalInvestigators -->
					<!-- place -->
					<!-- placeName -->
					
					
					<!-- ==============================
					CDRH specific 
					===================================-->
					
					<!-- category -->
					
					<field name="category">
						<xsl:text>images</xsl:text>
					</field>
					
					<!-- subCategory -->
					
					<field name="subCategory">
						<xsl:value-of select="substring-after($filenamepart, 'wfc.')"></xsl:value-of>
					</field>
					
					<!-- topic -->
					
					<xsl:for-each select="dc:subject">
						<xsl:if test=". != ''">
							<field name="keywords">
								<xsl:apply-templates/>
							</field>
						</xsl:if>
					</xsl:for-each>
					
					<!-- keywords -->
					<!-- people -->
					<!-- places -->
					<!-- works -->
					
					
					<!-- ==============================
					Project specific 
					===================================-->
					
					<!-- datesExact_dts -->
					
					<xsl:choose>
						<!-- Only have an exact date when document has an exact date. Used when pulling documents from a certain date -->
						<xsl:when test="translate(dc:date, '1234567890-', '') = '' and string-length(dc:date) = 10">
							<field name="datesExact_dts">
								<xsl:call-template name="date_standardize">
									<xsl:with-param name="datebefore"><xsl:value-of select="dc:date"/></xsl:with-param>
								</xsl:call-template>
								<xsl:text>T00:00:00Z</xsl:text>
							</field>
						</xsl:when>
						<xsl:otherwise><!-- blank for no date --></xsl:otherwise>
					</xsl:choose>
						
					
					
					
					
					
				</doc>
			</xsl:for-each>
		</add>
	</xsl:template>
	
	


</xsl:stylesheet>

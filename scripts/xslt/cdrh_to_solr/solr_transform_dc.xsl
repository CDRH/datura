<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:output indent="yes" omit-xml-declaration="yes"/>


	<xsl:template name="dc_template" xpath-default-namespace="" exclude-result-prefixes="#all">
		<xsl:param name="filenamepart"/>
		<xsl:param name="slug"/>
		
		
		<add>
			<xsl:for-each select="rdf:RDF/rdf:Description">
				<doc>
					
					<field name="id">
						<xsl:value-of select="@about"/>
					</field>
					
					<field name="slug">
						<xsl:value-of select="$slug"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$filenamepart"/>
						<xsl:text>.xml</xsl:text>
					</field>
					
					<field name="title">
						<xsl:value-of select="dc:title"/>
					</field>
					
					<field name="titleSort">
						<xsl:call-template name="normalize_name">
							<xsl:with-param name="string">
								<xsl:value-of select="dc:title"/>
							</xsl:with-param>
						</xsl:call-template>
					</field>
					
					<field name="creator">
						<xsl:value-of select="dc:creator"/>
					</field>
					
					<!--<field name="creators"/>-->
					<!--<field name="publisher"/>-->
					<!--<field name="contributor"/>-->
					<!--<field name="contributors"/>-->
					
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
						
					
					
					<!-- datesExact - a multivalued field for matching exact dates: 
						i.e. pulling all the things that happened on a certain date -->

					<xsl:choose>
						<!-- Only have an exact date when document has an exact date. Used when pulling documents from a certain date -->
						<xsl:when test="translate(dc:date, '1234567890-', '') = '' and string-length(dc:date) = 10">
							<field name="datesExact">
								<xsl:call-template name="date_standardize">
									<xsl:with-param name="datebefore"><xsl:value-of select="dc:date"/></xsl:with-param>
								</xsl:call-template>
								<xsl:text>T00:00:00Z</xsl:text>
							</field>
						</xsl:when>
						<xsl:otherwise><!-- blank for no date --></xsl:otherwise>
					</xsl:choose>
						

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
					
					<!-- format -->
					
					<field name="format">
						<xsl:text>image</xsl:text>
					</field>
					
					<field name="source">
						<xsl:value-of select="dc:source"/>
					</field>
					
					<field name="sourceURI">
						<xsl:value-of select="dc:rights"/>
					</field>
					
					<field name="related">
						<xsl:if test="starts-with($filenamepart, 'wfc')">
							<xsl:text>The William F. Cody Archive</xsl:text>
						</xsl:if>
					</field>
					
					<!-- projectInvestigator -->
					<!-- projectInvestigators -->
					
					<field name="category">
						<xsl:text>images</xsl:text>
					</field>
					
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
					
					<!-- people -->
					<!-- places -->
					<!-- works -->
					
					<xsl:if test="dc:description != ''">
						<field name="text">
							<xsl:value-of select="dc:description"/>
							
						</field>
					</xsl:if>
					
				</doc>
			</xsl:for-each>
		</add>
	</xsl:template>
	
	


</xsl:stylesheet>

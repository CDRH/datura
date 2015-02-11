<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:output indent="yes" omit-xml-declaration="yes"/>

	<xsl:param name="date"/>
	<xsl:param name="string"/>
	<xsl:include href="lib/common.xsl"/>

	<xsl:template match="/">
		<!-- Get the filename -->
		<xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
		
		<!-- Split the filename using '\.' -->
		<xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
		
		<!-- check the following: 
		     root is TEI (excluding any other XML files
		-->
		
		<xsl:if test="/TEI">
		
		<add>
			<doc>
				<field name="id">
					<xsl:value-of select="$filenamepart"/>
				</field>
				
				<field name="title">
					<xsl:choose>
						<xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']">
							<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'][1]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</field>
				
				<!-- alternate title, used for display and sorting purposes -->

				<field name="titleSort">
					<xsl:call-template name="normalize_name">
						<xsl:with-param name="string">
									<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']"/>
						</xsl:with-param>
					</xsl:call-template>
				</field>
				
				<!-- Creators -->
				<xsl:choose>
					<!-- When handled in header -->
					<xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/author != ''">
						<!-- All in one field -->
						<field name="creator">
							<xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author">
								<xsl:value-of select="normalize-space(.)"/>
								<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
							</xsl:for-each>
						</field>
						<!-- Individual fields -->
						
						<xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author">
							<field name="creators">
								<xsl:value-of select="."></xsl:value-of>
							</field>
						</xsl:for-each>
						
						
					</xsl:when>
					
					<!-- When handled in document -->
					<xsl:when test="//persName[@type = 'author']">
						<!-- All in one field -->
						<field name="creator">
							<xsl:for-each-group select="//persName[@type = 'author']" group-by="substring-after(@key,'#')">
								<xsl:sort select="substring-after(@key,'#')"/>
								<xsl:value-of select="current-grouping-key()"/>
								<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
							</xsl:for-each-group>
						</field>
						<!-- Individual fields -->
						<xsl:for-each-group select="//persName[@type = 'author']" group-by="substring-after(@key,'#')">
							<field name="creators">
								<xsl:value-of select="current-grouping-key()"></xsl:value-of>
							</field>
						</xsl:for-each-group>
					</xsl:when>

					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
				
				
				<!-- publisher -->
				
				<xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1] and /TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1] != ''">
					<field name="publisher">
						<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]"></xsl:value-of>
					</field>
				</xsl:if>
				
				<!-- contributors -->
				
				<!-- All in one field -->
				<field name="contributor">
					<xsl:for-each-group select="/TEI/teiHeader/revisionDesc/change/name" group-by=".">
						<xsl:sort select="."/>
						<xsl:value-of select="current-grouping-key()"/>
						<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
					</xsl:for-each-group>
				</field>
				<!-- Individual fields -->
				<xsl:for-each-group select="/TEI/teiHeader/revisionDesc/change/name" group-by=".">
					<field name="contributors">
						<xsl:value-of select="current-grouping-key()"></xsl:value-of>
					</field>
				</xsl:for-each-group>
				
				
				<!-- date -->
				
				
				
				<xsl:if test="/TEI/teiHeaderfileDesc/sourceDesc/bibl/date/@when">
					<xsl:variable name="doc_date">
						<xsl:value-of select="/TEI/teiHeaderfileDesc/sourceDesc/bibl/date/@when"/>
					</xsl:variable>
					
					<field name="date">
						<xsl:call-template name="date_standardize">
							<xsl:with-param name="datebefore"><xsl:value-of select="substring($doc_date,1,10)"/></xsl:with-param>
						</xsl:call-template>
						
						<xsl:text>T00:00:00Z</xsl:text>
						
					</field>
					
					<field name="dateDisplay">
						<xsl:call-template name="extractDate">
							<xsl:with-param name="date"
								select="$doc_date"/>
						</xsl:call-template>
					</field>
					
				</xsl:if>
				
				
				<!-- format -->
				
				<field name="format">
					<xsl:choose>
						<!-- letter -->
						<xsl:when test="/TEI/text/body/div1[@type='letter']">
							<xsl:text>letter</xsl:text>
						</xsl:when>
						<!-- magazine/journal -->
						<xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='j']">
							<xsl:text>periodical</xsl:text>
						</xsl:when>
						<!-- magazine/journal -->
						<xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='m']">
							<xsl:text>manuscript</xsl:text>
						</xsl:when>
					</xsl:choose>
				</field>
				
				<!-- repository -->
				
				<xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository[1] != ''">
					<field name="source">
						<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository"/>
					</field>
				</xsl:if>
				
				<!-- project/related 
				There's probably a better place for this, but this will do for now. 
				The Spec seems to say that related should be used for related files. -->
				
				<field name="related">
					<xsl:value-of select="/TEI/teiHeader/fileDesc/publicationStmt/authority"></xsl:value-of>
				</field>
				
				<!-- ==================== -->
				
				<!-- CDRH fields -->
				
				<!-- Principal Investigators -->
				<!-- Not in Dublin core, but I wanted to record this info -->
				
				<!-- All in one field -->
				<field name="principalInvestigator">
					<xsl:for-each-group select="/TEI/teiHeader/fileDesc/titleStmt/principal" group-by=".">
						<xsl:sort select="."/>
						<xsl:value-of select="current-grouping-key()"/>
						<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
					</xsl:for-each-group>
				</field>
				<!-- Individual fields -->
				<xsl:for-each-group select="/TEI/teiHeader/fileDesc/titleStmt/principal" group-by=".">
					<field name="principalInvestigators">
						<xsl:value-of select="current-grouping-key()"></xsl:value-of>
					</field>
				</xsl:for-each-group>
				
				<!-- category -->
				
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='category']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="category">
							<xsl:value-of select="."/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- subCategory -->
				
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="subcategory">
							<xsl:value-of select="."/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- topic -->
				<xsl:for-each
					select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="topic">
							<xsl:apply-templates/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- keywords -->
				<xsl:for-each
					select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="keywords">
							<xsl:apply-templates/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- people -->
				<xsl:for-each
					select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="people">
							<xsl:apply-templates/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- places -->
				<xsl:for-each
					select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="places">
							<xsl:apply-templates/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- works -->
				<xsl:for-each
					select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="works">
							<xsl:apply-templates/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- text -->
				
				<field name="text">
					<xsl:for-each select="//text">
						<xsl:text> </xsl:text>
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</field>
				
				
			</doc>
		</add>
			
		</xsl:if>

	</xsl:template>
	
	
	<!-- ========================================================
	Helper Templates
	==========================================================-->
	
	<xsl:template name="date_standardize">
		<xsl:param name="datebefore"/>
		<xsl:choose>
			<xsl:when test="count(tokenize($datebefore,'-')) = 1">
				<!-- Make sure it is the correct string length -->
				<xsl:if test="string-length($datebefore) = 4">
					<xsl:value-of select="$datebefore"/>
					<xsl:text>-01-01</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="count(tokenize($datebefore,'-')) = 2">
				<!-- Make sure it is the correct string length -->
				<xsl:if test="string-length($datebefore) = 7">
					<xsl:value-of select="$datebefore"/>
					<xsl:text>-01</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="count(tokenize($datebefore,'-')) = 3">
				<!-- Make sure it is the correct string length -->
				<xsl:if test="string-length($datebefore) = 10">
					<xsl:value-of select="$datebefore"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise><!-- do nothing because date is not in proper format --></xsl:otherwise>
		</xsl:choose>
		
		
		
	</xsl:template>


</xsl:stylesheet>

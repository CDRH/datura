<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:output indent="yes" omit-xml-declaration="yes"/>
	
	<!-- ======================================
		Params passed in from ruby script
		====================================== -->
	<xsl:param name="date"/>
	<xsl:param name="string"/>
	<xsl:param name="site_location"/><!-- will be lassed in from config.yml -->
	<xsl:param name="file_location"/><!-- will be lassed in from config.yml -->
	<xsl:param name="project" select="/TEI/teiHeader/fileDesc/publicationStmt/authority[1]"></xsl:param>
	<xsl:param name="slug"/><!-- will be lassed in from config.yml -->
	
	
	<xsl:include href="../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"/>
	
	<!-- ======================================
		Variables
		====================================== -->
	
	<xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
	<!-- The part of the url after the main document structure and before the filename. 
		Collected so we can link to files, even if they are nested, i.e. whitmanarchive/manuscripts -->
	<!--<xsl:variable name="slug" select="substring-before(substring-before(substring-after(base-uri(.),'data/projects/'),$filename),'/')"/>-->
	
	<!-- Split the filename using '\.' -->
	<xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
	<xsl:variable name="doctype">
		<xsl:choose>
			<xsl:when test="//body//listPerson">person</xsl:when>
			<xsl:when test="contains($filenamepart,'caseid')">caseid</xsl:when>
			<xsl:otherwise>document</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- ======================================
		Basic structure of xml post and calling templates
		====================================== -->
	
	<xsl:template match="/" exclude-result-prefixes="#all">
		
		<add>
		<xsl:choose>
			<!-- Act differenly on personography, caseid, or document (everything else) -->
			<xsl:when test="$doctype = 'person'">
				<xsl:for-each select="//person">
					<doc>
				<xsl:call-template name="tei_general">
					<xsl:with-param name="filenamepart" select="$filenamepart"/>
					<xsl:with-param name="slug" select="$slug"/>
				</xsl:call-template>
				<xsl:call-template name="tei_person"/>
				</doc>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$doctype = 'caseid'">
				<doc>
					<xsl:call-template name="tei_general">
						<xsl:with-param name="filenamepart" select="$filenamepart"/>
						<xsl:with-param name="slug" select="$slug"/>
					</xsl:call-template>
					<xsl:call-template name="tei_caseid"/>
				</doc>
			</xsl:when>
			<xsl:otherwise>
				<doc>
				<xsl:call-template name="tei_general">
					<xsl:with-param name="filenamepart" select="$filenamepart"/>
					<xsl:with-param name="slug" select="$slug"/>
				</xsl:call-template>
					<xsl:call-template name="tei_document"/>
				</doc>
				
					<xsl:call-template name="tei_document_join"/>
				
			</xsl:otherwise>
			
		</xsl:choose>
		</add>
		
		<!--<xsl:variable name="TESTTEST" select="/TEI/@xml:id"/>
		
		<xsl:for-each select="/TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@n = $TESTTEST or not(@n)]">
			[[[
			<xsl:value-of select="."></xsl:value-of>
			]]]
		</xsl:for-each>-->
			
			
		
	</xsl:template>
	
	
	<!-- ==============================
	See OSCYS Schema at: https://github.com/CDRH/data/blob/master/projects/oscys/schema.md
	=================================== -->
	
	

	<xsl:template name="tei_general" exclude-result-prefixes="#all">
		<xsl:param name="filenamepart"/>
		<xsl:param name="slug"/>
		

				
				<!-- ==============================
				resource identification 
				===================================-->
				
				<!-- id -->
				<!-- if person, in person template below -->
				<xsl:if test="$doctype != 'person'">
					<field name="id">
						<xsl:value-of select="$filenamepart"/>
					</field>
				</xsl:if>
				
				<!-- slug -->
				
				<field name="slug" update="add">
					<xsl:value-of select="$slug"/>
				</field>
				
				<!-- project -->
				
		<field name="project" update="add">
					<xsl:value-of select="$project"/>
				</field>
				
				<!-- uri -->
				
		<field name="uri" update="add"><xsl:value-of select="$site_location"/><xsl:text>files/</xsl:text><xsl:value-of select="$filenamepart"/>.html</field>
				
				<!-- uriXML -->
				
		<field name="uriXML" update="add">
					<xsl:value-of select="$file_location"/>
					<xsl:value-of select="$slug"/>
					<xsl:text>/tei/</xsl:text>
					<xsl:value-of select="$filenamepart"/>
					<xsl:text>.xml</xsl:text>
				</field>
				
				<!-- uriHTML -->
				
		<field name="uriHTML" update="add">
					<xsl:value-of select="$file_location"/>
					<xsl:value-of select="$slug"/>
					<xsl:text>/html-generated/</xsl:text>
					<xsl:value-of select="$filenamepart"/>
					<xsl:text>.txt</xsl:text>
				</field>
				
				<!-- dataType -->
				
		<field name="dataType" update="add"> 
					<xsl:text>tei</xsl:text>
				</field>
				
				
				<!-- ==============================
				Dublin Core 
				===================================-->
				
				<!-- title -->
				
				<!-- set title -->
				<xsl:variable name="title">
				<xsl:choose>
					<!-- if person, take PersName. todo: add more complicated rules.  -->
					<xsl:when test="$doctype = 'person'">
						<!--<xsl:value-of select='persName'/>-->
						<xsl:for-each select="persName">
							<xsl:call-template name="persNameFormatter"/>
						</xsl:for-each>
						
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']">
								<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'][1]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				</xsl:variable>
		
		<xsl:variable name="titleSort">
			<xsl:call-template name="normalize_name">
				<xsl:with-param name="string">
					<xsl:value-of select="$title"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="titleLetter">
			<xsl:value-of select="substring($titleSort,1,1)"></xsl:value-of>
		</xsl:variable>
		
		
				
		<field name="title" update="add">
					<xsl:value-of select="$title"/>
				</field>
				
				<!-- titleSort -->
				
		<field name="titleSort" update="add">
					<xsl:value-of select="$titleSort"/>
				</field>
		
		<field name="titleLetter_s" update="add">
			<xsl:value-of select="$titleLetter"/>
		</field>
		
				
				<!-- creator -->
				<!-- creators -->
				
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
				
				<!-- subject -->
				<!-- subjects -->
				<!-- description -->
				<!-- publisher -->
				
				<xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1] and /TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1] != ''">
					<field name="publisher">
						<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]"></xsl:value-of>
					</field>
				</xsl:if>
				
				<!-- contributor -->
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
				<!-- dateDisplay -->
				
				<!-- date -->
				
				<xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when">
					<xsl:variable name="doc_date">
						<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when"/>
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
				
				<!-- type -->
				
				<!-- format -->
				
				<xsl:variable name="format">
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
				</xsl:variable>
		
				<xsl:if test="$format != ''">
					<field name="format">
						<xsl:value-of select="$format"/>
					</field>
				</xsl:if>
				
				
				<!-- medium -->
				<!-- extent -->
				
				<!-- language -->
				<!-- relation -->
				<!-- coverage -->
				<!-- source -->
				
				<!-- todo: check with Kaci and Laura on how to format -->
		<xsl:if test="/TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/bibl[1] != ''">
					<field name="source">
						<xsl:value-of select="/TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/bibl[1]"/>
					</field>
				</xsl:if>
				
				<!-- rightsHolder -->
				
				<xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository[1] != ''">
					<field name="rightsHolder">
						<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository"/>
					</field>
				</xsl:if>
				
				<!-- rights -->
				<!-- rightsURI -->
				<!-- principalInvestigator -->
				<!-- principalInvestigators -->
				
				<!-- All in one field -->
		<field name="principalInvestigator" update="add">
					<xsl:for-each-group select="/TEI/teiHeader/fileDesc/titleStmt/principal" group-by=".">
						<xsl:sort select="."/>
						<xsl:value-of select="current-grouping-key()"/>
						<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
					</xsl:for-each-group>
				</field>
				<!-- Individual fields -->
				<xsl:for-each-group select="/TEI/teiHeader/fileDesc/titleStmt/principal" group-by=".">
					<field name="principalInvestigators" update="add">
						<xsl:value-of select="current-grouping-key()"></xsl:value-of>
					</field>
				</xsl:for-each-group>
				
				<!-- place -->
				<!-- placeName -->
				
				<!-- recipient -->
				<!-- recipients -->
				
				<!-- This is currently the way we encode for Neihardt. Other projects may need special rules. 
					Also, the TEI rules for may change.
					Currently, there is only one persName per letter, but that too could change
				-->
				<xsl:if test="/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName != ''">
					<field name="recipient">
						<xsl:value-of select="/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName"/>
					</field>
					<field name="recipients">
						<xsl:value-of select="/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName"/>
					</field>
				</xsl:if>
				
				
				<!-- ==============================
				CDRH specific 
				===================================-->
				
				<!-- category -->
		
		<xsl:variable name="category">
			<xsl:choose>
			<xsl:when test="/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term">
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term">
					<xsl:if test="normalize-space(.) != ''">
						<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>texts</xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
				
				<field name="category" update="add">
					<xsl:value-of select="$category"/>
				</field>
				
				
				<!-- subCategory -->
				
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="subCategory">
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
				
				<xsl:if test="$doctype != 'person'">
				<xsl:for-each
					select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="people">
							<xsl:apply-templates/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson/person/persName">
					<xsl:if test="normalize-space(.) != ''">
					<field name="people">
						<xsl:value-of select="."/>
					</field>
					</xsl:if>
				</xsl:for-each>
				</xsl:if>
				

				<!-- places -->
				<xsl:if test="$doctype != 'person'">
				<xsl:for-each
					select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="places">
							<xsl:apply-templates/>
						</field>
					</xsl:if>
				</xsl:for-each>
				</xsl:if>
				
				<!-- works -->
				
				<xsl:for-each
					select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="works">
							<xsl:apply-templates/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				
				<!-- ===============================
					OSCYS Specific fields
				==================================== -->
		
		<xsl:call-template name="people"/>
				
				<!-- recordType_s -->
		
				<field name="recordType_s">
					<xsl:value-of select="$doctype"/>
				</field>

				<!-- term -->
				
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='term']/term">
					<xsl:if test="normalize-space(.) != ''">
						<field name="term_ss"> 
							<xsl:value-of select="."/>
						</field>
					</xsl:if>
				</xsl:for-each>
					
				<!-- Related cases (for case pages) -->
				
				<!-- related case ID -->
				
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/classCode/ref[@type='related.case']">
					<xsl:if test="normalize-space(.) != ''">
						<field name="relatedCaseID_ss" update="add"> 
							<xsl:value-of select="."/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- related case Data (In JSON) -->
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/classCode/ref[@type='related.case']">
					<xsl:if test="normalize-space(.) != ''">
						<field name="relatedCaseData_ss" update="add"> 
							<xsl:text>{</xsl:text>
							
							<!-- Label -->
							<xsl:text>"label":"</xsl:text>
							<!-- go to another document to get the case name -->
							<xsl:variable name="caseDocID"><xsl:text>../tei/</xsl:text><xsl:value-of select="."/><xsl:text>.xml</xsl:text></xsl:variable>
							<xsl:for-each select="document($caseDocID)">
								<xsl:value-of select="//title"/>
							</xsl:for-each>
							<xsl:text>"</xsl:text>
							
							<xsl:text>,</xsl:text>
							
							<!-- ID -->
							<xsl:text>"id":"</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>"</xsl:text>
							
							<xsl:text>}</xsl:text>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- case ID -->
		<!-- This is used only in documents to point to the case which they belong to -->
				
				<xsl:for-each select="//idno[@type='case']">
					<xsl:if test="normalize-space(.) != ''">
						<field name="documentCaseID_ss" update="add"> 
							<xsl:value-of select="."/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- case Name -->
				
				<xsl:for-each select="//idno[@type='case']">
					<xsl:if test="normalize-space(.) != ''">
						<field name="documentCaseData_ss"> 
							<xsl:text>{</xsl:text>
							
							<!-- Label -->
							<xsl:text>"label":"</xsl:text>
							<!-- go to another document to get the case name -->
							<xsl:variable name="caseDocID"><xsl:text>../tei/</xsl:text><xsl:value-of select="."/><xsl:text>.xml</xsl:text></xsl:variable>
							<xsl:for-each select="document($caseDocID)">
								<xsl:value-of select="//title"/>
							</xsl:for-each>
							<xsl:text>"</xsl:text>
							
							<xsl:text>,</xsl:text>
							
							<!-- ID -->
							<xsl:text>"id":"</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>"</xsl:text>
								
							<xsl:text>}</xsl:text>
						</field>
					</xsl:if>
				</xsl:for-each>
		
		<xsl:for-each select="//orgName">
			<field name="jurisdiction_ss"><xsl:value-of select="."/></field>
		</xsl:for-each>
				
				
		
		<!-- Text -->
		
		<xsl:if test="$doctype != 'person'">
		<field name="text">
			<xsl:for-each select="//text">
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
		</field>
		</xsl:if>

	</xsl:template>
	
	
	
<!-- ==================================
	Person
	=================================== -->
	
	<xsl:template name="tei_person" exclude-result-prefixes="#all">
		<!-- All are within the //person for-each -->
		
		<!-- id -->
		
		<field name="id">
			<xsl:value-of select="@xml:id"/>
		</field>
		
		<xsl:variable name="updateType"></xsl:variable>
		
		<!-- people -->
		
		
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">people</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		
		
		<!--<field name="people"><xsl:value-of select='persName'/></field>-->
		<!-- todo, fill this in from personography -->
		<!--<field name="places"></field>-->
		
		<!-- OSCYS Specific -->
		
		<!--<field name="peopleData_ss">
			<xsl:text>{"id":"</xsl:text>
			<xsl:value-of select="@xml:id"/>
			<xsl:text>","label":"</xsl:text>
			<xsl:value-of select='persName'/>
			<xsl:text>"}</xsl:text>
		</field>-->
		
		<!-- Person ID -->
		
		<!--<field name="peopleID_ss">
			<xsl:value-of select="@xml:id"></xsl:value-of>
		</field>-->
		
		<!-- People Specific -->
		
		
		<xsl:for-each select="idno[@type='viaf'][normalize-space()]">
			<field name="personIdnoVIAF_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<!--<field name="personData_ss"><xsl:call-template name="dataIDSourceData"/></field>-->
		</xsl:for-each>
		
		<!-- ??? -->
		<xsl:for-each select="persName[normalize-space()]">
			<field name="personName_ss"><xsl:call-template name="persNameFormatter"></xsl:call-template></field>
			<field name="personNameData_ss">
				<xsl:call-template name="dataIDSourceData">
					<xsl:with-param name="label"><xsl:call-template name="persNameFormatter"/></xsl:with-param>
				</xsl:call-template>
			</field>
		</xsl:for-each>
		
		<xsl:for-each select="persName/addName[normalize-space()]">
			<field name="personAltName_ss"><xsl:value-of select="normalize-space(.)"></xsl:value-of></field>
		</xsl:for-each>
		
		<xsl:for-each select="sex[normalize-space()]">
			<field name="personSex_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personSexData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="affiliation[normalize-space()]">
			<field name="personAffiliation_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personAffiliationData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="age[normalize-space()]">
			<field name="personAge_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personAgeData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="bibl[normalize-space()]">
			<field name="personBibl_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personBiblData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="birth[normalize-space()]">
			<field name="personBirth_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personBirthData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="death[normalize-space()]">
			<field name="personDeath_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personDeathData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="event[normalize-space()]">
			<field name="personEvent_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personEventData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="nationality[normalize-space()]">
			<field name="personNationality_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personNationalityData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="note[normalize-space()]">
			<field name="personNote_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personNoteData_ss"><xsl:call-template name="dataIDSourceData"/></field>
		</xsl:for-each>
		<xsl:for-each select="occupation[normalize-space()]">
			<field name="personOccupation_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personOccupationData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="residence[normalize-space()]">
			<field name="personResidence_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personResidenceData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="socecStatus[normalize-space()]">
			<field name="personSocecStatus_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personSocecStatusData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>
		<xsl:for-each select="trait[@type='color'][normalize-space()]">
			<field name="personColor_ss"><xsl:value-of select="normalize-space(.)"/></field>
			<field name="personColorData_ss"><xsl:call-template name="dataIDSourceData"><xsl:with-param name="label" select="normalize-space(.)"/></xsl:call-template></field>
		</xsl:for-each>

		
		<field name="text">
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text> </xsl:text>
		</field>


	</xsl:template>
	
	<xsl:template name="dataIDSourceData">
		<xsl:param name="label"/>
		
		
		<xsl:text>{</xsl:text>
		
		<!-- Label -->
		<xsl:text>"label":"</xsl:text>
		<xsl:value-of select="$label"></xsl:value-of>
		<xsl:text>"</xsl:text>
		
		<!-- Date -->
		<xsl:if test="@notAfter[normalize-space()] or @notBefore[normalize-space()] or @when[normalize-space()]">
			<xsl:text>,"date":"</xsl:text>
			<xsl:if test="@notAfter[normalize-space()]"><xsl:text>Not After </xsl:text><xsl:value-of select="@notAfter"/></xsl:if>
			<xsl:if test="@notBefore[normalize-space()]"><xsl:text>Not Before </xsl:text><xsl:value-of select="@notBefore"/></xsl:if>
			<xsl:value-of select="@when"></xsl:value-of>
			<xsl:text>"</xsl:text>
		</xsl:if>
		
		<xsl:text>,</xsl:text>
		
		<!-- ID -->
		<xsl:text>"id":"</xsl:text>
		<xsl:choose>
			<xsl:when test="contains(@source,'viaf')">
				<xsl:value-of select="//sourceDesc[1]//bibl[1]/ref"></xsl:value-of>
			</xsl:when>
			<xsl:when test="@source">
				<xsl:text>oscys</xsl:text>
				<xsl:value-of select="substring-after(@source,'oscys')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>oscys</xsl:text>
				<xsl:value-of select="substring-after(../@source,'oscys')"></xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>"</xsl:text>
		

		
		<xsl:text>}</xsl:text>
	</xsl:template>
	
	<!-- ==================================
	case ID
	=================================== -->
	
	<xsl:template name="tei_caseid" exclude-result-prefixes="#all">
		<xsl:if test="normalize-space(//div1[@type='case']) != ''">
			<field name="caseidHasNarrative_s">true</field>
		</xsl:if>
		
		
	</xsl:template>
	
	<!-- ==================================
	Case Doc
	=================================== -->
	
	<xsl:template name="tei_document" exclude-result-prefixes="#all">
	
		
		
	</xsl:template>
	
	<!-- ==================================
	Case Doc Join (info to go in a caseid record from a case document) 
	=================================== -->
	
	<xsl:template name="tei_document_join" exclude-result-prefixes="#all">
		
		<xsl:for-each select="//idno[@type='case'][normalize-space()]">
			<doc>
				<field name="id"> 
					<xsl:value-of select="."/>
				</field>
			<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='outcome']/term">
				<field update="add" name="outcomeID_ss">
					<xsl:text>{</xsl:text>
					
					<!-- Label -->
					<xsl:text>"label":"</xsl:text>
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text>"</xsl:text>
					
					<xsl:text>,</xsl:text>
					
					<!-- ID -->
					<xsl:text>"id":"</xsl:text>
					<xsl:value-of select="/TEI/@xml:id"/>
					<xsl:text>"</xsl:text>
						
					<xsl:text>}</xsl:text>
				</field>
			</xsl:for-each>
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='outcome']/term">
					<field update="add" name="outcome_ss">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:for-each>
				

				<xsl:variable name="caseid" select="normalize-space(.)"></xsl:variable>
				
				<!--[[[{<xsl:value-of select="//listPerson[1]/@type"/>}{<xsl:value-of select="$caseid"/>}]]]-->
				<!--/TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@n = $TESTTEST or not(@n)]-->
				
				
				<xsl:call-template name="people">
						<xsl:with-param name="updateType">caseID</xsl:with-param>
						<xsl:with-param name="caseid"><xsl:value-of select="$caseid"></xsl:value-of></xsl:with-param>
				</xsl:call-template>
					
				
				

			
			<xsl:for-each select="//orgName">
				<field name="jurisdiction_ss" update="add"><xsl:value-of select="."/></field>
			</xsl:for-each>
				
				
				<!-- split into case documents and related documents -->
				<xsl:choose>
					<xsl:when test="normalize-space(//keywords[@n='category']) = 'Case Papers'">
						<field name="caseDocumentID_ss" update="add">
							<xsl:value-of select="/TEI/@xml:id"/>
						</field>
						<field name="caseDocumentData_ss" update="add">
							<xsl:text>{</xsl:text>
							
							<!-- Label -->
							<xsl:text>"label":"</xsl:text>
							<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
							<xsl:text>"</xsl:text>
							
							<xsl:text>,</xsl:text>
							
							<!-- ID -->
							<xsl:text>"id":"</xsl:text>
							<xsl:value-of select="/TEI/@xml:id"/>
							<xsl:text>"</xsl:text>
								
							<xsl:text>}</xsl:text>
						</field>
					</xsl:when>
					<xsl:otherwise>
						<field name="caseRelatedDocumentID_ss" update="add">
							<xsl:value-of select="/TEI/@xml:id"/>
						</field>
						<field name="caseRelatedDocumentData_ss" update="add">
							<xsl:text>{</xsl:text>
							
							<!-- Label -->
							<xsl:text>"label":"</xsl:text>
							<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
							<xsl:text>"</xsl:text>
							
							<xsl:text>,</xsl:text>
							
							<!-- ID -->
							<xsl:text>"id":"</xsl:text>
							<xsl:value-of select="/TEI/@xml:id"/>
							<xsl:text>"</xsl:text>
							
							<xsl:text>}</xsl:text>
						</field>
					</xsl:otherwise>
				</xsl:choose>
				
				
				
			</doc>
		</xsl:for-each>
		
		

	</xsl:template>
	
	
	<!-- ==================================
	Person Name Formatter
	=================================== -->
	
	<xsl:template name="persNameFormatter">
		<xsl:choose>
			<xsl:when test="not(child::*)">
				<xsl:value-of select="normalize-space(.)"></xsl:value-of>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="surname[not(@type)][normalize-space()]"/><!-- [not(@*)] not working :( -->
				<xsl:if test="(surname and forename) or (surname and roleName) or (surname and genName)"><xsl:text>,</xsl:text></xsl:if>
				<xsl:if test="roleName != ''">
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(roleName)"/>
				</xsl:if>
				<xsl:if test="forename[@type='first'] != ''">
					<xsl:text> </xsl:text>
					<xsl:for-each select="forename[@type='first']">
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="forename[@type='middle'] != ''">
					<xsl:text> </xsl:text>
					<xsl:for-each select="forename[@type='middle']">
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:for-each>
					
				</xsl:if>
				<xsl:if test="genName != ''">
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(genName)"/>
				</xsl:if>
				<xsl:if test="surname[@type='maiden'] != ''">
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(surname[@type='maiden'])"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<!-- ==================================
	Person Field
	=================================== -->
	
	<xsl:template name="personField" exclude-result-prefixes="#all">
		<xsl:param name="fieldName"/>
		<xsl:param name="personCode"/>
		<xsl:param name="updateType"/>

		<xsl:variable name="personID">
		<xsl:choose>
			<xsl:when test="../@xml:id">
				<xsl:value-of select="../@xml:id"/>
			</xsl:when>
			<xsl:when test="@xml:id">
				<xsl:value-of select="@xml:id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>per.000000</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		
		<!-- for troubleshooting, remove later -->
		<!--[[[
		<xsl:copy-of select="$personCode"></xsl:copy-of>
		]]]-->
		
		<xsl:variable name="personName">
			<xsl:for-each select="$personCode/person/persName[1]">
				
				<xsl:call-template name="persNameFormatter"/>
				
			</xsl:for-each>
		</xsl:variable>
		
	
		
			<field>
				<xsl:attribute name="name"><xsl:value-of select="$fieldName"/><xsl:text>_ss</xsl:text></xsl:attribute>
				<xsl:if test="$updateType = 'caseID'"><xsl:attribute name="update">add</xsl:attribute></xsl:if>
					
				<xsl:value-of select="$personName"/>
			</field>
		
		
		
			<field>
				<xsl:attribute name="name"><xsl:value-of select="$fieldName"/><xsl:text>ID_ss</xsl:text></xsl:attribute>
				<xsl:if test="$updateType = 'caseID'"><xsl:attribute name="update">add</xsl:attribute></xsl:if>
				<xsl:value-of select="$personID"/>
			</field>
		
		
			<field>
				<xsl:attribute name="name"><xsl:value-of select="$fieldName"/><xsl:text>Data_ss</xsl:text></xsl:attribute>
				<xsl:if test="$updateType = 'caseID'"><xsl:attribute name="update">add</xsl:attribute></xsl:if>
				
				<xsl:text>{</xsl:text>
				
				<!-- Label -->
				<xsl:text>"label":"</xsl:text>
				<xsl:value-of select="$personName"/>
				<xsl:text>"</xsl:text>
				
				<xsl:text>,</xsl:text>
				
				<!-- ID -->
				<xsl:text>"id":"</xsl:text>
				<xsl:value-of select="$personID"/>
				<xsl:text>"</xsl:text>
				
				<xsl:text>}</xsl:text>
			</field>
		
	</xsl:template>
	
	
	<!-- ==================================
	People (template so can be repeated in caseid and case documents)
	
	This template pulls all people out of the teiHeader and inserts into the respective documents. 
	=================================== -->
	
	<xsl:template name="people"  exclude-result-prefixes="#all">
		<xsl:param name="updateType"/>
		<xsl:param name="caseid"/>
		
		<!-- Generic people in keywords rather than a listPerson -->

		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term[1][normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">person</xsl:with-param>
				<xsl:with-param name="personCode">
					<person xmlns="http://www.tei-c.org/ns/1.0" xml:id="{@xml:id}">
						<persName><xsl:value-of select="."/></persName>
					</person>
				</xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	
		
		<!-- Explanation of listPerson[@type = $caseid or not(@type)]
		In order to match up the people in the documents with more than one case, they have been seperated 
		into seperate listpersons with the case id on type. see file oscys.case.0017.003 for an example. 
		This xpath matches the value on the listperson to the caseid, or pulls everything if there is no caseid -->
		
		<!-- Person ID and Name -->
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson[@type = $caseid or not(@type)]/person/persName[normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">person</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<!-- plaintiff -->
		
		<!-- earlier docs used petitioner instead of plaintiff -->
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson[@type = $caseid or not(@type)]/person[@role='petitioner']/persName[1][normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">plaintiff</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>

		</xsl:for-each>
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson[@type = $caseid or not(@type)]/person[@role='plaintiff']/persName[1][normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">plaintiff</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>

				
		</xsl:for-each>
		
		<!-- defendant -->
		
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson[@type = $caseid or not(@type)]/person[@role='defendant']/persName[1][normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">defendant</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<!-- attorney P -->
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson[@type = $caseid or not(@type)]/person[@role='attorney_petitioner']/persName[1][normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">attorneyP</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">attorney</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson[@type = $caseid or not(@type)]/person[@role='attorney_plaintiff']/persName[1][normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">attorneyP</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">attorney</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		
		<!-- attorney D -->
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson[@type = $caseid or not(@type)]/person[@role='attorney_defendant']/persName[1][normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">attorneyD</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">attorney</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		
		

	</xsl:template>
	

	<!-- ==================================
	JSON Formatting 
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
		<xsl:text>"</xsl:text>
		<xsl:call-template name="escape-bs-string">
			<xsl:with-param name="s" select="$s"/>
		</xsl:call-template>
		<xsl:text>"</xsl:text>
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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
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
		
		
		<!-- Set file type, based on containing folder -->
		<!--<xsl:variable name="type">
			<xsl:variable name="path">
				<xsl:text>data/projects/</xsl:text>
				<xsl:value-of select="$slug"></xsl:value-of>
				<xsl:text>/</xsl:text>
			</xsl:variable>
			<xsl:value-of select="substring-before(substring-before(substring-after(base-uri(.),$path),$filename), '/')"/>
		</xsl:variable>-->
		
		<add>
		<xsl:choose>
			<!-- Act differenly on personography -->
			<xsl:when test="$doctype = 'person'">
				<!--<xsl:for-each select="//trait">
					<xsl:for-each select="./*/node-name(.)">
						<xsl:text>
</xsl:text><xsl:value-of select="."></xsl:value-of>
					</xsl:for-each>
					
				</xsl:for-each>-->
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
				
				<!-- testing to see if I can add a person to a case from a document -->
				<!--<doc>
					
				</doc>-->
			</xsl:otherwise>
			
		</xsl:choose>
		</add>
		
		
		
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
					<xsl:when test="$doctype = 'person'">
						<xsl:value-of select='persName'/>
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
				
		<field name="title" update="add">
					<xsl:value-of select="$title"/>
				</field>
				
				<!-- titleSort -->
				
		<field name="titleSort" update="add">
					<xsl:call-template name="normalize_name">
						<xsl:with-param name="string">
							<xsl:value-of select="$title"/>
						</xsl:with-param>
					</xsl:call-template>
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
					
					<!-- datesExact - a multivalued field for matching exact dates: 
						i.e. pulling all the things that happened on a certain date -->
					
					
					
					<!--<xsl:choose>
							<!-\- Only have an exact date when document has an exact date. Used when pulling documents from a certain date -\->
							<xsl:when test="translate($doc_date, '1234567890-', '') = '' and string-length(dc:date) = 10">
								<field name="datesExact">
									<xsl:call-template name="date_standardize">
										<xsl:with-param name="datebefore"><xsl:value-of select="dc:date"/></xsl:with-param>
									</xsl:call-template>
									<xsl:text>T00:00:00Z</xsl:text>
								</field>
							</xsl:when>
							<xsl:otherwise><!-\- blank for no date -\-></xsl:otherwise>
						</xsl:choose>-->
					
					
					
					<field name="dateDisplay">
						<xsl:call-template name="extractDate">
							<xsl:with-param name="date"
								select="$doc_date"/>
						</xsl:call-template>
					</field>
					
				</xsl:if>
				
				<!-- type -->
				
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
				
				<!-- medium -->
				<!-- extent -->
				
				<!-- language -->
				<!-- relation -->
				<!-- coverage -->
				<!-- source -->
				
				<xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='j'] != ''">
					<field name="source">
						<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='j']"/>
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
				
				
				<!-- ==============================
				OSCYS Specific elements 
				===================================-->
				
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
			
			<xsl:when test="contains($filenamepart, 'caseid')">Caseid</xsl:when>
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
				
				<!-- related case Name -->
				<!-- todo make JSON -->
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/classCode/ref[@type='related.case']">
					<xsl:if test="normalize-space(.) != ''">
						<field name="relatedCaseIDName_ss" update="add"> 
							<xsl:text>{"id":"</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>","label":"</xsl:text>
							<!-- go to another document to get the case name -->
							<xsl:variable name="caseDocID"><xsl:text>../tei/</xsl:text><xsl:value-of select="."/><xsl:text>.xml</xsl:text></xsl:variable>
							<xsl:for-each select="document($caseDocID)">
								<xsl:value-of select="//title"/>
							</xsl:for-each>
							<xsl:text>"}</xsl:text>
							
							
							
							
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- case ID -->
		<!-- This is used only in documents to point to the case which they belong to -->
				
				<xsl:for-each select="//idno[@type='case']">
					<xsl:if test="normalize-space(.) != ''">
						<field name="caseID_ss" update="add"> 
							<xsl:value-of select="."/>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- case Name -->
				
				<xsl:for-each select="//idno[@type='case']">
					<xsl:if test="normalize-space(.) != ''">
						<field name="caseIDName_ss"> 
							<xsl:text>{"id":"</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>","label":"</xsl:text>
							<!-- go to another document to get the case name -->
							<xsl:variable name="caseDocID"><xsl:text>../tei/</xsl:text><xsl:value-of select="."/><xsl:text>.xml</xsl:text></xsl:variable>
							<xsl:for-each select="document($caseDocID)">
								<xsl:value-of select="//title"/>
							</xsl:for-each>
							<xsl:text>"}</xsl:text>
						</field>
					</xsl:if>
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
		
		<!-- people -->
		
		<field name="people"><xsl:value-of select='persName'/></field>
		<field name="places"></field>
		
		<!-- OSCYS Specific -->
		
		<field name="peopleIDName_ss">
					<xsl:value-of select="@xml:id"></xsl:value-of>
					<xsl:text>/</xsl:text>
					<xsl:value-of select='persName'/>
		</field>
		
		<!-- Person ID -->
		
		<field name="peopleID_ss">
			<xsl:value-of select="@xml:id"></xsl:value-of>
		</field>
		
		<!-- People Specific -->
		
		
		
		<xsl:for-each select="affiliation[normalize-space()]">
			<field name="personAffiliation_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="age[normalize-space()]">
			<field name="personAge_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="bibl[normalize-space()]">
			<field name="personBibl_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="birth[normalize-space()]">
			<field name="personBirth_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="death[normalize-space()]">
			<field name="personDeath_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="event[normalize-space()]">
			<field name="personEvent_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="idno[@type='viaf'][normalize-space()]">
			<field name="personIdnoVIAF_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="nationality[normalize-space()]">
			<field name="personNationality_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="note[normalize-space()]">
			<field name="personNote_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="occupation[normalize-space()]">
			<field name="personOccupation_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="persName[normalize-space()]">
			<field name="personName_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="residence[normalize-space()]">
			<field name="personResidence_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="sex[normalize-space()]">
			<field name="personSex_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="socecStatus[normalize-space()]">
			<field name="personSocecStatus_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		<xsl:for-each select="trait[@type='color'][normalize-space()]">
			<field name="personColor_ss"><xsl:value-of select="normalize-space(.)"/></field>
		</xsl:for-each>
		
	
	
		
		<field name="text">
			
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text> </xsl:text>
			
		</field>


	</xsl:template>
	
	<!-- ==================================
	case ID
	=================================== -->
	
	<xsl:template name="tei_caseid" exclude-result-prefixes="#all">
		

		
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
					<xsl:text>{"label":"</xsl:text>
					<xsl:value-of select="normalize-space(.)"/>
					<xsl:text>","id":"</xsl:text>
					<xsl:value-of select="/TEI/@xml:id"/>
					<xsl:text>"}</xsl:text>
				</field>
			</xsl:for-each>
				<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='outcome']/term">
					<field update="add" name="outcome_ss">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:for-each>
				
				<xsl:call-template name="people">
					<xsl:with-param name="updateType">caseID</xsl:with-param></xsl:call-template>
			</doc>
		</xsl:for-each>

	</xsl:template>
	
	
	<!-- PersonField (So I don't have to repeat my code over and over...) -->
	
	<xsl:template name="personField" exclude-result-prefixes="#all">
		<xsl:param name="fieldName"/>
		<xsl:param name="personCode"/>
		<xsl:param name="updateType"/>
		
		
		
		<xsl:variable name="personID">
		<xsl:choose>
			<xsl:when test="../@xml:id">
				<xsl:value-of select="../@xml:id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>per.000000</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		
		<field>
			<xsl:attribute name="name"><xsl:value-of select="$fieldName"/><xsl:text>_ss</xsl:text></xsl:attribute>
			<xsl:if test="$updateType = 'caseID'"><xsl:attribute name="update">add</xsl:attribute></xsl:if>
			<xsl:value-of select="normalize-space(.)"/>
		</field>
		
		<field>
			<xsl:attribute name="name"><xsl:value-of select="$fieldName"/><xsl:text>ID_ss</xsl:text></xsl:attribute>
			<xsl:if test="$updateType = 'caseID'"><xsl:attribute name="update">add</xsl:attribute></xsl:if>
			
			<xsl:text>{"id":"</xsl:text>
			<xsl:value-of select="$personID"/>
			<xsl:text>","label":"</xsl:text>
			<xsl:value-of select="normalize-space(.)"/>
			<xsl:text>"}</xsl:text>
		</field>	
	</xsl:template>
	
	
	<!-- ==================================
	People (template so can be repeated in caseid and case documents)
	=================================== -->
	
	<xsl:template name="people"  exclude-result-prefixes="#all">
		<xsl:param name="updateType"/>
		
		<!-- plaintiff -->
		
		<!-- earlier docs used petitioner instead of plaintiff -->
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson/person[@role='petitioner']/persName[normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">plaintiff</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>

		</xsl:for-each>
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson/person[@role='plaintiff']/persName[normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">plaintiff</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>

				
		</xsl:for-each>
		
		<!-- defendant -->
		
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson/person[@role='defendant']/persName[normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">defendant</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<!-- attorney P -->
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson/person[@role='attorney_petitioner']/persName[normalize-space()]">
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
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson/person[@role='attorney_plaintiff']/persName[normalize-space()]">
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
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson/person[@role='attorney_defendant']/persName[normalize-space()]">
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
		
		
		<!-- Person ID and Name -->
		
		<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/listPerson/person/persName[normalize-space()]">
			<xsl:call-template name="personField">
				<xsl:with-param name="fieldName">person</xsl:with-param>
				<xsl:with-param name="personCode"><xsl:copy-of select="../."/></xsl:with-param>
				<xsl:with-param name="updateType"><xsl:value-of select="$updateType"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

	</xsl:template>
	



</xsl:stylesheet>

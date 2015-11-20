<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.whitmanarchive.org/namespace"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:output indent="yes" omit-xml-declaration="yes"/>
	
	<!-- ===================================
	Correspondence
	=======================================-->
	
        <!-- PARAMS -->
        <!-- Defined in project config files -->
	<xsl:param name="date"/>          <!-- TODO kmd look at if date and string are still being used by anything -->
	<xsl:param name="string"/>
        <xsl:param name="fig_location"/>  <!-- url for figures -->
        <xsl:param name="file_location"/> <!-- url for tei files -->
        <xsl:param name="figures"/>       <!-- boolean for if figs should be displayed (not for this script, for html script) -->
        <xsl:param name="fw"/>            <!-- boolean for html not for this script -->
        <xsl:param name="pb"/>            <!-- boolean for page breaks in html, not this script -->
        <xsl:param name="project"/>       <!-- longer name of project -->
        <xsl:param name="slug"/>          <!-- slug of project -->
        
        <!-- TODO kmd jvd is site_location important to this script? -->
	<xsl:param name="site_location"/>
	<!-- <xsl:param name="project" select="/TEI/teiHeader/fileDesc/publicationStmt/authority[1]"></xsl:param> -->
	
        <!-- INCLUDES -->
	<xsl:include href="../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"/>
	
	
	
	
        <!-- SCRIPT -->
	<xsl:template match="/" exclude-result-prefixes="#all">
		<xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
		<!-- The part of the url after the main document structure and before the filename. 
			Collected so we can link to files, even if they are nested, i.e. whitmanarchive/manuscripts -->
		<!-- <xsl:variable name="slug" select="substring-before(substring-before(substring-after(base-uri(.),'data/projects/'),$filename),'/')"/> -->
		
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
		
		<!--<xsl:if test="$included = 'true'">ttt</xsl:if>--> <!-- Left from an experiment in generalizing the templates -->
		
		<add>
			<doc>
				
				<xsl:call-template name="tei_resource">
					<xsl:with-param name="filenamepart" select="$filenamepart"/>
					<xsl:with-param name="slug" select="$slug"/>
				</xsl:call-template>
		<xsl:call-template name="tei_template">
			<xsl:with-param name="filenamepart" select="$filenamepart"/>
			<xsl:with-param name="slug" select="$slug"/>
		</xsl:call-template>
			</doc>
		</add>
		
	</xsl:template>

	<!-- ==============================
	resource identification 
	===================================-->
	
	<!-- id -->
	<!-- slug -->
	<!-- project -->
	<!-- uri -->
	<!-- uriXML -->
	<!-- uriHTML -->
	<!-- dataType --> <!-- tei, dublin_core, csv, vra_core -->
	
	
	<!-- ==============================
	Dublin Core 
	===================================-->
	
	<!-- title -->
	<!-- titleSort -->
	<!-- creator -->
	<!-- creators -->
	<!-- subject -->
	<!-- subjects -->
	<!-- description -->
	<!-- publisher -->
	<!-- contributor -->
	<!-- contributors -->
	<!-- date -->
	<!-- dateDisplay -->
	<!-- type -->
	<!-- format -->
	<!-- medium -->
	<!-- extent -->
	<!-- language -->
	<!-- relation -->
	<!-- coverage -->
	<!-- source -->
	<!-- rightsHolder -->
	<!-- rights -->
	<!-- rightsURI -->
	
	
	<!-- ==============================
	Other Elements 
	===================================-->
	
	<!-- principalInvestigator -->
	<!-- principalInvestigators -->
	<!-- place -->
	<!-- placeName -->
	<!-- recipient -->
	<!-- recipients -->
	<!-- sender -->
	<!-- senders -->
	
	<!-- ==============================
	CDRH specific categorization
	===================================-->
	
	<!-- category -->
	<!-- subCategory -->
	<!-- topic -->
	<!-- keywords -->
	<!-- people -->
	<!-- places -->
	<!-- works -->
	
	<xsl:template name="tei_resource" exclude-result-prefixes="#all">
		<xsl:param name="filenamepart"/>
		<xsl:param name="slug"/>
		<!-- ==============================
				resource identification 
				===================================-->
		
		<!-- id -->
		
		<field name="id">
			<xsl:value-of select="$filenamepart"/>
		</field>
		
		<!-- slug -->
		
		<field name="slug">
			<xsl:value-of select="$slug"/>
		</field>
		
		<!-- project -->
		
		<field name="project">
			<xsl:value-of select="$project"/>
		</field>
		
		<!-- uri -->
		
		<field name="uri"><xsl:value-of select="$site_location"/><xsl:text>files/</xsl:text><xsl:value-of select="$filenamepart"/>.html</field>
		
		<!-- uriXML -->
		
		<field name="uriXML">
			<xsl:value-of select="$file_location"/>
			<xsl:value-of select="$slug"/>
			<xsl:text>/tei/</xsl:text>
			<xsl:value-of select="$filenamepart"/>
			<xsl:text>.xml</xsl:text>
		</field>
		
		<!-- uriHTML -->
		
		<field name="uriHTML">
			<xsl:value-of select="$file_location"/>
			<xsl:value-of select="$slug"/>
			<xsl:text>/html-generated/</xsl:text>
			<xsl:value-of select="$filenamepart"/>
			<xsl:text>.txt</xsl:text>
		</field>
		
		<!-- dataType -->
		
		<field name="dataType"> 
			<xsl:text>tei</xsl:text>
		</field>
		
		<!-- fig_location -->
		
		<xsl:if test="$fig_location != ''">
			<field name="fig_location">
				<xsl:value-of select="$fig_location"/>
			</field>
		</xsl:if>
		
		<!-- image_id -->
		
		<xsl:if test="//pb">
			<field name="image_id">
				<xsl:value-of select="(//pb)[1]/@facs"/>
			</field>
		</xsl:if>
		
	</xsl:template>
	
	

	<xsl:template name="tei_template" exclude-result-prefixes="#all">
		<xsl:param name="filenamepart"/>
		<xsl:param name="slug"/>
		
		
				
				
				
				
				
				<!-- ==============================
				Dublin Core 
				===================================-->
				
				<!-- title -->
				
				<!-- set title -->
				<xsl:variable name="title">
					<xsl:choose>
						<xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']">
							<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'][1]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<field name="title">
					<xsl:value-of select="$title"/>
				</field>
				
				<!-- titleSort -->
				
				<field name="titleSort">
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
				
				<!-- commented out because it's not working right -->
		<!--<xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@notBefore or /TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@when">
			<xsl:variable name="doc_date">
				<xsl:choose>
					<xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@notBefore">
						<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notBefore"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date[1]/@when"/>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:variable>
			
			<field name="date">
				<xsl:call-template name="date_standardize">
					<xsl:with-param name="datebefore"><xsl:value-of select="substring($doc_date,1,10)"/></xsl:with-param>
				</xsl:call-template>
				
			</field>
			
			<field name="dateDisplay">
				<xsl:call-template name="extractDate">
					<xsl:with-param name="date"
						select="$doc_date"/>
				</xsl:call-template>
			</field>
			
		</xsl:if>-->
		
		<!-- Eighth field is the item date in human-readable format, pulled from the date in source description. -->
		<field name="dateDisplay">
			<xsl:value-of select="//sourceDesc/bibl/date"/>
		</field>
		
		
		<!-- Ninth field is a sortable version of the date in the format yyyy-mm-dd pulled from @when or @notBefore on date element in the source description. -->
		<field name="date">
			<xsl:choose>
				<xsl:when test="//sourceDesc/bibl/date/attribute::notBefore">
					<xsl:value-of select="//sourceDesc/bibl/date/attribute::notBefore"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="//sourceDesc/bibl/date/attribute::when"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
		
				
				<!-- type -->
				
				<!-- format -->
				
				<field name="format">
					<xsl:choose>
						<!-- letter -->
						<xsl:when test="/TEI/text/body/div1[@type='letter']">
							<xsl:text>letter</xsl:text>
						</xsl:when>
						<xsl:when test="/TEI/text[@type='letter']">
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
				
				<field name="rightsHolder">
					<xsl:value-of select="//sourceDesc/bibl/orgName"/>
				</field>
				
				<!-- rights -->
				<!-- rightsURI -->
				
				
				<!-- ==============================
				Other elements 
				===================================-->
				
				<!-- principalInvestigator -->
				<!-- principalInvestigators -->
				
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
				
				<!-- place -->
				<!-- placeName -->
				
				<!-- recipient -->
				<!-- recipients -->
				
				<xsl:if test="/TEI/teiHeader/profileDesc/particDesc/person/@role='recipient'">
					
					<!-- All in one field -->
					<field name="recipient">
						<xsl:if test="count(//person[@role='recipient']) = 1"><xsl:value-of select="//person[@role='recipient']/persName/attribute::key"/></xsl:if>
						<xsl:if test="count(//person[@role='recipient']) = 2">
							<xsl:value-of select="//person[@role='recipient'][1]/persName/attribute::key"/>
							<xsl:text>; </xsl:text>
							<xsl:value-of select="//person[@role='recipient'][2]/persName/attribute::key"/>
						</xsl:if>
						<xsl:if test="count(//person[@role='recipient']) = 3">
							<xsl:value-of select="//person[@role='recipient'][1]/persName/attribute::key"/>
							<xsl:text>; </xsl:text>
							<xsl:value-of select="//person[@role='recipient'][2]/persName/attribute::key"/>
							<xsl:text>; </xsl:text>
							<xsl:value-of select="//person[@role='recipient'][3]/persName/attribute::key"/>
						</xsl:if>
						<xsl:if test="count(//person[@role='recipient']) &gt; 3">
							<xsl:value-of select="//person[@role='recipient'][1]/persName/attribute::key"/>
							<xsl:text>; </xsl:text>
							<xsl:value-of select="//person[@role='recipient'][2]/persName/attribute::key"/>
							<xsl:text>; </xsl:text>
							<xsl:value-of select="//person[@role='recipient'][3]/persName/attribute::key"/>
							<xsl:text> and others</xsl:text><!--
                        <xsl:value-of select="//person[@role='recipient'][4]/persName/attribute::key"/>-->
						</xsl:if>
					</field>
					<!-- Individual fields -->
					
					<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName/@key">
						<field name="recipients">
							<xsl:value-of select="."></xsl:value-of>
						</field>
					</xsl:for-each>
					
					
				</xsl:if>
				
				<!-- recipient -->
				<!-- recipients -->
				
				<xsl:if test="/TEI/teiHeader/profileDesc/particDesc/person/@role='sender'">
					
					<!-- All in one field -->
					<field name="sender">
						<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/person[@role='sender']/persName/@key">
							<xsl:value-of select="normalize-space(.)"/>
							<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
						</xsl:for-each>
					</field>
					<!-- Individual fields -->
					
					<xsl:for-each select="/TEI/teiHeader/profileDesc/particDesc/person[@role='sender']/persName/@key">
						<field name="senders">
							<xsl:value-of select="."></xsl:value-of>
						</field>
					</xsl:for-each>
					
					
				</xsl:if>
				
				
				
				<!-- ==============================
				CDRH specific 
				===================================-->
				
				<!-- category -->
				
				
				<field name="category">
					<xsl:text>biography</xsl:text>
				</field>
							
				<!-- subCategory -->
				
				<field name="subCategory">
					<xsl:text>correspondence</xsl:text>
				</field>
				
				
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
				
				
				<!-- ==============================
				Whitman specific 
				===================================-->
				
				<!-- repository_s 
				May be the same as rightsHolder, but duplicating for clarity
				-->
				
				<field name="repository_s">
					<xsl:value-of select="//sourceDesc/bibl/orgName"/>
				</field>
				
				<!-- text -->
				
				<!--<field name="text">
					<xsl:for-each select="//text">
						<xsl:text> </xsl:text>
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</field>-->
				
				<field name="text">
					<!-- To duplicate 'Editorial notes' section of metadata box in web view -->
					<!-- 1. Notes in others' hand on the document -->
					<xsl:for-each select="//body//note[@type='editorial']">
						<xsl:variable name="person_name"><xsl:value-of select="substring-after(@resp, '#')"/></xsl:variable>
						<xsl:text>The annotation, "</xsl:text><xsl:value-of select="//body//note[@type='editorial']"/><xsl:text>," is in the hand of </xsl:text> <xsl:value-of select="//handNote[@xml:id=$person_name]/persName"/><xsl:text>. </xsl:text>
					</xsl:for-each>
					<!-- 2. Notes about the document, such as about other items on the same leaf. -->
					<xsl:if test="//note[@type='project']"><xsl:value-of select="//note"/></xsl:if>
					
					
					<!-- Everything from text element -->
					<xsl:value-of select="//text"/>
					
					
					<!-- Footnotes -->
					<xsl:for-each select="//ptr">
						<xsl:variable name="ptr_target">
							<xsl:value-of select="@target"></xsl:value-of>
						</xsl:variable>                            
						
						<xsl:value-of select="document('notes.xml')//body/descendant::note[@xml:id=$ptr_target]"/><xsl:text>&#13;</xsl:text>
					</xsl:for-each>
					
					<xsl:for-each select="//profileDesc//persName[@ref]">
						<xsl:variable name="ref_target">
							<xsl:value-of select="@ref"/>
						</xsl:variable>
						<xsl:value-of select="document('notes.xml')//body/descendant::note[@xml:id=$ref_target]"/><xsl:text>&#13;</xsl:text>
					</xsl:for-each>
				</field>
				
				
				
			
		

	</xsl:template>


</xsl:stylesheet>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:output indent="yes"></xsl:output>
	
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
			
			<xsl:for-each select="//*[@level='item']">
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
				
			</xsl:for-each>
			
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
			<xsl:value-of select="did/unitid[@type='WWA']"/>
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
			<xsl:text>ead</xsl:text>
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
					<xsl:value-of select="normalize-space(did/unittitle)"/>
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
				
				
				<!--<field name="creator"></field>
				<field name="creators"></field>-->
					
					
				<!-- subject -->
				<!-- subjects -->
				<!-- description -->
				<!-- publisher -->
				
				<!--<field name="publisher"></field>-->
				
				<!-- contributor -->
				<!-- contributors -->
				
				<!-- All in one field -->
		
				<!--<field name="contributor"></field>-->
				<!-- Individual fields -->
		
				<!--<field name="contributors"></field>-->
				
				<!-- date -->
				<!-- dateDisplay -->
				
				<!-- date -->
				
				<xsl:if test="did/unitdate/@normal">
					
					<field name="date">
						<xsl:value-of select="did/unitdate/@normal"/>
					</field>
					
				
					
					
					<field name="dateDisplay">
						<xsl:value-of select="did/unitdate"></xsl:value-of>
					</field>
					
				</xsl:if>
				
				<!-- type -->
				
				<!-- format -->
				
				<field name="format">
					<xsl:text>Repository Item</xsl:text>
				</field>
				
				<!-- medium -->
				<!-- extent -->
				
				<!-- language -->
				<!-- relation -->
				<!-- coverage -->
				<!-- source -->
				
				<xsl:if test="/ead/archdesc[1]/did[1]/unittitle[1] != ''">
					<field name="source">
						<xsl:value-of select="normalize-space(/ead/archdesc[1]/did[1]/unittitle[1])"/>
					</field>
				</xsl:if>
				
				<!-- rightsHolder -->
				
				<field name="rightsHolder">
					<xsl:value-of select="normalize-space(/ead/archdesc[1]/did[1]/repository[1]/corpname[1])"/>
				</field>
				
				<!-- rights -->
				<!-- rightsURI -->
				
				
				<!-- ==============================
				Other elements 
				===================================-->
				
				<!-- principalInvestigator -->
				<!-- principalInvestigators -->
				
				<!-- All in one field -->
				<field name="principalInvestigator"></field>
				<!-- Individual fields -->
				<field name="principalInvestigators"></field>
				
				<!-- place -->
				<!-- placeName -->
				
				<!-- recipient -->
				<!-- recipients -->
				
				
				
				<!-- recipient -->
				<!-- recipients -->
				
				
				
				
				
				<!-- ==============================
				CDRH specific 
				===================================-->
				
				<!-- category -->
				
				
				<field name="category">
					<xsl:text>manuscripts</xsl:text>
				</field>
							
				<!-- subCategory -->
				
				<field name="subCategory">
					<xsl:text>finding_aids</xsl:text>
				</field>
				
				
				<!-- topic -->
				
				
				<!-- keywords -->
				
			
				
				<!-- people -->
				
				
				
				<!-- places -->
				
				
				
				<!-- works -->
				
				
				<!-- ==============================
				Whitman specific 
				===================================-->
		
		
				<!-- work titles and id's -->
				<xsl:for-each select="did/unitid[@type='work']">
					<field name="ead_work_id_ss">
						<xsl:value-of select="."/>
					</field>
					
					<field name="ead_work_title_ss">
						<xsl:text>Go into work files to get titles - </xsl:text><xsl:value-of select="."/>
					</field>
				</xsl:for-each>
				
				<!-- genre -->	
				<xsl:for-each select="did/physdesc/genreform">
					<field name="genre_ss">
						<xsl:value-of select="."></xsl:value-of>
					</field>
				</xsl:for-each>
		
		<!-- box -->	
		<xsl:if test="did/container[@type='box']">
			<field name="box_s">
				<xsl:value-of select="did/container[@type='box']"/>
			</field>
		</xsl:if>
		
		<!-- folder -->	
		
		<xsl:if test="did/container[@type='folder']">
			<field name="folder_s">
				<xsl:value-of select="did/container[@type='folder']"></xsl:value-of>
			</field>
		</xsl:if>
		
		<!-- physical description -->
		
		<field name="physical_description_s">
			<xsl:value-of select="did/physdesc/extent"/>
			<xsl:text>, </xsl:text>
			<xsl:value-of select="did/physdesc/physfacet"/>
		</field>
		
		<!-- ead description -->
		
		<field name="ead_description_s">
			<xsl:apply-templates select="scopecontent"/>
		</field>
		
		<!-- ead images -->
		
		<xsl:for-each select="dao">
			<field name="ead_images_ss">
				<xsl:value-of select="@href"/>
			</field>
		</xsl:for-each>
		
		
			
				
				
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

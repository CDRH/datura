<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.vraweb.org/vracore4.htm"
	xmlns:tei="http://www.tei-c.org/ns/1.0">
	<xsl:output indent="yes"/>
	
	
	
	<!-- Fields -->
	
	<!-- 
id
   image_id
   image_path
   path
   type
   subtype
   title
   date
   date_sort
   place
   repository
   creator
   creator_sort
	-->
	
<xsl:template match="/">
		<add>
			<doc>
				<field name="id">
					<!-- Get the filename -->
					<xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
					
					<!-- Split the filename using '\.' -->
					<xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
					
					<!-- Remove the file extension -->
					<xsl:value-of select="$filenamepart"/>
				</field>
				
				<field name="image_id">
					
					<xsl:value-of select="/vra/collection[1]/work[1]/image[1]/@id"></xsl:value-of>
	
				</field>
				
				<!--image_path-->
				
				<field name="path">
					<!--<xsl:text>http://whitmanarchive.org/published/LG/</xsl:text>
					<xsl:value-of select="substring(/TEI/teiHeader/fileDesc/notesStmt/note[@target='#dat1'],1,4)"/>
					<xsl:text>/whole.html</xsl:text>-->
				</field>
				
				<field name="type">
					<xsl:text>image</xsl:text>
				</field>
				
				<field name="subtype">
					<xsl:value-of select="/vra/collection[1]/techniqueSet[1]/technique[1]"></xsl:value-of>
				</field>
				
				<field name="title">
					<xsl:value-of select="//title[@type='descriptive']"/>
				</field>
				
				<field name="date">
					<xsl:value-of select="/vra/collection[1]/dateSet[1]/display[1]"></xsl:value-of>
				</field>
				
				<field name="date_sort">
					<xsl:value-of select="/vra/collection[1]/dateSet[1]/date[1]/earliestDate[1]"></xsl:value-of>
				</field>

				
				<field name="place">
					<xsl:value-of select="/vra/collection[1]/subjectSet[1]/subject/term[@type='geographicPlace']"></xsl:value-of>
				</field>
				
				<!--repository-->
				
				
				<xsl:for-each select="/vra/collection/agentSet/agent">
					<field name="creator">
					<xsl:value-of select="normalize-space(name)"/>
					</field>
				</xsl:for-each>
				
				<!--<field name="creator">
					<xsl:value-of select="/vra/collection[1]/agentSet[1]/agent[1]/name[1]"></xsl:value-of>
				</field>-->
				
				<field name="creator_sort"><xsl:for-each select="/vra/collection/agentSet/agent">
						<xsl:value-of select="normalize-space(name)"/>
					<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
				</xsl:for-each>
				</field>
				
				
				
				
				
				<field name="text">
					<xsl:value-of select="/vra"/>
				</field>
			</doc>
		</add>
	
</xsl:template>	
				
</xsl:stylesheet>

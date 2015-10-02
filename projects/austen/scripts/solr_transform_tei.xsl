<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/">
  <xsl:output indent="yes"/>
  
  <xsl:param name="date"/>
  <xsl:param name="string"/>
  <xsl:param name="site_location"/><!-- will be lassed in from config.yml -->
  <xsl:param name="file_location"/><!-- will be lassed in from config.yml -->
  <xsl:param name="project" select="/TEI/teiHeader/fileDesc/publicationStmt/authority[1]"></xsl:param>
  <xsl:param name="slug"/><!-- will be lassed in from config.yml -->
  <!-- <xsl:include href="../stylesheets/xslt/common.xsl"/> -->
  <xsl:include href="../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"/>
  <!--<xsl:include href="../xsl/common.xsl"/>-->
  
  <!-- 
  List of fields:
    id
    novel
    speaker_id
    speaker_name
    age
    occupation
    sex
    class_status
    marriage_status
    character_type
    mode_of_speech*
    chapter
    text
  
  -->
  

  
  <xsl:template match="/">
    <add>
      <xsl:for-each select="//said">
        <doc>
          <field name="id">
            <!-- Get the filename -->
            <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
            
            <!-- Split the filename using '\.' -->
            <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
            
            <!-- Remove the file extension -->
            <xsl:value-of select="$filenamepart"/>
            
            <xsl:text>_</xsl:text>
            <xsl:number format="00001" level="any"/>
          </field>
          
          <xsl:variable name="title" select="/TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@type='main']"/>
          <xsl:variable name="title_normalized" select="replace(lower-case($title), ' ', '_')"/>
          <field name="novel">
            <xsl:value-of select="$title_normalized"/>
          </field>




          
          <field name="chapter"><xsl:value-of select="ancestor::div/@n"/></field>
          
          <field name="said_no"><xsl:number format="00001" level="any"/></field>
          
          <field name="speaker_id"><xsl:value-of select="@who"/></field>
          
          <field name="speaker_name">
            <!-- Some speakers do not have personography entries, so will put in Unknown so there is a speaker everywhere -->
            <xsl:variable name="speaker"><xsl:value-of select="@who"/></xsl:variable>
            <xsl:choose>
              <xsl:when test="//person[@xml:id = $speaker]">
                <xsl:value-of select="normalize-space(//person[@xml:id = $speaker]/persName)"/>
              </xsl:when>
              <xsl:otherwise>Unknown</xsl:otherwise>
            </xsl:choose>
            
            
          </field>
          
          <xsl:variable name="who"><xsl:value-of select="@who"/></xsl:variable>
          <xsl:for-each select="//person[@xml:id = $who]/age">
            <field name="age">
            <xsl:value-of select="normalize-space(.)"></xsl:value-of>
            </field>
          </xsl:for-each>
          

          <xsl:for-each select="//person[@xml:id = $who]/occupation">
            <field name="occupation">
              <xsl:value-of select="normalize-space(.)"></xsl:value-of>
            </field>
          </xsl:for-each>
          

          <xsl:for-each select="//person[@xml:id = $who]/sex">
            <field name="sex">
              <xsl:value-of select="normalize-space(.)"></xsl:value-of>
            </field>
          </xsl:for-each>
          

          <xsl:for-each select="//person[@xml:id = $who]/socecStatus">
            <field name="class_status">
              <xsl:value-of select="normalize-space(.)"></xsl:value-of>
            </field>
          </xsl:for-each>
          

          <xsl:for-each select="//person[@xml:id = $who]/state">
            <field name="marriage_status">
              <xsl:value-of select="normalize-space(.)"></xsl:value-of>
            </field>
          </xsl:for-each>


          <xsl:for-each select="//person[@xml:id = $who]/trait">
            <field name="character_type">
              <xsl:value-of select="normalize-space(.)"></xsl:value-of>
            </field>
          </xsl:for-each>
          
          <!-- FID -->
          <xsl:if test="contains(@who,'nar') and @direct = 'false' and descendant::certainty">
            <field name="mode_of_speech">
              <xsl:text>fid</xsl:text>
            </field>
          </xsl:if>
          <!-- Indirect -->
          <xsl:if test="@direct = 'false' and descendant::certainty">
            <field name="mode_of_speech">
              <xsl:text>indirect</xsl:text>
            </field>
          </xsl:if>
        
        
        <field name="text">
          <xsl:value-of select="normalize-space(.)"></xsl:value-of>
        </field>
      </doc>
      </xsl:for-each>
      
    </add>
    
  </xsl:template>
  
</xsl:stylesheet>

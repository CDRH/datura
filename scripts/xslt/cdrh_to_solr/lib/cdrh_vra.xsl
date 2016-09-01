<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:vra="http://www.vraweb.org/vracore4.htm"
  xpath-default-namespace="http://www.vraweb.org/vracore4.htm"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:template match="/" exclude-result-prefixes="#all">
    <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
    
    <!-- Split the filename using '\.' -->
    <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
    
    <xsl:call-template name="vra_template">
      <xsl:with-param name="filenamepart" select="$filenamepart"/>
    </xsl:call-template>
    
  </xsl:template>

  <!-- api schema -->

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
  <!-- image_id -->
  
  
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
  
  <!-- ==============================
  Other Elements 
  ===================================-->
  
  <!-- principalInvestigator -->
  <!-- principalInvestigators -->
  <!-- place -->
  <!-- placeName -->
  <!-- recipient -->
  <!-- recipients -->
  
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
  <!-- fig_location -->
  
  
  <!-- ==================================================================== -->
  <!--                        BUILD THE SOLR REQUEST                        -->
  <!-- ==================================================================== -->

  <xsl:template name="vra_template" exclude-result-prefixes="#all">
    <xsl:param name="filenamepart"/>
    
    <add>
      
      <doc>
        
        <!-- ==============================
        resource identification 
        ===================================-->
        
        <!-- id -->
        <xsl:call-template name="id">
          <xsl:with-param name="id" select="$filenamepart"/>
        </xsl:call-template>
        
        <!-- slug -->
        <xsl:call-template name="slug"/>
        
        <!-- project -->
        <xsl:call-template name="project"/>
        
        <!-- uri -->
        <xsl:call-template name="uri">
          <xsl:with-param name="id" select="$filenamepart"/>
        </xsl:call-template>
        
        <!-- uriXML -->
        <xsl:call-template name="uriXML">
          <xsl:with-param name="id" select="$filenamepart"/>
        </xsl:call-template>
        
        <!-- uriHTML -->
        <xsl:call-template name="uriHTML">
          <xsl:with-param name="id" select="$filenamepart"/>
        </xsl:call-template>
        
        <!-- image_id -->
        <xsl:call-template name="image_id"/>

        <!-- dataType -->
        <field name="dataType"> 
          <xsl:text>vra</xsl:text>
        </field>

        <!-- ==============================
        Dublin Core 
        ===================================-->
        
        <!-- title and titleSort-->
        <xsl:call-template name="title"/>

        <!-- creator -->
        <!-- creators -->
        <xsl:call-template name="creators"/>
        
        <!-- subject -->
        <!-- subjects -->
        <!-- description -->
        <!-- publisher -->
        <!--<xsl:call-template name="publisher"/>-->

        <!-- contributor -->
        <!-- contributors -->
        <xsl:call-template name="contributors"/>
        
        <!-- date and dateDisplay-->
        <xsl:call-template name="date"/>
        
        <!-- type -->
        
        <!-- format -->
        <xsl:call-template name="format"/>
        
        <!-- medium -->
        <!-- extent -->
        
        <!-- language -->
        <!-- relation -->
        <!-- coverage -->
        <!-- source -->
        <!--<xsl:call-template name="source"/>-->
        
        <!-- rightsHolder -->
        <!--<xsl:call-template name="rightsHolder"/>-->
        
        <!-- rights -->
        <!-- rightsURI -->
        <!--<xsl:call-template name="rightsURI"/>-->
        
        <!-- ==============================
        Other elements 
        ===================================-->
        
        <!-- principalInvestigator -->
        <!-- principalInvestigators -->
        <!--<xsl:call-template name="investigators"/>-->
        
        <!-- place -->
        <!-- placeName -->
        <xsl:call-template name="placeName"/>
        
        <!-- recipient -->
        <!-- recipients -->
        <!--<xsl:call-template name="recipients"/>-->
        
        
        <!-- ==============================
        CDRH specific 
        ===================================-->
        
        <!-- category -->
        <xsl:call-template name="category"/>
        
        <!-- subCategory -->
        <xsl:call-template name="subCategory"/>        
        
        <!-- topic -->
        <!--<xsl:call-template name="topic"/>-->
        
        <!-- keywords -->
        <!--<xsl:call-template name="keywords"/>-->
        
        <!-- people -->
        <!--<xsl:call-template name="people"/>-->
        
        <!-- places -->
        <xsl:call-template name="places"/>
        
        <!-- works -->
        <!--<xsl:call-template name="works"/>-->
        
        <!-- text -->
        <xsl:call-template name="text"/>
        
        <!-- fig_location -->
        <!--<xsl:call-template name="fig_location"/>-->


        <!-- ==============================
        Project specific 
        ===================================-->

        <!-- extra fields -->
        <xsl:call-template name="extras"/>
          <!-- because you really need some fancy field
               with an underscore like planet_class_s -->
      </doc>
    </add>

  </xsl:template>

  <!-- ==================================================================== -->
  <!-- ==================================================================== -->
  <!-- ==================================================================== -->
  <!--                         FIELD TEMPLATES                              -->
  <!-- ==================================================================== -->
  <!-- ==================================================================== -->
  <!-- ==================================================================== -->

  <!-- ========== id ========== -->

  <xsl:template name="id">
    <xsl:param name="id"/>
    <field name="id">
      <xsl:value-of select="$id"/>
    </field>
  </xsl:template>

  <!-- ========== slug ========== -->

  <xsl:template name="slug">
    <field name="slug">
      <xsl:value-of select="$slug"/>
    </field>
  </xsl:template>

  <!-- ========== project ========== -->

  <xsl:template name="project">
    <field name="project">
      <xsl:value-of select="$project"/>
    </field>
  </xsl:template>

  <!-- ========== uri ========== -->

  <xsl:template name="uri">
    <xsl:param name="id"/>
    <field name="uri">
      <xsl:value-of select="$site_url"/>
      <xsl:text>/doc/</xsl:text>
      <xsl:value-of select="$id"/>
    </field>
  </xsl:template>

  <!-- ========== uriXML ========== -->

  <xsl:template name="uriXML">
    <xsl:param name="id"/>
    <field name="uriXML">
      <xsl:value-of select="$file_location"/>
      <xsl:value-of select="$slug"/>
      <xsl:text>/tei/</xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text>.xml</xsl:text>
    </field>
  </xsl:template>

  <!-- ========== uriHTML ========== -->

  <xsl:template name="uriHTML">
    <xsl:param name="id"/>
    <field name="uriHTML">
      <xsl:value-of select="$file_location"/>
      <xsl:value-of select="$slug"/>
      <xsl:text>/html-generated/</xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text>.txt</xsl:text>
    </field>
  </xsl:template>

  <!-- ========== image_id ========== -->

  <xsl:template name="image_id">
    <field name="image_id">
      <xsl:value-of select="/vra/collection[1]/work[1]/image[1]/@id"/>
    </field>
  </xsl:template>

  <!-- ==================================================================== -->
  <!--                             DUBLIN CORE                              -->
  <!-- ==================================================================== -->

  <!-- ========== title and titleSort ========== -->

  <xsl:template name="title">
    <xsl:variable name="title">
      <xsl:value-of select="//title[@type='descriptive']"/>
    </xsl:variable>
    
    <field name="title">
      <xsl:value-of select="$title"/>
    </field>

    <field name="titleSort">
      <xsl:call-template name="normalize_name">
        <xsl:with-param name="string">
          <xsl:value-of select="$title"/>
        </xsl:with-param>
      </xsl:call-template>
    </field>
  </xsl:template>

  <!-- ========== creator and creators ========== -->

  <xsl:template name="creators">
    <!-- not yet handling multiple creator -->
    <xsl:value-of select="normalize-space(name)"/>
  </xsl:template>

  <!-- ========== publisher ========== -->

  <xsl:template name="publisher">
    <!-- not yet handling publisher -->
  </xsl:template>

  <!-- ========== contributors ========== -->

  <xsl:template name="contributors">
    <!-- not yet handling contributors -->
  </xsl:template>

  <!-- ========== date and dateDisplay ========== -->

  
  <xsl:template name="date">
    
    <!-- could probably use more robust handling -->
    <field name="date">
      <xsl:value-of select="/vra/collection[1]/dateSet[1]/date[1]/earliestDate[1]"/>
    </field>
    
    
    <field name="dateDisplay">
      <xsl:value-of select="/vra/collection[1]/dateSet[1]/display[1]"/>
    </field>
  </xsl:template>

  <!-- ========== format ========== -->

  <xsl:template name="format">
    <field name="format">
       <xsl:value-of select="/vra/collection[1]/techniqueSet[1]/technique[1]"></xsl:value-of>
    </field>
  </xsl:template>

  <!-- ========== source ========== -->

  <xsl:template name="source">
    <!-- not yet handling source -->
  </xsl:template>

  <!-- ========== rightsHolder ========== -->

  <xsl:template name="rightsHolder">
    <!-- not yet handling rightsHolder -->
  </xsl:template>

  <!-- ========== rightsURI ========== -->

  <xsl:template name="rightsURI">
    <!-- not yet handling rightsHolder -->
  </xsl:template>

  <!-- ========== investigator and investigators ========== -->

  <xsl:template name="investigators">
    <!-- not yet handling investigators -->
  </xsl:template>

  <!-- ========== recipient and recipients ========== -->

  <xsl:template name="recipients">
    <!-- vra will probably not use this -->
  </xsl:template>
  
  <!-- ========== place and placeName ========== -->
  
  <xsl:template name="placeName">
    <!-- currently repeated in places -->
    <xsl:value-of select="/vra/collection[1]/subjectSet[1]/subject/term[@type='geographicPlace']"/>
  </xsl:template>


  <!-- ==================================================================== -->
  <!--                         CDRH SPECIFIC FIELDS                         -->
  <!-- ==================================================================== -->

  <!-- ========== category ========== -->

  <xsl:template name="category">
    <!-- this is whitman specific right now, may want to reconsider how it is used -->
    <field name="category">
      <xsl:text>image</xsl:text>
    </field>
  </xsl:template>

  <!-- ========== subCategory ========== -->

  <xsl:template name="subCategory">
    <field name="subCategory">
      <!-- not yet handling subCategory -->
    </field>
  </xsl:template>

  <!-- ========== topic ========== -->

  <xsl:template name="topic">
    <!-- not yet handling topic  -->
  </xsl:template>

  <!-- ========== keywords ========== -->

  <xsl:template name="keywords">
    <!-- not yet handling keywords -->
  </xsl:template>

  <!-- ========== people ========== -->

  <xsl:template name="people">
    <!-- not yet handling people -->
  </xsl:template>

  <!-- ========== places ========== -->

  <xsl:template name="places">
        <field name="places">
          <xsl:value-of select="/vra/collection[1]/subjectSet[1]/subject/term[@type='geographicPlace']"/>
        </field>
  </xsl:template>

  <!-- ========== works ========== -->

  <xsl:template name="works">
    <!-- not yet handling works -->
  </xsl:template>

  <!-- ========== text ========== -->

  <xsl:template name="text">
    <xsl:value-of select="/vra"/>
  </xsl:template>

  <!-- ========== fig_location ========== -->

  <xsl:template name="fig_location">
    <!-- not yet handling fig_location -->
  </xsl:template>

  <!-- ==================================================================== -->
  <!--                     PROJECT SPECIFIC FIELDS                          -->
  <!-- ==================================================================== -->

  <xsl:template name="extras"/>  <!-- blank by default, override in specific projects -->

</xsl:stylesheet>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="#all">

  <xsl:template match="/" exclude-result-prefixes="#all">
    <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
    
    <!-- Split the filename using '\.' -->
    <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
    
    <xsl:call-template name="tei_template">
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

  <xsl:template name="tei_template" exclude-result-prefixes="#all">
    <xsl:param name="filenamepart"/>
    
    <add>
      <xsl:if test="contains($filenamepart, 'person')">
        <xsl:call-template name="personography">
          <xsl:with-param name="filenamepart" select="$filenamepart"/>
        </xsl:call-template>
      </xsl:if>
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
          <xsl:text>tei</xsl:text>
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
        <xsl:call-template name="publisher"/>

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
        <xsl:call-template name="source"/>
        
        <!-- rightsHolder -->
        <xsl:call-template name="rightsHolder"/>
        
        <!-- rights -->
        <!-- rightsURI -->
        <xsl:call-template name="rightsURI"/>
        
        <!-- ==============================
        Other elements 
        ===================================-->
        
        <!-- principalInvestigator -->
        <!-- principalInvestigators -->
        <xsl:call-template name="investigators"/>
        
        <!-- place -->
        <!-- placeName -->
        
        <!-- recipient -->
        <!-- recipients -->
        <xsl:call-template name="recipients"/>
        
        
        <!-- ==============================
        CDRH specific 
        ===================================-->
        
        <!-- category -->
        <xsl:call-template name="category"/>
        
        <!-- subCategory -->
        <xsl:call-template name="subCategory"/>        
        
        <!-- topic -->
        <xsl:call-template name="topic"/>
        
        <!-- keywords -->
        <xsl:call-template name="keywords"/>
        
        <!-- people -->
        <xsl:call-template name="people"/>
        
        <!-- places -->
        <xsl:call-template name="places"/>
        
        <!-- works -->
        <xsl:call-template name="works"/>
        
        <!-- text -->
        <xsl:call-template name="text"/>
        
        <!-- fig_location -->
        <xsl:call-template name="fig_location"/>


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
      <xsl:text>/docs/</xsl:text>
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
      <xsl:if test="//pb">
        <xsl:value-of select="(//pb)[1]/@facs"/>
      </xsl:if>
    </field>
  </xsl:template>

  <!-- ==================================================================== -->
  <!--                             DUBLIN CORE                              -->
  <!-- ==================================================================== -->

  <!-- ========== title and titleSort ========== -->

  <xsl:template name="title">
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
  </xsl:template>

  <!-- ========== publisher ========== -->

  <xsl:template name="publisher">
    <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1] and /TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1] != ''">
      <field name="publisher">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]"></xsl:value-of>
      </field>
    </xsl:if>
  </xsl:template>

  <!-- ========== contributors ========== -->

  <xsl:template name="contributors">
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
  </xsl:template>

  <!-- ========== date and dateDisplay ========== -->

  <xsl:template name="date">
    <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when">
      <xsl:variable name="doc_date">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when"/>
      </xsl:variable>
      <field name="date">
        <xsl:call-template name="date_standardize">
          <xsl:with-param name="datebefore">
            <xsl:value-of select="substring($doc_date,1,10)"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>T00:00:00Z</xsl:text>
      </field>
      <!-- dateDisplay -->
      <field name="dateDisplay">
        <xsl:call-template name="extractDate">
          <xsl:with-param name="date" select="$doc_date"/>
        </xsl:call-template>
      </field>
    </xsl:if>
  </xsl:template>

  <!-- ========== format ========== -->

  <xsl:template name="format">
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
  </xsl:template>

  <!-- ========== source ========== -->

  <xsl:template name="source">
    <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='j'] != ''">
      <field name="source">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='j']"/>
      </field>
    </xsl:if>
  </xsl:template>

  <!-- ========== rightsHolder ========== -->

  <xsl:template name="rightsHolder">
    <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository[1] != ''">
      <field name="rightsHolder">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository"/>
      </field>
    </xsl:if>
  </xsl:template>

  <!-- ========== rightsURI ========== -->

  <xsl:template name="rightsURI"/>

  <!-- ========== investigator and investigators ========== -->

  <xsl:template name="investigators">
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
  </xsl:template>

  <!-- ========== recipient and recipients ========== -->

  <xsl:template name="recipients">
    <xsl:if test="/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName != ''">
      <field name="recipient">
        <xsl:value-of select="/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName"/>
      </field>
      <field name="recipients">
        <xsl:value-of select="/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName"/>
      </field>
    </xsl:if>
  </xsl:template>


  <!-- ==================================================================== -->
  <!--                         CDRH SPECIFIC FIELDS                         -->
  <!-- ==================================================================== -->

  <!-- ========== category ========== -->

  <xsl:template name="category">
    <xsl:choose>
      <xsl:when test="/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term">
        <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term">
          <xsl:if test="normalize-space(.) != ''">
            <field name="category">
              <xsl:value-of select="."/>
            </field>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <field name="category">texts</field>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ========== subCategory ========== -->

  <xsl:template name="subCategory">
    <xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term">
      <xsl:if test="normalize-space(.) != ''">
        <field name="subCategory">
          <xsl:value-of select="."/>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ========== topic ========== -->

  <xsl:template name="topic">
    <xsl:for-each
      select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term">
      <xsl:if test="normalize-space(.) != ''">
        <field name="topic">
          <xsl:value-of select="."/>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ========== keywords ========== -->

  <xsl:template name="keywords">
    <xsl:for-each
      select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term">
      <xsl:if test="normalize-space(.) != ''">
        <field name="keywords">
          <xsl:value-of select="."/>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ========== people ========== -->

  <xsl:template name="people">
    <xsl:for-each
      select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term">
      <xsl:if test="normalize-space(.) != ''">
        <field name="people">
          <xsl:value-of select="."/>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ========== places ========== -->

  <xsl:template name="places">
    <xsl:for-each
      select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term">
      <xsl:if test="normalize-space(.) != ''">
        <field name="places">
          <xsl:value-of select="."/>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ========== works ========== -->

  <xsl:template name="works">
    <xsl:for-each
      select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term">
      <xsl:if test="normalize-space(.) != ''">
        <field name="works">
          <xsl:value-of select="."/>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ========== text ========== -->

  <xsl:template name="text">
    <field name="text">
      <xsl:for-each select="//text">
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </field>
  </xsl:template>

  <!-- ========== fig_location ========== -->

  <xsl:template name="fig_location">
    <xsl:if test="$fig_location">
      <field name="fig_location_s">
        <xsl:value-of select="$fig_location"/>
      </field>
    </xsl:if>
  </xsl:template>

  <!-- ==================================================================== -->
  <!--                     PROJECT SPECIFIC FIELDS                          -->
  <!-- ==================================================================== -->

  <xsl:template name="extras"/>  <!-- blank by default, override in specific projects -->

</xsl:stylesheet>
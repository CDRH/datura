<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0"
  exclude-result-prefixes="xsl tei xs">

<!-- ==================================================================== -->
<!--                          PERSONOGRAPHY                               -->
<!-- ==================================================================== -->

<xsl:template match="TEI[contains(@xml:id, 'person')]//body">
  <xsl:apply-templates select="div1[@type='introduction']"/>
  <div class="list">
    <ul class="life_item">
      <xsl:for-each select="//person">
        <xsl:sort select="@xml:id"/>
        <li>
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="persName[@type='display']"/>
            </xsl:attribute>
            <xsl:value-of select="persName[@type='display']"/>
          </a>
        </li>
      </xsl:for-each>
    </ul>
      
    <xsl:for-each select="//person">
      <xsl:sort select="@xml:id"/>
      <xsl:call-template name="person_info"/>
    </xsl:for-each>

    <!-- this is the same as the above but written to a specific file -->
    <xsl:for-each select="//person">
      <!-- the filename will start relative to the html-generated (output) directory of a specific project -->
      <xsl:variable name="filename" select="concat(@xml:id, '.txt')"/>
      <xsl:result-document href="{$filename}">
        <xsl:call-template name="person_info"/>
      </xsl:result-document>
    </xsl:for-each>
  </div>
</xsl:template>
    
<xsl:template name="person_info">
  <div>
    <xsl:attribute name="class">
      <xsl:text>life_item</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="id">
      <xsl:value-of select="@xml:id"/>
    </xsl:attribute>
    <h3>
      <a>
        <xsl:attribute name="class">persNameLink</xsl:attribute>
        <xsl:attribute name="href"><xsl:value-of select="$site_url"/>/doc/<xsl:value-of select="@xml:id"/></xsl:attribute>
       <xsl:value-of select="persName[@type='display']"/>
      </a>
    </h3>
    <p><xsl:apply-templates select="note"/></p>
  </div>
</xsl:template>

<!-- ==================================================================== -->
<!--                           ENCYCLOPEDIA                               -->
<!-- ==================================================================== -->

<xsl:template match="TEI[contains(@xml:id, 'encyc')]//div1">
  <ul class="life_item">
    <xsl:for-each select="div2">
      <xsl:sort select="@xml:id"/>
      <li>
        <a>
          <xsl:attribute name="href">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="@xml:id"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="head"/>
          </xsl:attribute>
          <xsl:value-of select="head"/>
        </a>
      </li>
    </xsl:for-each>
  </ul>
    
  <xsl:for-each select="div2">
    <xsl:sort select="@xml:id"/>
    <xsl:call-template name="encyc_info"/>
  </xsl:for-each>

  <!-- encyclopedia entries are not currently indexed to solr and so do
       not have their own page view -->
</xsl:template>

<xsl:template name="encyc_info">
  <div>
    <xsl:attribute name="class">
      <xsl:text>life_item</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="id">
      <xsl:value-of select="@xml:id"/>
    </xsl:attribute>
    <h3>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="$site_url"/>
          <!-- construct a search url and use quotation marks (%22) on either side of the term -->
          <xsl:value-of select="concat('/search?fqfield=text&amp;fqtext=%22', head, '%22')"/>
        </xsl:attribute>
        <xsl:value-of select="head"/>
      </a>
    </h3>
    <xsl:apply-templates select="p"/>
  </div>
</xsl:template>

</xsl:stylesheet>
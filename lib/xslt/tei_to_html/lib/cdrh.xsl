<?xml version="1.0"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0"
  exclude-result-prefixes="xsl tei xs">

  <!-- ==================================================================== -->
  <!-- =========================== TEMPLATES  =============================  -->
  <!-- ==================================================================== -->
  
  <xsl:template match="text">
    <div class="main_content">
      <xsl:apply-templates/>
      <xsl:if test="//note[@place='foot']">
        <br/>
        <hr/>
      </xsl:if>
      <xsl:if test="//note[@place='foot']">
        <div class="footnotes">
          <xsl:text> </xsl:text>
          <xsl:for-each select="//note[@place='foot']">
            <p>
              <span class="notenumber"><xsl:value-of select="substring(@xml:id, 2)"/>.</span>
              <xsl:text> </xsl:text>
              <xsl:apply-templates/>
              <xsl:text> </xsl:text>
              <a>
                <xsl:attribute name="href">
                  <xsl:text>#</xsl:text>
                  <xsl:text>body</xsl:text>
                  <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
                <xsl:attribute name="id">
                  <xsl:text>foot</xsl:text>
                  <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
                <xsl:text>[back]</xsl:text>
              </a>
            </p>
          </xsl:for-each>
        </div>
      </xsl:if>
    </div>
  </xsl:template>
  
  <!-- people's names link to their solr entry -->
  <xsl:template match="persName">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@xml:id">
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="$site_url"/>/doc/<xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
      
    </span>
  </xsl:template>

  <!-- link places to search results -->
  <xsl:template match="placeName ">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="$site_url"/>/search/qfield=text&amp;qtext=<xsl:value-of select="text()"/>
        </xsl:attribute>
        <xsl:value-of select="text()"/>
      </a>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- ===================================================================================
    TEMPLATES: Param controlled
    =================================================================================== -->
  
  

  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Figures
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="figure">
      <xsl:choose>
        <!-- Is this specific to everyweek, should it be in here? -KMD -->
        <xsl:when test="@n='flag'"></xsl:when>
        <xsl:otherwise>
          <div class="inline_figure">
            <div class="p">[illustration]</div>
            <xsl:apply-templates/></div>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Page breaks and page images
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

  <xsl:template name="url_builder">
    <xsl:param name="figure_id_local"/> 
    <xsl:param name="image_size_local"/>
    <xsl:param name="iiif_path_local"/>
    <xsl:value-of select="$media_base"/>
    <xsl:text>/iiif/2/</xsl:text>
    <xsl:value-of select="$iiif_path_local"/>
    <xsl:text>%2F</xsl:text>
    <xsl:value-of select="$figure_id_local"/>
    <xsl:text>.jpg/full/!</xsl:text>
    <xsl:value-of select="$image_size_local"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$image_size_local"/>
    <xsl:text>/0/default.jpg</xsl:text>
  </xsl:template>

  <!-- needed because of the "open in a new window" link which is pulled 
       from the title attribute on a photo using pretty photo -->
  <xsl:template name="url_builder_escaped">
    <xsl:param name="figure_id_local"/> 
    <xsl:param name="image_size_local"/>
    <xsl:param name="iiif_path_local"/>
    <xsl:value-of select="$media_base"/>
    <xsl:text>/iiif/2/</xsl:text>
    <xsl:value-of select="$iiif_path_local"/>
    <xsl:text>%252F</xsl:text><!-- %2F Must be double encoded or it comes out as / -->
    <xsl:value-of select="$figure_id_local"/>
    <xsl:text>.jpg/full/!</xsl:text>
    <xsl:value-of select="$image_size_local"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$image_size_local"/>
    <xsl:text>/0/default.jpg</xsl:text>
  </xsl:template>
  
  <xsl:template match="pb">
      <!-- grab the figure id, first looking in @facs, then @xml:id, and if there is a .jpg, chop it off -->
      <xsl:variable name="figure_id">
        <xsl:variable name="figure_id_full">
          <xsl:choose>
            <xsl:when test="@facs"><xsl:value-of select="@facs"></xsl:value-of></xsl:when>
            <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"></xsl:value-of></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="ends-with($figure_id_full,'.jpg') or ends-with($figure_id_full,'.jpeg')">
            <xsl:value-of select="substring-before($figure_id_full,'.jp')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$figure_id_full"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <span class="hr">&#160;</span>
      <xsl:if test="$figure_id != ''">
        <span>
          <xsl:attribute name="class">
            <xsl:text>pageimage</xsl:text>
          </xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="url_builder">
                <xsl:with-param name="figure_id_local" select="$figure_id"/>  
                <xsl:with-param name="image_size_local" select="$image_large"/>
                <xsl:with-param name="iiif_path_local" select="$collection"/> 
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="rel">
              <xsl:text>prettyPhoto[pp_gal]</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:text>&lt;a href=&#34;</xsl:text>
              <xsl:call-template name="url_builder_escaped">
                <xsl:with-param name="figure_id_local" select="$figure_id"/>  
                <xsl:with-param name="image_size_local" select="$image_large"/>
                <xsl:with-param name="iiif_path_local" select="$collection"/>
              </xsl:call-template>
              <xsl:text>" target="_blank" &gt;open image in new window&lt;/a&gt;</xsl:text>
            </xsl:attribute>
            
            <img>
              <xsl:attribute name="src">
                <xsl:call-template name="url_builder">
                  <xsl:with-param name="figure_id_local" select="$figure_id"/> 
                  <xsl:with-param name="image_size_local" select="$image_thumb"/>
                  <xsl:with-param name="iiif_path_local" select="$collection"/>
                </xsl:call-template>
              </xsl:attribute>
              <xsl:attribute name="class">
                <xsl:text>display&#160;</xsl:text>
              </xsl:attribute>
            </img>
          </a>
        </span>
      </xsl:if>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Notes / Footnotes
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="note">
    <xsl:choose>
      <xsl:when test="@place='foot'">
        <span>
          <xsl:attribute name="class">
            <xsl:text>foot</xsl:text>
          </xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:text>foot</xsl:text>
              <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="id">
              <xsl:text>body</xsl:text>
              <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            
            <xsl:text>(</xsl:text>
            <xsl:value-of select="substring(@xml:id, 2)"/>
            <xsl:text>)</xsl:text>
          </a>
        </span>
      </xsl:when>
      <xsl:when test="@type='editorial'"/>
      <xsl:otherwise>
        <div>
          <xsl:attribute name="class">
            <xsl:value-of select="name()"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    References
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <!-- we need a better way to determine when references are notes, when they are internal to the site, and then they are external links -->
  <xsl:template match="ref">
    <xsl:choose>
      <!-- When target starts with #, assume it is an in page link (anchor) -->
      <xsl:when test="starts-with(@target, '#')">
        <xsl:variable name="n" select="@target"/>
        <xsl:text> </xsl:text>
        <a>
          <xsl:attribute name="id">
            <xsl:text>ref</xsl:text>
            <xsl:value-of select="@target"/>
          </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:text>inlinenote</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="href">
            <xsl:text>#note</xsl:text>
            <xsl:value-of select="@target"/>
          </xsl:attribute>
          <xsl:text>[note </xsl:text>
          <xsl:apply-templates/>
          <xsl:text>]</xsl:text>
        </a>
        <xsl:text> </xsl:text>
      </xsl:when>
      <!-- when marked as link, treat as an external link -->
      <xsl:when test="@type='link'">
        <a href="{@target}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <!-- external link -->
      <xsl:when test="starts-with(@target, 'http://') or starts-with(@target, 'https://')">
        <a href="{@target}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <!-- if the above are not true, it is assumed to be an internal to the site link -->
      <xsl:when test="@type='sitelink'">
        <a href="../{@target}" class="internal_link">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <!-- the below will generate a footnote / in page link -->
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="concat('#', @target)"/>
          </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:text>internal_link</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>

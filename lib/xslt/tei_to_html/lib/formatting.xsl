<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0"
  exclude-result-prefixes="xsl tei xs">

  <!-- ================================================ -->
  <!--             GENERIC CLASS TEMPLATE               -->
  <!-- ================================================ -->

  <!-- this template is used to generate a list of classes that 
    represent all the attributes and values on a tag for instance, 
    <fw type="pageNum test" place="top"> would render as "tei_fw_type_pageNum tei_fw_type_test tei_fw_place_top tei_fw" -->
  <!-- line returns or spaces are passed through to attributes so are removed -->

  <xsl:template name="add_attributes">
    <xsl:if test="@*">
      <xsl:for-each select="@*">
        <xsl:variable name="att_prefix">
          <xsl:text>tei_</xsl:text>
          <xsl:value-of select="../name()"/>
          <xsl:text>_</xsl:text>
          <xsl:value-of select="name()"/>
          <xsl:text>_</xsl:text>
        </xsl:variable>
        <xsl:for-each select="tokenize(., ' ')">
          <xsl:value-of select="$att_prefix"/>
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:if>
    <xsl:text>tei_</xsl:text>
    <xsl:value-of select="name()"/>
  </xsl:template>

  <!-- ================================================ -->
  <!--                   ABBREVIATION                   -->
  <!-- ================================================ -->

  <xsl:template match="choice[child::abbr]">
    <a>
      <xsl:attribute name="rel">
        <xsl:text>tooltip</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text>abbr</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:apply-templates select="expan"/>​ </xsl:attribute>
      <xsl:apply-templates select="abbr"/>
    </a>​ </xsl:template>

  <!-- ================================================ -->
  <!--                       ADD                        -->
  <!-- ================================================ -->

  <xsl:template match="add">
    <xsl:choose>
      <xsl:when test="@place = 'superlinear' or @place = 'supralinear'">
        <sup>
          <xsl:apply-templates/>
        </sup>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:attribute name="class">
            <xsl:call-template name="add_attributes"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================ -->
  <!--                      DATES                       -->
  <!-- ================================================ -->

  <xsl:template name="extractDate">
    <xsl:param name="date"/>
    <!--This template converts a date from format YYYY-MM-DD to mm D, YYYY (MM, MM-DD, optional)-->

    <xsl:variable name="YYYY" select="substring($date, 1, 4)"/>
    <xsl:variable name="MM" select="substring($date, 6, 2)"/>
    <xsl:variable name="DD" select="substring($date, 9, 2)"/>

    <xsl:choose>
      <xsl:when test="($DD != '') and ($MM != '') and ($DD != '')">
        <xsl:call-template name="lookUpMonth"><xsl:with-param name="numValue" select="$MM"
          /></xsl:call-template><xsl:text> </xsl:text>
        <xsl:number format="1" value="$DD"/>, <xsl:value-of select="$YYYY"/>
      </xsl:when>
      <xsl:when test="($YYYY != '') and ($MM != '')">
        <xsl:call-template name="lookUpMonth"><xsl:with-param name="numValue" select="$MM"
          /></xsl:call-template>, <xsl:value-of select="$YYYY"/>
      </xsl:when>
      <xsl:when test="($DD != '') and ($MM != '')">
        <xsl:call-template name="lookUpMonth"><xsl:with-param name="numValue" select="$MM"
          /></xsl:call-template>, <xsl:value-of select="$YYYY"/>
      </xsl:when>
      <xsl:when test="($YYYY != '')">
        <xsl:value-of select="$YYYY"/>
      </xsl:when>
      <xsl:otherwise> N.D. </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="lookUpMonth">
    <xsl:param name="numValue"/>
    <xsl:choose>
      <xsl:when test="$numValue = '01'">January</xsl:when>
      <xsl:when test="$numValue = '02'">February</xsl:when>
      <xsl:when test="$numValue = '03'">March</xsl:when>
      <xsl:when test="$numValue = '04'">April</xsl:when>
      <xsl:when test="$numValue = '05'">May</xsl:when>
      <xsl:when test="$numValue = '06'">June</xsl:when>
      <xsl:when test="$numValue = '07'">July</xsl:when>
      <xsl:when test="$numValue = '08'">August</xsl:when>
      <xsl:when test="$numValue = '09'">September</xsl:when>
      <xsl:when test="$numValue = '10'">October</xsl:when>
      <xsl:when test="$numValue = '11'">November</xsl:when>
      <xsl:when test="$numValue = '12'">December</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================ -->
  <!--                      DAMAGE                      -->
  <!-- ================================================ -->

  <xsl:template match="damage">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="@type"/>
      </xsl:attribute>
      <xsl:apply-templates/>
      <xsl:text>[?]</xsl:text>
    </span>
  </xsl:template>

  <!-- ================================================ -->
  <!--                      DELETE                      -->
  <!-- ================================================ -->

  <xsl:template match="del">
    <del>
      <xsl:if test="@*">
        <xsl:attribute name="class">
          <xsl:call-template name="add_attributes"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </del>
  </xsl:template>

  <!-- ================================================ -->
  <!--                  DIV1 and DIV2                   -->
  <!-- ================================================ -->

  <xsl:template match="div1 | div2 | div3 | div4">
    <xsl:choose>
      <xsl:when test="@type = 'html'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:attribute name="class">
            <xsl:value-of select="@type"/>
            <xsl:if test="@subtype">
              <xsl:text> </xsl:text>
              <xsl:value-of select="@subtype"/>
            </xsl:if>
          </xsl:attribute>
          <xsl:if test="@corresp">
            <xsl:attribute name="id">
              <xsl:value-of select="substring-after(@corresp, '#')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================ -->
  <!--                   FIGURES                        -->
  <!-- ================================================ -->

  <xsl:template match="figure">
    <xsl:choose>
      <xsl:when test="@n = 'flag'"/>
      <xsl:otherwise>
        <div class="inline_figure">
          <div class="p">[illustration]</div>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================ -->
  <!--                  FORM WORKS                      -->
  <!-- ================================================ -->

  <!-- try handling in misc below, uncomment if this does not work out -->
  <!--<xsl:template match="fw">
    <xsl:choose>
      <xsl:when test="ancestor::p">
        <span class="h6"><xsl:apply-templates/></span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(@type='sub')">
          <h6>
            <xsl:attribute name="class">
              <xsl:value-of select="name()"/>
            </xsl:attribute>
            <xsl:apply-templates/>
          </h6>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->

  <!-- ================================================ -->
  <!--                        GAP                       -->
  <!-- ================================================ -->

  <xsl:template match="gap">
    <span>
      <xsl:attribute name="class">
        <xsl:call-template name="add_attributes"/>
      </xsl:attribute>
      <xsl:apply-templates/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="@reason"/>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>

  <!-- ================================================ -->
  <!--                       HEADS                      -->
  <!-- ================================================ -->

  <xsl:template match="head">
    <xsl:choose>
      <xsl:when test="ancestor::*[name() = 'p']">
        <span class="head">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="ancestor::*[name() = 'figure']">
        <span class="head">
          <xsl:apply-templates/>
        </span>
      </xsl:when>

      <xsl:when test="//div1">
        <xsl:choose>
          <xsl:when test="//div1/head">
            <xsl:choose>
              <xsl:when test="parent::div1">
                <h3>
                  <xsl:apply-templates/>
                </h3>
              </xsl:when>
              <xsl:when test="parent::div2">
                <h4>
                  <xsl:apply-templates/>
                </h4>
              </xsl:when>
              <xsl:when test="parent::div3">
                <h5>
                  <xsl:apply-templates/>
                </h5>
              </xsl:when>
              <xsl:when test="parent::div4 or parent::div5 or parent::div6 or parent::div7">
                <h6>
                  <xsl:apply-templates/>
                </h6>
              </xsl:when>
              <xsl:otherwise>
                <h4>
                  <xsl:apply-templates/>
                </h4>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="parent::div2">
                <h3>
                  <xsl:apply-templates/>
                </h3>
              </xsl:when>
              <xsl:when test="parent::div3">
                <h4>
                  <xsl:apply-templates/>
                </h4>
              </xsl:when>
              <xsl:when test="parent::div4">
                <h5>
                  <xsl:apply-templates/>
                </h5>
              </xsl:when>
              <xsl:when test="parent::div5 or parent::div6 or parent::div7">
                <h6>
                  <xsl:apply-templates/>
                </h6>
              </xsl:when>
              <xsl:otherwise>
                <h4>
                  <xsl:apply-templates/>
                </h4>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:when test=".[@type = 'sub']">
        <h4>
          <xsl:apply-templates/>
        </h4>
      </xsl:when>
      <xsl:when test="preceding::*[name() = 'head']">
        <h4>
          <xsl:apply-templates/>
        </h4>
      </xsl:when>
      <xsl:otherwise>
        <h3>
          <xsl:apply-templates/>
        </h3>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================ -->
  <!--                 HI and ITALICS                   -->
  <!-- ================================================ -->

  <!-- may need to overwrite both priority 1 and 2 for consistency -->
  <xsl:template match="hi[@rend]" priority="1">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="hi[@rend = 'italic'] | hi[@rend = 'italics']" priority="2">
    <em>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </em>
  </xsl:template>

  <xsl:template match="ab[@rend = 'italics'] | p[@rend = 'italics']">
    <div>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <em>
        <xsl:apply-templates/>
      </em>
    </div>
  </xsl:template>

  <!-- ================================================ -->
  <!--                        HIDE                      -->
  <!-- ================================================ -->

  <xsl:template match="teiHeader | revisionDesc | publicationStmt | sourceDesc | figDesc">
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- ================================================ -->
  <!--           HORIZONTAL RULE (MILESTONE)            -->
  <!-- ================================================ -->

  <xsl:template match="milestone">
    <div>
      <xsl:attribute name="class">
        <xsl:text>milestone </xsl:text>
        <xsl:value-of select="@unit"/>
      </xsl:attribute>
      <xsl:text> </xsl:text>
    </div>
  </xsl:template>

  <!-- ================================================ -->
  <!--                    LINE BREAKS                   -->
  <!-- ================================================ -->

  <xsl:template match="lb">
    <xsl:apply-templates/>
    <br/>
  </xsl:template>

  <!-- ================================================ -->
  <!--                       LINKS                      -->
  <!-- ================================================ -->

  <xsl:template match="xref[@n]">
    <a href="{@n}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <!-- ================================================ -->
  <!--                       LISTS                      -->
  <!-- ================================================ -->
  <!-- need to account for more complicated list structures. For instance, you can have a <p> -->

  <xsl:template match="list">
    <xsl:if test="head">
      <div class="tei_list_head">
        <xsl:apply-templates select="head/node()"/>
      </div>
    </xsl:if>
    <ul>
      <xsl:attribute name="class">
        <xsl:if test="@*">
          <xsl:for-each select="@*">
            <xsl:text>tei_list_</xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </xsl:if>
        <xsl:text>tei_list</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="item"/>
    </ul>
  </xsl:template>

  <xsl:template match="item">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- ================================================ -->
  <!--               MISC -> SPANS OR EMS               -->
  <!-- ================================================ -->

  <xsl:template match="hi[@rend = 'smallcaps'] | hi[@rend = 'roman']" priority="2">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template
    match="term | foreign | emph | title[not(@level = 'a')] | biblScope[@type = 'volume']">
    <em>
      <xsl:attribute name="class">
        <xsl:call-template name="add_attributes"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </em>
  </xsl:template>

  <xsl:template
    match="
      byline | docDate | sp | speaker | letter | fw |
      notesStmt | titlePart | docDate | ab | trailer |
      front | lg | l | bibl | dateline | salute | trailer |
      titlePage | opener | closer | floatingText | date
      | resp | respStmt | name | orgName | label | caption | idno | signed">
    <span>
      <xsl:attribute name="class">
        <xsl:call-template name="add_attributes"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- ================================================ -->
  <!--               NOTES and FOOTNOTES                -->
  <!-- ================================================ -->

  <xsl:template match="note">
    <xsl:choose>
      <xsl:when test="@place = 'foot'">
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
      <xsl:when test="@type = 'editorial'"/>
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

  <!-- ================================================ -->
  <!--                  ORIG AND REG                    -->
  <!-- ================================================ -->

  <!-- to fix - breaks over pagebreaks -KMD -->
  <xsl:template match="choice[child::orig]">
    <!-- Hidden because it breaks over pagebreaks -->
    <!--<a>
    <xsl:attribute name="rel">
      <xsl:text>tooltip</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="class">
      <xsl:text>orig</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="title">
      <xsl:apply-templates select="reg"/>​ </xsl:attribute><xsl:apply-templates select="orig"
    /></a>​-->
    <xsl:apply-templates select="orig"/>
  </xsl:template>

  <!-- ================================================ -->
  <!--                  PAGE BREAKS                     -->
  <!-- ================================================ -->

  <!-- For iiif images -->

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
    <xsl:text>%252F</xsl:text>
    <!-- %2F Must be double encoded or it comes out as / -->
    <xsl:value-of select="$figure_id_local"/>
    <xsl:text>.jpg/full/!</xsl:text>
    <xsl:value-of select="$image_size_local"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$image_size_local"/>
    <xsl:text>/0/default.jpg</xsl:text>
  </xsl:template>

  <xsl:template match="pb">
    <!-- grab the figure id from @facs, and if there is a .jpg, chop it off
          note: I previously also looked at xml:id for figure ID, but that's 
          incorrect -->
    <xsl:variable name="figure_id">
      <xsl:variable name="figure_id_full">
        <xsl:value-of select="normalize-space(@facs)"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="ends-with($figure_id_full, '.jpg') or ends-with($figure_id_full, '.jpeg')">
          <xsl:value-of select="substring-before($figure_id_full, '.jp')"/>
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

  <!-- ================================================ -->
  <!--                    PARAGRAPHS                    -->
  <!-- ================================================ -->

  <!-- todo - this could be better, need to do a full evaluation 
    of things that are not allowed within a p -KMD -->
  <xsl:template match="p">
    <xsl:choose>
      <xsl:when test="descendant::list or descendant::p">
        <div>
          <xsl:attribute name="class">
            <xsl:call-template name="add_attributes"/>
            <xsl:text> p</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:attribute name="class">
            <xsl:call-template name="add_attributes"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================ -->
  <!--                     PERSNAME                     -->
  <!-- ================================================ -->

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

  <!-- ================================================ -->
  <!--                     PLACENAME                    -->
  <!-- ================================================ -->

  <xsl:template match="placeName">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="$site_url"/>/search/qfield=text&amp;qtext=<xsl:value-of
            select="text()"/>
        </xsl:attribute>
        <xsl:value-of select="text()"/>
      </a>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- ================================================ -->
  <!--                   POSITIONING                    -->
  <!-- ================================================ -->

  <xsl:template match="hi[@rend = 'right'] | hi[@rend = 'center']" priority="2">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- ================================================ -->
  <!--                     QUOTES                       -->
  <!-- ================================================ -->

  <xsl:template match="hi[@rend = 'quoted']" priority="2">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="quote">
    <xsl:choose>
      <xsl:when test="descendant::*[name() = 'lg']">
        <blockquote>
          <xsl:apply-templates/>
        </blockquote>
      </xsl:when>
      <xsl:otherwise>
        <blockquote>
          <p>
            <xsl:apply-templates/>
          </p>
        </blockquote>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="q">
    <span class="inline_quote">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- ================================================ -->
  <!--                     REFS                         -->
  <!-- ================================================ -->

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
      <xsl:when test="@type = 'link'">
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
      <xsl:when test="@type = 'sitelink'">
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


  <!-- ================================================ -->
  <!--                       SEG                        -->
  <!-- ================================================ -->

  <!-- Handwritten From CWW - move into collection file? -->
  <xsl:template match="seg[@type = 'handwritten']">
    <span>
      <xsl:attribute name="class">
        <xsl:text>handwritten</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- ================================================ -->
  <!--                       SEG                        -->
  <!-- ================================================ -->

  <xsl:template match="choice[child::corr]">
    <a>
      <xsl:attribute name="rel">
        <xsl:text>tooltip</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text>sic</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="title"><xsl:apply-templates select="corr"/>​</xsl:attribute>
      <xsl:apply-templates select="sic"/>
    </a>
  </xsl:template>

  <!-- ================================================ -->
  <!--                    SIGNATURE                     -->
  <!-- ================================================ -->

  <!--<xsl:template match="//signed">
    <br/>
    <xsl:apply-templates/>
  </xsl:template>-->

  <!-- ================================================ -->
  <!--                     SPACE                        -->
  <!-- ================================================ -->

  <!-- CWW Specific, move into collection stylesheet? -->
  <xsl:template match="space">
    <span class="teispace">
      <xsl:text>[no handwritten text supplied here]</xsl:text>
    </span>
  </xsl:template>

  <!-- ================================================ -->
  <!--                     STRONG/BOLD                  -->
  <!-- ================================================ -->

  <xsl:template match="item/label | hi[@rend = 'bold']">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <!-- ================================================ -->
  <!--              SUPER AND SUB SCRIPT                -->
  <!-- ================================================ -->

  <!-- May need to overwrite both priority 1 and 2 for consistency -->

  <xsl:template match="hi[@rend = 'subscript']" priority="2">
    <sub>
      <xsl:apply-templates/>
    </sub>
  </xsl:template>

  <xsl:template
    match="p[@rend = 'superscript'] | p[@rend = 'sup'] | hi[@rend = 'super'] | hi[@rend = 'superscript']"
    priority="2">
    <sup>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>

  <!-- ================================================ -->
  <!--                      TABLES                      -->
  <!-- ================================================ -->

  <!-- remove heads in table by default, they are not allowed -->
  <xsl:template match="table/head"/>

  <!-- called from table match -->
  <xsl:template match="table/head" mode="show">
    <div class="tei_table_head">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="table">

    <xsl:for-each select="head">
      <xsl:apply-templates select="." mode="show"/>
    </xsl:for-each>
    <table>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
        <xsl:text> tei_table table</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="row">
    <tr>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
        <xsl:text> tei_tr</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <xsl:template match="cell">
    <td>
      <xsl:if test="@rows">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="@rows"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@cols">
        <xsl:attribute name="colspanspan">
          <xsl:value-of select="@cols"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
        <xsl:text> tei_td</xsl:text>
        <xsl:if test="@rows">
          <xsl:text> rowspan_</xsl:text>
          <xsl:value-of select="@rows"/>
        </xsl:if>
        <xsl:if test="@cols">
          <xsl:text> colspan_</xsl:text>
          <xsl:value-of select="@cols"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- ================================================ -->
  <!--                     TEXT                         -->
  <!-- ================================================ -->

  <xsl:template match="text">
    <div class="main_content">
      <xsl:apply-templates/>
      <xsl:if test="//note[@place = 'foot']">
        <br/>
        <hr/>
      </xsl:if>
      <xsl:if test="//note[@place = 'foot']">
        <div class="footnotes">
          <xsl:text> </xsl:text>
          <xsl:for-each select="//note[@place = 'foot']">
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

  <!-- ================================================ -->
  <!--                     UNCLEAR                      -->
  <!-- ================================================ -->

  <xsl:template match="unclear">
    <span>
      <xsl:attribute name="class">
        <xsl:text>unclear </xsl:text>
        <xsl:value-of select="@reason"/>
        <xsl:text> </xsl:text>
        <xsl:attribute name="class">
          <xsl:call-template name="add_attributes"/>
        </xsl:attribute>
      </xsl:attribute>
      <xsl:apply-templates/>
      <xsl:text>[?]</xsl:text>
    </span>
  </xsl:template>

</xsl:stylesheet>

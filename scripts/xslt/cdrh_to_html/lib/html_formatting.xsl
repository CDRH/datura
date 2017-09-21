<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0"
  exclude-result-prefixes="xsl tei xs">
  
  <!-- this template is used to generate a list of classes that 
    represent all the attributes and values on a tag for instance, 
    <fw type="pageNum test" place="top"> would render as "tei_fw_type_pageNum tei_fw_type_test tei_fw_place_top tei_fw" -->
  <!-- line returns or spaces are passed through to attributes so are removed -->
  <xsl:template name="add_attributes">
    <xsl:if test="@*">
      <xsl:for-each select="@*">
        <xsl:variable name="att_prefix"><xsl:text>tei_</xsl:text><xsl:value-of select="../name()"/><xsl:text>_</xsl:text><xsl:value-of select="name()"/><xsl:text>_</xsl:text></xsl:variable>
        <xsl:for-each select="tokenize(.,' ')"><xsl:value-of select="$att_prefix"/><xsl:value-of select="."/><xsl:text> </xsl:text></xsl:for-each>
      </xsl:for-each>
    </xsl:if><xsl:text>tei_</xsl:text><xsl:value-of select="name()"/>
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
      <xsl:apply-templates select="expan"/>​ 
    </xsl:attribute>
    <xsl:apply-templates select="abbr"/>
  </a>​
</xsl:template>

<!-- ================================================ -->
<!--                       ADD                        -->
<!-- ================================================ -->
  
  <xsl:template match="add">
    <xsl:choose>
      <xsl:when test="@place='superlinear' or @place='supralinear'">
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
<!--                       BOLD                       -->
<!-- ================================================ -->

<!-- See "Strong" below -->

<!-- ================================================ -->
<!--                      DATES                       -->
<!-- ================================================ -->

<xsl:template name="extractDate">
  <xsl:param name="date" />
  <!--This template converts a date from format YYYY-MM-DD to mm D, YYYY (MM, MM-DD, optional)-->
  
  <xsl:variable name="YYYY" select="substring($date,1,4)" />
  <xsl:variable name="MM" select="substring($date,6,2)" />
  <xsl:variable name="DD" select="substring($date,9,2)" />

  <xsl:choose>
    <xsl:when test="($DD != '') and ($MM != '') and ($DD != '')">
      <xsl:call-template name="lookUpMonth"><xsl:with-param name="numValue" select="$MM" /></xsl:call-template><xsl:text> </xsl:text> <xsl:number format="1" value="$DD" />, <xsl:value-of select="$YYYY" />
    </xsl:when>
    <xsl:when test="($YYYY != '') and ($MM != '')">
      <xsl:call-template name="lookUpMonth"><xsl:with-param name="numValue" select="$MM" /></xsl:call-template>, <xsl:value-of select="$YYYY" />
    </xsl:when>
    <xsl:when test="($DD != '') and ($MM != '')">
      <xsl:call-template name="lookUpMonth"><xsl:with-param name="numValue" select="$MM" /></xsl:call-template>, <xsl:value-of select="$YYYY" />
    </xsl:when>
    <xsl:when test="($YYYY != '')">
      <xsl:value-of select="$YYYY" />
    </xsl:when>
    <xsl:otherwise>
      N.D.
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="lookUpMonth">
  <xsl:param name="numValue" />
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
    <xsl:otherwise></xsl:otherwise></xsl:choose>
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
    <!-- note, previously I matched on @type='overwrite' or @rend='overwrite' and did not show. Now, instead, I
    attaches the class tei_del_overwrite, which we can then style with css or hide with javascript. -->
    
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
    <xsl:when test="@type='html'">
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

<!-- Started heads at h3 because h1 is the site title and h2 is normally the page title, which is pulled from solr or a database.  -->

<xsl:template match="head">
  <!-- need to fix for handwritten text -KD -->
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
    
    <!-- I added the div1 code for OSCYS, but I assume it will pop up elsewhere. 
    First I test if the div1 has a head. If it does not, I start the div2's on the h3's and work from there. - karin
    -->
    <xsl:when test="//div1">
      <xsl:choose>
        <xsl:when test="//div1/head">
          <xsl:choose>
            <xsl:when test="parent::div1">
              <h3><xsl:apply-templates/></h3>
            </xsl:when>
            <xsl:when test="parent::div2">
              <h4><xsl:apply-templates/></h4>
            </xsl:when>
            <xsl:when test="parent::div3">
              <h5><xsl:apply-templates/></h5>
            </xsl:when>
            <xsl:when test="parent::div4 or parent::div5 or parent::div6 or parent::div7  ">
              <h6><xsl:apply-templates/></h6>
            </xsl:when>
            <xsl:otherwise>
              <h4><xsl:apply-templates/></h4>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="parent::div2">
              <h3><xsl:apply-templates/></h3>
            </xsl:when>
            <xsl:when test="parent::div3">
              <h4><xsl:apply-templates/></h4>
            </xsl:when>
            <xsl:when test="parent::div4">
              <h5><xsl:apply-templates/></h5>
            </xsl:when>
            <xsl:when test="parent::div5 or parent::div6 or parent::div7  ">
              <h6><xsl:apply-templates/></h6>
            </xsl:when>
            <xsl:otherwise>
              <h4><xsl:apply-templates/></h4>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    
    <xsl:when test=".[@type='sub']">
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
<!--                        HI                        -->
<!-- ================================================ -->

<xsl:template match="hi[@rend]" priority="1">
  <span>
    <xsl:attribute name="class"><xsl:value-of select="@rend"/></xsl:attribute>
    <xsl:apply-templates/>
  </span>
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
<!--                      ITALICS                     -->
<!-- ================================================ -->

<xsl:template match="ab[@rend='italics'] | p[@rend='italics']">
  <div>
    <xsl:attribute name="class">
      <xsl:value-of select="name()"/>
    </xsl:attribute>
    <em>
      <xsl:apply-templates/>
    </em>
  </div>
</xsl:template>

<xsl:template match="hi[@rend='italic'] | hi[@rend='italics']" priority="2">
  <em>
    <xsl:attribute name="class">
      <xsl:value-of select="name()"/>
    </xsl:attribute>
    <xsl:apply-templates/>
  </em>
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
    <div class="tei_list_head"><xsl:apply-templates select="head/node()"/></div>
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

<xsl:template match="hi[@rend='smallcaps'] | hi[@rend='roman']" priority="1">
  <span>
    <xsl:attribute name="class">
      <xsl:value-of select="@rend"/>
    </xsl:attribute>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="term | foreign | emph | title[not(@level='a')] | biblScope[@type='volume']">
  <em>
    <xsl:attribute name="class"><xsl:call-template name="add_attributes"/></xsl:attribute>
    <xsl:apply-templates/>
  </em>
</xsl:template>

<xsl:template
  match="byline | docDate | sp | speaker | letter | fw |
  notesStmt | titlePart | docDate | ab | trailer | 
  front | lg | l | bibl | dateline | salute | trailer | titlePage | opener | closer | floatingText | date
  | resp | respStmt | name | orgName | label | caption | idno | signed">
  <span>
    <xsl:attribute name="class"><xsl:call-template name="add_attributes"/></xsl:attribute>
      <xsl:apply-templates/>
  </span>
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
<!--                    PARAGRAPHS                    -->
<!-- ================================================ -->

  <!-- todo - this could be better, need to do a full evaluation of things that are illegal within a p -KMD -->
<xsl:template match="p">
  <xsl:choose>
    <xsl:when test="descendant::list or descendant::p">
      <div class="p">
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <p><xsl:apply-templates/></p>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ================================================ -->
<!--                   POSITIONING                    -->
<!-- ================================================ -->

<xsl:template match="hi[@rend='right'] | hi[@rend='center']" priority="1">
  <div>
    <xsl:attribute name="class">
      <xsl:value-of select="@rend"/>
    </xsl:attribute>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- ================================================ -->
<!--                     QUOTES                       -->
<!-- ================================================ -->

<xsl:template match="hi[@rend='quoted']" priority="1">
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
<!--                       SEG                        -->
<!-- ================================================ -->

<!-- Handwritten From CWW - move into collection file? -->
<xsl:template match="seg[@type='handwritten']">
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
    <xsl:attribute name="class"><xsl:text>sic</xsl:text></xsl:attribute>
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
<!--                     STRONG                       -->
<!-- ================================================ -->

<xsl:template match="item/label | hi[@rend='bold']">
  <strong><xsl:apply-templates/></strong>
</xsl:template>


<!-- ================================================ -->
<!--              SUPER AND SUB SCRIPT                -->
<!-- ================================================ -->

 <xsl:template match="p[@rend='superscript'] | p[@rend='sup'] | hi[@rend='super'] | hi[@rend='superscript']" priority="2">
  <sup><xsl:apply-templates/></sup>
</xsl:template>

<xsl:template match="hi[@rend='subscript']" priority="1">
  <sub><xsl:apply-templates/></sub>
</xsl:template>

<!-- ================================================ -->
<!--                      TABLES                      -->
<!-- ================================================ -->
  
  <!-- remove heads in table by default, they are not allowed -->
  <xsl:template match="table/head"></xsl:template>
  
  <!-- called from table match -->
  <xsl:template match="table/head" mode="show"><div class="tei_table_head"><xsl:apply-templates/></div></xsl:template>

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
    <xsl:if test="@rows"><xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute></xsl:if>
    <xsl:if test="@cols"><xsl:attribute name="colspanspan"><xsl:value-of select="@cols"/></xsl:attribute></xsl:if>
    <xsl:attribute name="class">
      <xsl:value-of select="@rend"/>
      <xsl:text> tei_td</xsl:text>
      <xsl:if test="@rows"><xsl:text> rowspan_</xsl:text><xsl:value-of select="@rows"/></xsl:if>
      <xsl:if test="@cols"><xsl:text> colspan_</xsl:text><xsl:value-of select="@cols"/></xsl:if>
    </xsl:attribute>
    <xsl:apply-templates/>
  </td>
</xsl:template>

<!-- ================================================ -->
<!--                     UNCLEAR                      -->
<!-- ================================================ -->

<xsl:template match="unclear">
  <span>
    <xsl:attribute name="class">
      <xsl:text>unclear </xsl:text>
      <xsl:value-of select="@reason"/>
    </xsl:attribute>
    <xsl:apply-templates/>
    <xsl:text>[?]</xsl:text>
  </span>
</xsl:template>

<!-- ================================================ -->
<!--                    UNDERLINE                     -->
<!-- ================================================ -->

  <xsl:template match="hi[@rend='underlined'] | hi[@rend='underline'] | emph[@rend='underline']" priority="1">
  <u>
    <xsl:attribute name="class">
      <xsl:text>tei_</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>_underline</xsl:text>
    </xsl:attribute>
    <xsl:apply-templates/>
  </u>
</xsl:template>


</xsl:stylesheet>

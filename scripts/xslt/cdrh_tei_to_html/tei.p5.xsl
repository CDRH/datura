<?xml version="1.0"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0"
  exclude-result-prefixes="xsl tei xs">
  
  <!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
  
  <xsl:output method="xhtml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PARAMETERS
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <!-- Left for project display rules, currently unused -->
  <xsl:param name="pagetype"></xsl:param>
  <xsl:param name="subpagetype"></xsl:param>
  
  <!-- delete --><xsl:param name="metadata_box">false</xsl:param> <!-- true/false Toggle metadata box on and off  -->
  <xsl:param name="figures">true</xsl:param> <!-- true/false Toggle figures on and off  -->
  <xsl:param name="fw">true</xsl:param> <!-- true/false Toggle fw's on and off  -->
  <xsl:param name="pb">true</xsl:param> <!-- true/false Toggle pb's on and off  -->
  
  <!-- link locations - unsure about how these will work in the "real world" -->
  <xsl:param name="fig_location"><xsl:text>http://rosie.unl.edu/data_images/projects/cody/figures/</xsl:text></xsl:param> <!-- set figure location  -->
  <!-- delete --><xsl:param name="keyword_link"><xsl:text>../../</xsl:text></xsl:param> <!-- set keyword link location  -->
  
  
  <!-- ===================================================================================
    CODE TO INCLUDE
    =================================================================================== -->
  
  <!-- DELETE THIS AND PULL METADATA FROM SOLR -->
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    METADATA BOX
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template name="metadata">
    
    <div class="metadata">
      <h3>Metadata</h3>
      <dl>
        
        <!-- ___Project___ -->
        <dt>Project:</dt>
        <dd><xsl:value-of select="//publicationStmt/authority[1]"/></dd>
        
        
        <!-- ___Title___ -->
        <dt>Title:</dt>
        <dd>
          <xsl:choose>
            <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']">
              <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
            </xsl:otherwise>
          </xsl:choose></dd>
        
        <!-- ____Principal Investigators___ -->
        <xsl:if test="normalize-space(//titleStmt/principal[1])">
          <dt>Principal Investigator(s):</dt>
          <dd>
            <xsl:for-each select="//titleStmt/principal">
              <xsl:if test="normalize-space(.) != ''">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
              </xsl:if>
            </xsl:for-each>
         </dd>
        </xsl:if>
        
        <!-- ___Authors___ -->
        <xsl:if test="normalize-space(//titleStmt/author[1])">
          <dt>Author(s):</dt>
          <dd>
            <xsl:for-each select="//titleStmt/author">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
            </xsl:for-each>
          </dd>
        </xsl:if>
        
        <!-- ___Encoders___ -->
        <!-- This is done differently in different files, see cather file cat.cs006 for an example -KMD -->
        
        <xsl:if test="/TEI/teiHeader/fileDesc/titleStmt/respStmt[1]/name[1]">
          <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/respStmt">
            
              <dt>
              <!-- Select the resp statement role. Might need to change if we find files with more than one resp statement-->
              <!--<xsl:value-of select="concat(upper-case(substring(resp,1,1)),substring(resp,2))"/><xsl:text>:</xsl:text>-->
                  <xsl:for-each select="./resp">
                      <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(.,2))"/>
                      <xsl:choose>
                          <xsl:when test="position() = last()">
                              <xsl:text>:</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                              <xsl:text>, </xsl:text>
                          </xsl:otherwise>
                      </xsl:choose>
                  </xsl:for-each>
            </dt>
            
            <!-- display each name. See CWW for more complex code that displays like ___, ____, and ____. -->
            <dd>
              <xsl:for-each select="name"><xsl:value-of select="."/>
                <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
              </xsl:for-each>
            </dd>
            
          </xsl:for-each>
          
          
        </xsl:if>
        
        <!-- ___Source___ -->
        
        <xsl:if test="normalize-space(//sourceDesc/bibl) != ''">
        <dt>Source:</dt>
        <dd>
          <xsl:for-each select="//sourceDesc/bibl"> 
            <xsl:for-each select="child::*">
              <xsl:if test="normalize-space(.) != ''">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
              </xsl:if>
            </xsl:for-each>
          </xsl:for-each>
           
        </dd>
        </xsl:if>
        
        <!-- ___Keywords, categories, etc.___ -->
        
        <xsl:if test="normalize-space(//profileDesc/textClass) != ''">
          <xsl:for-each select="//profileDesc/textClass/keywords">
            <xsl:if test="normalize-space(.) != ''">
              <dt><xsl:value-of select="concat(upper-case(substring(@n,1,1)),substring(@n,2))"/></dt>
            <dd>
              <xsl:for-each select="term">
                <xsl:if test="normalize-space(.) != ''">
                  <!-- when keyword_link is not false, set the default path for linking keywords -->
                  <xsl:choose>
                    <xsl:when test="$keyword_link = 'false'">
                      <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="{$keyword_link}{parent::*/@n}/{.}">
                      <xsl:value-of select="."/>
                       
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                  
                  <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                </xsl:if>
                
              </xsl:for-each>
            </dd>
            </xsl:if>
          </xsl:for-each>
          
        </xsl:if>
        
        <!-- ___TEI ID___ -->
        <dt>TEI ID:</dt>
        <dd><xsl:value-of select="/TEI/@xml:id"></xsl:value-of></dd>
        
        <!-- ___Link to XML___ -->
        <dt>TEI XML Download:</dt>
        <dd>
          <a href="{/TEI/@xml:id}.xml">
            <xsl:value-of select="/TEI/@xml:id"></xsl:value-of>
            <xsl:text>.xml</xsl:text>
          </a></dd>
        
        <dt></dt>
        <dd></dd>
      </dl>
      
    </div>
    
  </xsl:template>
  
  
  
  
  
  
  <!-- ===================================================================================
    TEMPLATES: Header and Footer
    =================================================================================== -->
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Add info to top of document
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match= "/TEI/text[1]">
    
    <div class="main_content">
   
    <xsl:if test="$metadata_box = 'true'">
    <xsl:call-template name="metadata"/>
    </xsl:if>
    <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Add info to bottom of document
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="text"> <!-- find a better rule for matching bottom of document -->
    <xsl:apply-templates/>
    
    <xsl:if test="//note[@place='foot']">
      <br/>
      <hr/>
    </xsl:if>
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
  </xsl:template>
  
  
  <!-- ===================================================================================
    TEMPLATES: Param controlled
    =================================================================================== -->
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    FW (Form Work)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="fw">
    <xsl:if test="$fw = 'true'">
      <xsl:if test="not(@type='sub')">
        <h6>
          <xsl:attribute name="class">
            <xsl:value-of select="name()"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </h6>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  

  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Figures
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="figure">
    <xsl:if test="$figures = 'true'">
      <xsl:choose>
        <!-- Is this specific to everyweek, should it be in here? -KMD -->
        <xsl:when test="@n='flag'"></xsl:when>
        <xsl:otherwise>
          <div class="inline_figure">
            <div class="p">[illustration]</div>
            <xsl:apply-templates/></div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Page breaks and page images
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="pb">
    <xsl:if test="$pb = 'true'">
      
      <!-- grab the figure id, first looking in @facs, then @xml:id, and if there is a .jpg, chop it off -->
      <xsl:variable name="figure_id">
        <xsl:variable name="figure_id_full">
          <xsl:choose>
            <xsl:when test="@facs"><xsl:value-of select="@facs"></xsl:value-of></xsl:when>
            <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"></xsl:value-of></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($figure_id_full,'.jpg')">
            <xsl:value-of select="substring-before($figure_id_full,'.jpg')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$figure_id_full"/>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:variable>

      
      <span class="hr">&#160;</span>
      <span>
        <xsl:attribute name="class">
          <xsl:text>pageimage</xsl:text>
        </xsl:attribute>
        
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="$fig_location"/>
            <xsl:text>large/</xsl:text>
            <xsl:value-of select="$figure_id"/>
            <xsl:text>.jpg</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="rel">
            <xsl:text>prettyPhoto[pp_gal]</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:text>&lt;a href="</xsl:text>
            <xsl:value-of select="$fig_location"/>
            <xsl:text>large/</xsl:text>
            <xsl:value-of select="$figure_id"/>
            <xsl:text>.jpg</xsl:text>
            <xsl:text>" target="_blank" &gt;open image in new window&lt;/a&gt;</xsl:text>
          </xsl:attribute>
          
          <img>
            <xsl:attribute name="src">
              <xsl:value-of select="$fig_location"/>
              <xsl:text>thumbnails/</xsl:text>
              <xsl:value-of select="$figure_id"/>
              <xsl:text>.jpg</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="class">
              <xsl:text>display</xsl:text>
            </xsl:attribute>
          </img>
        </a>
      </span>
    </xsl:if>
  </xsl:template>
  
  
  <!-- ===================================================================================
    TEMPLATES: Basic Styles
    =================================================================================== -->
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Things to hide
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

  <xsl:template match="teiHeader | revisionDesc | publicationStmt | sourceDesc | figDesc">
    <!-- hide -->
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Add classes for styling TEI
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <!-- Div's -->
  <xsl:template
    match="byline | docDate | sp | speaker | letter | 
    notesStmt | titlePart | docDate | ab | trailer | 
    front | lg | l | bibl | dateline | salute | trailer | titlePage | closer | floatingText">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
        <xsl:if test="@type"><xsl:text> </xsl:text><xsl:value-of select="@type"/></xsl:if>
        <xsl:if test="@rend"><xsl:text> </xsl:text><xsl:value-of select="@rend"/></xsl:if>
        <xsl:if test="not(parent::p)"><xsl:text> p</xsl:text></xsl:if>
      </xsl:attribute>
      <xsl:choose>
        <!-- This is for CWW, check to see if this is done correctly, will it add two handwritten classses? -KMD -->
        <xsl:when test="@type='handwritten'">
          <span>
            <xsl:attribute name="class">
              <xsl:text>handwritten</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Don't know why this was here, commenting out for now -KMD -->
      <!--<xsl:text> </xsl:text>-->
    </span>
  </xsl:template>
  
  <!-- Special case, if encoding is fixed, can fold into rule above-->
  
  <xsl:template match="ab[@rend='italics']">
    <div>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <em>
        <xsl:apply-templates/>
      </em>
    </div>
  </xsl:template>
  
  <!-- Div types for styling -->
  <!-- directly from CWW - should we keep, is there a better way? -KMD -->
  
  <xsl:template match="div1 | div2">
    <xsl:choose>
      <xsl:when test="@type='html'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:attribute name="class">
            <xsl:value-of select="@type"/>
            
            <xsl:attribute name="class">
              <xsl:if test="preceding-sibling::div1">
                <xsl:text> doublespace</xsl:text>
              </xsl:if>
              <xsl:text> </xsl:text>
              <xsl:value-of select="@subtype"/>
            </xsl:attribute>
            
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
  
  <!-- SPAN's -->
  
  <xsl:template match="docAuthor | persName | placeName ">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
      <!-- <xsl:text> </xsl:text> -->
    </span>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Text Styles
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="p[@rend='italics']">
    <p>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <em>
        <xsl:apply-templates/>
      </em>
    </p>
  </xsl:template>
  
  <xsl:template match="p[@rend='superscript'] | p[@rend='sup']">
    <sup>
        <xsl:apply-templates/>
    </sup>
  </xsl:template>
  
  <!-- Handwritten From CWW - move into project file? -->
  <xsl:template match="seg[@type='handwritten']">
    <span>
      <xsl:attribute name="class">
        <xsl:text>handwritten</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="div2[@subtype='handwritten']">
    <div>
      <xsl:attribute name="class">
        <xsl:text>handwritten</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template
    match="term | foreign | emph | title[not(@level='a')] | biblScope[@type='volume'] | 
    hi[@rend='italic'] | hi[@rend='italics']">
    <em>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </em>
  </xsl:template>
  
  <xsl:template match="hi[@rend='underlined']">
    <u>
      <xsl:apply-templates/>
    </u>
  </xsl:template>
  
  <!-- Things that should be strong -->
  
  <xsl:template match="item/label">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>
  
  <xsl:template match="hi[@rend='bold']">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>
  
  <!-- Rules to account for hi tags other than em and strong-->
  
  <xsl:template match="hi[@rend='underline']">
    <u>
      <xsl:apply-templates/>
    </u>
  </xsl:template>
  
  <xsl:template match="hi[@rend='quoted']">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  
  <xsl:template match="hi[@rend='super']">
    <sup>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>
  
  <xsl:template match="hi[@rend='subscript']">
    <sub>
      <xsl:apply-templates/>
    </sub>
  </xsl:template>
  
  <xsl:template match="hi[@rend='smallcaps'] | hi[@rend='roman']">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="hi[@rend='right'] | hi[@rend='center']">
    <div>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <!-- CWW Specific, move into project stylesheet? -->
  <xsl:template match="space">
    <span class="teispace">
      <xsl:text>[no handwritten text supplied here]</xsl:text>
    </span>
  </xsl:template>
  
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HEADS
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <!-- Started heads at h3 because h1 is the site title and h2 is normally the page title, which is normally pulled from solr or a database.  -->
  
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
      First I test if the div1 has a head. If it does not, I start the div2's on the h3's and work from there.
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

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Paragraphs
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  
  
  <!-- Greatly simplified from TEI-C stylesheets, kept here because P currently only place that references it -->
  
  <xsl:template  name="splitHTMLBlocks">
    <xsl:param name="element"/>
    <xsl:param name="content"/>
    
    

    <xsl:for-each select="$content/node()">
      <xsl:if test="normalize-space(.) != ''">
      <xsl:choose>
        <!-- Check for block level HTML elements -->
        <xsl:when test="name() = 'h6' or name() = 'h5'">
          <xsl:copy-of select="."></xsl:copy-of>
        </xsl:when>
        <xsl:otherwise>
          <p>
            <xsl:copy-of select="."/>
          </p>
        </xsl:otherwise>
      </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  
  <xsl:template match="p">
    <xsl:choose>
      
      <xsl:when test="
        descendant::*[name() = 'p'] or
        descendant::*[name() = 'quote'] or
        descendant::*[name() = 'fw']">
        <xsl:call-template name="splitHTMLBlocks">
          <xsl:with-param name="element">p</xsl:with-param>
          <xsl:with-param name="content">
            <xsl:apply-templates/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <p><xsl:apply-templates/></p>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
 
    <!-- This didn't work but I would really like it to -KMD -->
<!--  <xsl:template match="p[descendant::*[name() = 'quote']]/node() |
                       p[descendant::*[name() = 'fw']]/node()">
    [[[zzz<!-\-<xsl:copy-of select="."></xsl:copy-of>-\-><xsl:apply-templates select="text()"/>]]]
  </xsl:template>-->
  
 
  
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
      <!-- TODO talk to jessica about relative vs absolute links - maybe se should use sub domains to make everything absolute?
      Right now I am using relative, assuming documents will always be one level up-->
      <xsl:otherwise>
        <a href="../doc/{@target}" class="internal_link">
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- Old rules preserved here - TODO KMD needs to check with Laura to see which need to be kept -->
    <!--<xsl:choose>
      <xsl:when test="starts-with(@target, 'n')">
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
      <xsl:when test="@type='link'">
        <a href="{@target}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> </xsl:text>
        <a href="{@target}" id="{@target}.ref" class="footnote">
          
          <xsl:choose>
            <xsl:when test="descendant::text()">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@n"/>
            </xsl:otherwise>
          </xsl:choose>
          
        </a>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>-->
  </xsl:template>
  

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Links
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="xref[@n]">
    <a href="{@n}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Milestone / horizontal rule
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="milestone">
    <div>
      <xsl:attribute name="class">
        <xsl:text>milestone </xsl:text>
        <xsl:value-of select="@unit"/>
      </xsl:attribute>
      <xsl:text> </xsl:text>
    </div>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Line Breaks
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

  <xsl:template match="lb">
    <xsl:apply-templates/>
    <br/>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Tables
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="table">
    <xsl:choose>
      <xsl:when test="@rend='handwritten'">
        <table>
          <xsl:attribute name="class">
            <xsl:text>handwritten</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <table>
          <xsl:apply-templates/>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="row">
    <tr>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  
  <xsl:template match="cell">
    <td>
      <xsl:apply-templates/>
    </td>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Lists
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="list">
    <xsl:choose>
      <xsl:when test="@type='handwritten'">
        <ul>
          <xsl:attribute name="class">
            <xsl:text>handwritten</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:apply-templates/>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="item">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Quotes
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
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
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Letters
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <!-- ___Signed___ -->
  <xsl:template match="//signed">
    <br/>
    <xsl:apply-templates/>
  </xsl:template>
  
  
  

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Gap
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

  <xsl:template match="gap">
    <span>
      <xsl:attribute name="class">
        <xsl:text>gap </xsl:text>
        <xsl:value-of select="@reason"/>
      </xsl:attribute>
      <xsl:apply-templates/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="@reason"/>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Unclear
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="unclear">
    <span>
      <xsl:attribute name="class">
        <xsl:text>unclear </xsl:text>
        <xsl:value-of select="@reason"/>
      </xsl:attribute>
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>?]</xsl:text>
    </span>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Add
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="add">
    <xsl:choose>
      <xsl:when test="@place='superlinear' or @place='supralinear'">
        <sup>
          <xsl:apply-templates/>
        </sup>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Delete
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="del">
    <xsl:choose>
      <xsl:when test="@type='overwrite'">
        <!-- Don't show overwritten text -->
      </xsl:when>
      <xsl:otherwise>
        <del>
          
            <xsl:if test="@reason">
              <xsl:attribute name="class">
            <xsl:value-of select="@reason"/>
              </xsl:attribute>
            </xsl:if>
            
          
          <xsl:apply-templates/>
          <!-- <xsl:text>[?]</xsl:text> -->
        </del>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Sic and Corr
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="choice[child::corr]">
    <a>
      <xsl:attribute name="rel">
        <xsl:text>tooltip</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text>sic</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:apply-templates select="corr"/>​ </xsl:attribute><xsl:apply-templates select="sic"/>
    </a>
    ​</xsl:template>
  
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Orig and Reg
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
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
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Abbr and Expan
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template match="choice[child::abbr]">
    <a>
      <xsl:attribute name="rel">
        <xsl:text>tooltip</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text>abbr</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:apply-templates select="expan"/>​ </xsl:attribute><xsl:apply-templates select="abbr"
        /></a>​</xsl:template>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Damage
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

  <xsl:template match="damage">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="@type"/>
      </xsl:attribute>
      <xsl:apply-templates/>
      <xsl:text>[?]</xsl:text>
    </span>
  </xsl:template>
  

  






  <!-- ===================================================================================
    HELPER TEMPLATES
    =================================================================================== -->
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    EXTRACT DATE
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
  <xsl:template name="extractDate">
    <xsl:param name="date" />
    <!--This template converts a date from format YYYY-MM-DD to mm D, YYYY (MM, MM-DD, optional)-->
    
    
    <xsl:variable name="YYYY" select="substring($date,1,4)" />
    <xsl:variable name="MM" select="substring($date,6,2)" />
    <xsl:variable name="DD" select="substring($date,9,2)" />
    <!--
            (Y:"<xsl:value-of select="$YYYY" />" M:"<xsl:value-of select="$MM" />" D:"<xsl:value-of select="$DD" />")
        -->
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
  
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LOK UP MONTH (used by extract date)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  
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





  

 
  
</xsl:stylesheet>

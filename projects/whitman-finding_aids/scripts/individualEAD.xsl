<xsl:stylesheet xmlns="http://www.w3.dorg/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1">
  <!-- ~~~~~~~~~~~~~~~~~~
  Individual Archive file, e.g.:
  manuscripts/finding_aids/Yale.html
  ~~~~~~~~~~~~~~~~~~~~ -->

  <!-- When editing this file, please refer to the Wiki entry on EAD XSLT -->

  <!-- This XSLT sheet styles all of the individual EAD XML files -->

  <!-- The sheet is divided into 6 main components: General information/metadata, c01, c02, c03, c04, and links -->

  <xsl:output method="html" indent="yes" encoding="utf-8" media-type="text/html"
    doctype-public="-//W3C//DTD HTML 4.0//EN"/>
  <!-- added config -KMD -->
  <xsl:include href="../../xslt/config.xsl"/>

  <!-- General information/metadata starts here and continues until c01 -->

  <!-- The following template sets up the structure and order of the output document -->

  <xsl:template match="ead">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>
          <xsl:value-of select="descendant::eadheader/filedesc/titlestmt/titleproper"/>
        </title>
      </head>
      <body>
        <h1 class="docTitle">Resources</h1>
        <h2 class="docTitle">Catalogs of Manuscripts at Individual Repositories</h2>

        <!-- The following template displays the title statement -->

        <h3>
          <xsl:value-of select="//titlestmt//titleproper"/>
          <br/>
          <br/>
        </h3>

        <!-- The following creates the display for the author/sponsor information -->

        <p>
          <xsl:apply-templates select="//titlestmt/author"/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="//sponsor"/>
          <br/>
          <br/>
        </p>

        <!-- The following generates the individual c0 level entries -->

        <p>
          <xsl:apply-templates/>
        </p>

        <!-- The following sets the display for the restrictions and use statements which appear at the end of each EAD file -->

        <p>
          <hr/>
        </p>
        <p>
          <strong>
            <xsl:value-of select="//descgrp/accessrestrict/head"/>
          </strong>&#160;<xsl:apply-templates select="//accessrestrict/p"/>
        </p>
        <xsl:choose>
          <xsl:when test="//userestrict">
            <p>
              <strong>
                <xsl:value-of select="//descgrp/userestrict/head"/>
              </strong>&#160;<xsl:apply-templates select="//descgrp/userestrict/p"/>
            </p>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="//altformavail">
            <p>
              <strong>
                <xsl:value-of select="//descgrp/altformavail/head"/>
              </strong>&#160;<xsl:apply-templates select="//descgrp/altformavail/p"/>
            </p>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
        <p>
          <strong>
            <xsl:value-of select="//descgrp/prefercite/head"/>
          </strong> &#160;<xsl:apply-templates select="//descgrp/prefercite/p"/>
        </p>
        <p>
          <hr/>
        </p>
        <p>
          <strong>Repository Contact Information: </strong>
          <br/>
          <xsl:for-each select="//repository/address/addressline">
            <br/>
            <xsl:value-of select="."/>
          </xsl:for-each>
        </p>
      </body>
    </html>
  </xsl:template>

  <!-- The following templates format the display of various render attributes -->

  <xsl:template match="*[@render='bold']">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <xsl:template match="*[@render='underline']">
    <u>
      <xsl:apply-templates/>
    </u>
  </xsl:template>

  <xsl:template match="*[@render='sub']">
    <sub>
      <xsl:apply-templates/>
    </sub>
  </xsl:template>

  <xsl:template match="*[@render='super']">
    <super>
      <xsl:apply-templates/>
    </super>
  </xsl:template>

  <xsl:template match="*[@render='quoted']">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="*[@render='boldquoted']">
    <strong>
      <xsl:text>"</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>"</xsl:text>
    </strong>
  </xsl:template>

  <xsl:template match="*[@render='boldunderline']">
    <strong>
      <u>
        <xsl:apply-templates/>
      </u>
    </strong>
  </xsl:template>

  <xsl:template match="*[@render='bolditalic']">
    <strong>
      <i>
        <xsl:apply-templates/>
      </i>
    </strong>
  </xsl:template>

  <xsl:template match="*[@render='boldsmcaps']">
    <span class="smallcaps">
      <strong>
        <xsl:apply-templates/>
      </strong>
    </span>
  </xsl:template>

  <xsl:template match="*[@render='smcaps']">
    <span class="smallcaps">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="*[@render='doublequote']">"<xsl:apply-templates/>"</xsl:template>

  <xsl:template match="*[@render='italic']">
    <i>
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  

  <!-- This template suppresses eadid because it should not be displayed-->

  <xsl:template match="//eadid"> </xsl:template>

  <!-- These templates surpress parts of the TEI header: titlestmt, publicationstmt, profiledesc, and frontmatter-->

  <xsl:template match="//titlestmt"> </xsl:template>

  <xsl:template match="//publicationstmt"> </xsl:template>

  <xsl:template match="//profiledesc"> </xsl:template>

  <xsl:template match="//frontmatter"> </xsl:template>

  <!-- These templates display archdesc info for each XML Repository file, such as Title, Collection Number, Creator and Repository -->

  <!-- Title -->

  <xsl:template match="//archdesc/did/unittitle">
    <span><hr/><strong>
        <xsl:value-of select="@label"/>
      </strong>&#160;<xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <!-- Liz added this on 2015-04-14, while Kevin was around. -->
  <xsl:template match="c01[@level='series']/did/unittitle" priority="1">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Collection number -->

  <xsl:template match="//archdesc/did/unitid">
    <span>
      <br/><br/>
      <strong>
        <xsl:value-of select="@label"/>
      </strong>&#160;<xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- Creator -->

  <xsl:template match="//archdesc/did/origination">
    <span>
      <br/><br/>
      <strong>
        <xsl:value-of select="@label"/>
      </strong>&#160;
      <xsl:for-each select="persname">
        <xsl:apply-templates select="."/>
        <xsl:if test="following-sibling::persname">,&#160;</xsl:if>
      </xsl:for-each>
      
    </span>
  </xsl:template>

  <!-- Repository -->

  <xsl:template match="//archdesc/did/repository">
    <span>
      <br/><br/>
      <strong>
        <xsl:value-of select="@label"/>
      </strong>&#160;<xsl:apply-templates/><hr/>
    </span>
  </xsl:template>

  <!-- This template surpresses physdesc within archdesc because it shouldn't be displayed -->

  <xsl:template match="//archdesc/did/physdesc"> </xsl:template>

  <!-- These templates surpress address, accessrestrit, userestrict, prefercite and altformavail -->

  <xsl:template match="//address"> </xsl:template>

  <xsl:template match="//accessrestrict"> </xsl:template>

  <xsl:template match="//userestrict"> </xsl:template>

  <xsl:template match="//prefercite"> </xsl:template>

  <xsl:template match="//altformavail"> </xsl:template>

  <!--This template surpresses physloc-->

  <xsl:template match="physloc"/>

  <!-- The following templates take care of Abstract, Scope and Content, Biographical Information, and Subjects for each XML Repository file-->

  <!-- Abstract -->

  <xsl:template match="//abstract">
    <span>
      <br/>
      <strong>Abstract:</strong>
      <div>
        <xsl:apply-templates/>
        <br/>
        <br/>
      </div>
    </span>
  </xsl:template>

  <!-- Scope and Content -->

  <xsl:template match="//scopecontent[@id='sc001']">
    <span>
      <strong>
        <xsl:value-of select="head"/>:&#160; </strong>
      <br/>
    </span>

    <!-- Paragraphs within Scope and Content s-->

    <xsl:for-each select="p">
      <span>
        <xsl:apply-templates select="."/>
        <br/>
        <br/>
      </span>
    </xsl:for-each>
  </xsl:template>

  <!-- This template styles the titles within Scope and Content as links -->

  <xsl:template match="//scopecontent//title[@href]" priority="1">
    <xsl:choose>

      <!-- The <xsl:when> statements here ensure that titles styled as links still maintain their @render styling. -->

      <xsl:when test="@render = 'doublequote'">
        <span>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of
                select="replace(attribute::href,'http://www.whitmanarchive.org/', $siteroot)"/>
            </xsl:attribute>
            <xsl:text>"</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>"</xsl:text>
          </a>
        </span>
      </xsl:when>
      <xsl:when test="@render = 'italic'">
        <span>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of
                select="replace(attribute::href,'http://www.whitmanarchive.org/', $siteroot)"/>
            </xsl:attribute>
            <i>
              <xsl:apply-templates/>
            </i>
          </a>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of
                select="replace(attribute::href,'http://www.whitmanarchive.org/', $siteroot)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
          </a>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Biographical Information -->

  <xsl:template match="bioghist">
    <span>
      <strong>
        <xsl:value-of select="head"/>:<br/>
      </strong>
    </span>

    <!-- This section formats the paragraphs within Biographical Information -->

    <xsl:choose>

      <!-- When the section contains text, seperate paragraphs by line breaks and then insert the additional info statement -->

      <xsl:when test="child::p/child::text()">
        <xsl:for-each select="p">
          <span>
            <xsl:apply-templates select="."/>
            <br/>
            <br/>
          </span>
          <span> </span>
        </xsl:for-each>
        <div>
          <xsl:text>For additional biographical information, see </xsl:text>
          <a href="{$siteroot}biography/walt_whitman/index.html" target="_parent"> "Walt
            Whitman,"</a>
          <xsl:text> by Ed Folsom and Kenneth M. Price, and the </xsl:text>
          <a href="{$siteroot}biography/chronology.html" target="_self"> chronology</a>
          <xsl:text> of Whitman's Life.</xsl:text>
        </div>
      </xsl:when>

      <!-- If section does not contain text, insert additional info statement but no line breaks -->

      <xsl:otherwise>
        <span>
          <div>
            <xsl:text>For additional biographical information, see </xsl:text>
            <a href="{$siteroot}biography/walt_whitman/index.html" target="_parent"> "Walt
              Whitman,"</a>
            <xsl:text> by Ed Folsom and Kenneth M. Price, and the </xsl:text>
            <a href="{$siteroot}biography/chronology.html" target="_self"> chronology</a>
            <xsl:text> of Whitman's Life.</xsl:text>
          </div>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Subjects -->

  <xsl:template match="//controlaccess">
    <span>
      <strong>
        <br/>
        <xsl:value-of select="head"/>: </strong>
      <xsl:for-each select="persname">
        <xsl:apply-templates select="."/>
        <xsl:text>;&#160;
</xsl:text>
      </xsl:for-each>
      <xsl:for-each select="subject">
        <xsl:apply-templates select="."/>
        <xsl:if test="following-sibling::subject">;&#160;</xsl:if><!-- this puts a semicolon and space after each subject, except if it's the final subject (i.e. not followed by another subject) -->
        
      </xsl:for-each>
      <br/>
      <br/>
    </span>
  </xsl:template>

   
  <!-- deals with external links <extref>s -->
    
  <xsl:template match="extref">
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
      <xsl:attribute name="target">_blank</xsl:attribute>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  
  <!-- deals with internal links <ref>s. The anchors (which are currently only found around WWA ids) are implemented further down the stylesheet (currently in line 594), where we arrange each item and the WWA id is pulled in. -->
 <xsl:template match="//scopecontent/p/ref">
    <xsl:element name="a">
      <xsl:if test="@id">
        <xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@target">
        <xsl:attribute name="href">#<xsl:value-of select="@target"/></xsl:attribute>
        <xsl:attribute name="target">_self</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  
  
  
  <!-- this series of four templates keeps the series information from displaying twice (ask Liz if there is a better way to handle this. KM) -->
  <xsl:template match="c01[@level='series']/did/unittitle"/>
  <xsl:template match="c01[@level='series']/did/unitdate"/>
  <xsl:template match="c01[@level='series']/did/container"/>
  <xsl:template match="c01[@level='series']/scopecontent"/>
  
    
  <!-- Determines the order of the information in each individual item-level entry (essentially, this constructs each entry) -->
  
  <xsl:template match="//dsc">
    <!-- displays the "Item List" heading (or similar heading) -->
    <hr/>
    <!--<h3>
      <span><xsl:value-of select="//dsc/head"/></span>
    </h3>-->
    <br/>
    
    
    
    <!-- ============================================ 
    
    
    The following variable, and the "for-each" with two "sorts" that follow it, were created in an attempt to get the items in individual finding aids displaying by work. In its below form, the stylesheet pulls in the correct work titles, displays them before each item, and then arranges the entire finding aid alphatbetically by work and then by date within each work. However, we ideally do not want the work title to display for each item; we just want it to display once, at the beginning of a group of items that contributed to a single work (as with the Int. Guide). Also, the current form does not account for an item that may have contributed to multiple works (i.e. each item only appears in the individual finding aid once, regardless of whether it contributed to multiple works or not. These things need to be corrected. For now, the items are simply being displayed alphabetically by WWA title (which takes place in the "for-each" and "sort" at the end of this stylesheet. KM, 7/28/15
    
    ============================================================-->
    
    
    
    <!--<xsl:variable name="tempItemList">
        
    <!-\- The predicates within the select of the following "for-each" (the second two items in square brackets) tell the stylesheet to ignore anything marked as an 'item' that either 1) has a work id with '##' in it (basically, ignoring filler-work-ids), or 2) does not have a work ID. This was set up with Brian P-Z's help. KM, 7/14/15  -\->
    
      <xsl:for-each select="//*[@level='item'][not(contains(descendant::*[name()='unitid'][@type='work'],'##'))][descendant::*[name()='unitid'][@type='work'] !='']">
        
        <xsl:variable name="worksFile">../../work_files/<xsl:value-of select="./descendant::unitid[@type='work']"/>.xml</xsl:variable>
        
        
        <xsl:variable name="workTitle"><xsl:value-of select="document($worksFile)//titleStmt/title[@type='uniform']"/></xsl:variable>
        
        <div class="indivItem" id="{$workTitle}" unitdate="{descendant::unitdate/@normal}">
          
          <h1 class="eadworktitle"><xsl:value-of select="$workTitle"/></h1>
        
        <p><!-\-<strong><xsl:value-of select="$worksfile"/></strong><br/>-\->
          <strong>Whitman Archive Title: </strong><xsl:value-of select="descendant::title[not(@type='repository')]"/><br />
          <strong>Whitman Archive ID: </strong><xsl:value-of select="descendant::unitid[@type='WWA']"/><br/>
          <xsl:if test="ancestor::c01[@level='series']"><strong>Series: </strong><!-\-<xsl:value-of select="ancestor::c01[@level='series']/did/unittitle"/>-\-><xsl:apply-templates select="ancestor::c01[@level='series']/did/unittitle"></xsl:apply-templates><br/></xsl:if>
          <xsl:if test="ancestor::c02[@level='subseries']"><strong>Sub-Series: </strong><xsl:value-of select="ancestor::c02[@level='subseries']/did/unittitle/title"/><br/></xsl:if>
          <xsl:if test="descendant::container[@type='box']"><strong>Box: </strong><xsl:value-of select="descendant::container[@type='box']"/><br/></xsl:if>
          <xsl:if test="descendant::container[@type='folder']"><strong>Folder: </strong><xsl:value-of select="descendant::container[@type='folder']"/><br/></xsl:if>
          
          <!-\- repository title and ID -\->
          <xsl:if test="descendant::title[@type='repository']"><strong>Repository Title: </strong><xsl:value-of select="descendant::title[@type='repository']"/><br /></xsl:if>
          <xsl:if test="descendant::unitid[@type='repository']"><strong>Repository ID: </strong><xsl:value-of select="descendant::unitid[@type='repository']"/><br/></xsl:if>
          <strong>Date: </strong><xsl:value-of select="descendant::unitdate"/><br/>
          <strong>Genre: </strong> <xsl:value-of select="descendant::genreform[1]"/>
          <xsl:if test="descendant::genreform[2]">, <xsl:value-of select="descendant::genreform[2]"/></xsl:if><br/>
          <strong>Physical Description: </strong><xsl:value-of select="descendant::extent"/>, <xsl:if test="descendant::dimensions"><xsl:value-of select="descendant::dimensions"/>, </xsl:if><xsl:value-of select="descendant::physfacet[1]"/><xsl:if test="descendant::physfacet[2]">, <xsl:value-of select="descendant::physfacet[2]"/></xsl:if><br/>
          
          <!-\- the following deals with the image links -\->
          <xsl:choose>      
            <xsl:when test="descendant::dao">
              <strong>View images: </strong>
              <xsl:for-each select="descendant::dao">
                <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute><xsl:value-of select="position()"/></xsl:element><xsl:choose>
                  <xsl:when test="position() = last()"/>
                  <xsl:otherwise> | </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each><br/>
            </xsl:when>
            <xsl:otherwise><strong>Images:</strong> forthcoming<br/></xsl:otherwise>
          </xsl:choose>
          <!-\- end image link code-\->
          
          <!-\- content section -\->
          <strong>Content: </strong><xsl:apply-templates select="descendant::scopecontent/p[1]"/><xsl:if test="descendant::scopecontent/p[2]"><br/><br/><xsl:apply-templates select="descendant::scopecontent/p[2]"/></xsl:if><xsl:if test="descendant::scopecontent/p[3]"><br/><br/><xsl:apply-templates select="descendant::scopecontent/p[3]"/></xsl:if><xsl:if test="descendant::scopecontent/p[4]"><br/><br/><xsl:apply-templates select="descendant::scopecontent/p[4]"/></xsl:if><!-\- the preceding rules are an attempt to deal with content descriptions that have multiple paragraphs; this seemed like the easiest way to do it quickly, but is probably not the most succinct way (plus, it only accounts for up to 4 paragraphs). This works for now, but we may want to revise the way this is handled at some point. KM, 6/8/15 -\-><br/><br/>
          
          <!-\-<xsl:if test="following-sibling::c01[@level='item'] | following-sibling::c02[@level='item']">-\->
            <hr width="20%"/> <!-\- this places a short horizontal bar after an item, as long as it is NOT the last item in a work section (i.e. as long as it has another item after it) -\->
            <br/>
          <!-\-</xsl:if>-\->
          
        </p>
        
        </div>
        
      </xsl:for-each>
      
    </xsl:variable>
    
    
    <!-\- all of the items are stored in a variable (immediately preceding this), and the items within that variable are then sorted in the "for-each" below, first by work, and then by "unitdate". -\->
    
    <xsl:for-each select="$tempItemList/*[name()='div']">
      <xsl:sort select="@id" order="ascending" data-type="text"/>
      <xsl:sort select="@unitdate" order="ascending" data-type="text"/>
      <xsl:copy-of select="."/>
    </xsl:for-each>-->
    
    
    
    
    
    
     
    
      <xsl:for-each select="//*[@level='item']">
      
      <xsl:variable name="wwaTitle">
        <xsl:value-of select="./descendant::title[parent::unittitle][not(@type='repository')]"/>
      </xsl:variable>
      
      <xsl:variable name="sortTitle">
        <xsl:value-of select="lower-case(replace($wwaTitle, '[^(^\w)^\s]', ''))"/>
      </xsl:variable>
      
      <!-- <xsl:sort select="lower-case(replace(string(./descendant::title[parent::unittitle][not(@type='repository')]), '[^(^\w)^\s]', ''))" data-type="text"
        order="ascending"/>-->
      
      <!-- the following "sort" sorts all of the items alphabetically by Whitman Archive title (specifically, by the title which is NOT typed as "repository," since some older items do not have a @type="WWA"). KM, 7/28/15 -->
        <xsl:sort select="./descendant::title[not(@type='repository')]" data-type="text"
          order="ascending"/>
      
    
      
     
    <div class="indivItem">
      <!--<xsl:for-each select="*[@level='item']">
        <xsl:sort select="descendant::unitid/attribute::work" data-type="text"
          order="ascending"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>-->
      <p><!--<strong><xsl:value-of select="$worksfile"/></strong><br/>-->
        <!--<strong>Sort title: </strong><xsl:value-of select="$sortTitle"/><br/>-->
        <strong>Whitman Archive Title: </strong><xsl:value-of select="descendant::title[not(@type='repository')]"/><br />
        <!-- the following <xsl:choose> puts an anchor around WWA ids that are referenced in internal links. WWA ids that don't require an anchor are just displayed normally (in the <xsl:otherwise>) -->
        <strong>Whitman Archive ID: </strong><xsl:choose>
          <xsl:when test="descendant::did/unitid/ref">
            <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="descendant::did/unitid/ref[@id]"/></xsl:attribute><xsl:value-of select="descendant::unitid[@type='WWA']"/></xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="descendant::unitid[@type='WWA']"/>
          </xsl:otherwise>
        </xsl:choose>
        
        <br/>
        <!-- container info -->
        <xsl:if test="ancestor::c01[@level='series']"><strong>Series: </strong><!--<xsl:value-of select="ancestor::c01[@level='series']/did/unittitle"/>--><xsl:apply-templates select="ancestor::c01[@level='series']/did/unittitle"></xsl:apply-templates><br/></xsl:if>
        <xsl:if test="ancestor::c02[@level='subseries']"><strong>Sub-Series: </strong><xsl:value-of select="ancestor::c02[@level='subseries']/did/unittitle/title"/><br/></xsl:if>
        <xsl:if test="descendant::container[@type='box']"><strong>Box: </strong><xsl:value-of select="descendant::container[@type='box']"/><br/></xsl:if>
        <xsl:if test="descendant::container[@type='folder']"><strong>Folder: </strong><xsl:value-of select="descendant::container[@type='folder']"/><br/></xsl:if>
        
        <!-- repository title and ID -->
        <xsl:if test="descendant::title[@type='repository']"><strong>Repository Title: </strong><xsl:value-of select="descendant::title[@type='repository']"/><br /></xsl:if>
        <xsl:if test="descendant::unitid[@type='repository']"><strong>Repository ID: </strong><xsl:value-of select="descendant::unitid[@type='repository']"/><br/></xsl:if>
        <strong>Date: </strong><xsl:value-of select="descendant::unitdate"/><br/>
        <strong>Genre: </strong> <xsl:value-of select="descendant::genreform[1]"/>
        <xsl:if test="descendant::genreform[2]">, <xsl:value-of select="descendant::genreform[2]"/></xsl:if><br/>
        <strong>Physical Description: </strong><xsl:value-of select="descendant::extent"/>, <xsl:if test="descendant::dimensions"><xsl:value-of select="descendant::dimensions"/>, </xsl:if><xsl:value-of select="descendant::physfacet[1]"/><xsl:if test="descendant::physfacet[2]">, <xsl:value-of select="descendant::physfacet[2]"/></xsl:if><br/>
        
        <!-- the following deals with the image links -->
        <xsl:choose>      
          <xsl:when test="descendant::dao">
            <strong>View images: </strong>
            <xsl:for-each select="descendant::dao">
              <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute><xsl:attribute name="target">_blank</xsl:attribute><xsl:value-of select="position()"/></xsl:element><xsl:choose>
                <xsl:when test="position() = last()"/>
                <xsl:otherwise> | </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each><br/>
          </xsl:when>
          <xsl:otherwise><strong>Images:</strong> currently unavailable<br/></xsl:otherwise>
        </xsl:choose>
        <!-- end image link code-->
        
        <!-- content section -->
        <strong>Content: </strong><xsl:apply-templates select="descendant::scopecontent/p[1]"/><xsl:if test="descendant::scopecontent/p[2]"><br/><br/><xsl:apply-templates select="descendant::scopecontent/p[2]"/></xsl:if><xsl:if test="descendant::scopecontent/p[3]"><br/><br/><xsl:apply-templates select="descendant::scopecontent/p[3]"/></xsl:if><xsl:if test="descendant::scopecontent/p[4]"><br/><br/><xsl:apply-templates select="descendant::scopecontent/p[4]"/></xsl:if><!-- the preceding rules are an attempt to deal with content descriptions with multiple paragraphs; this seemed like the easiest way to do it quickly, but is probably not the most succinct (and only accounts for up to 4 paragraphs). May want to revise the way this is handled at some point. KM, 6/8/15 --><br/><br/>
        
        
        
        <!-- the following "if" statement has been commented out so that the short dividing lines appear between each item, even if it is the last item listed in a given XML file. This is done until we figure out a way to get the individual EAD files to sort by work. KM, 7/30/15 -->
        
        <!--<xsl:if test="following-sibling::c01[@level='item'] | following-sibling::c02[@level='item']">-->
          <hr width="20%"/> <!-- this places a short horizontal bar after an item, as long as it is NOT the last item in a work section (i.e. as long as it has another item after it) -->
          <br/>
        <!--</xsl:if>-->
        
      </p>
      
    </div> 
    </xsl:for-each>
    
 
    
    
  </xsl:template>
  
   
</xsl:stylesheet>

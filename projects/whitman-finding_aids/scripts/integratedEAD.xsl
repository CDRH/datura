<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1">

  <!-- ~~~~~~~~~~~~~~~~~~
  An Integrated Finding Guide to Walt Whitman's Poetry Manuscripts
  manuscripts/finding_aids/integrated.html
  ~~~~~~~~~~~~~~~~~~~~ -->
  
  <!-- When editing this file, please refer to the Wiki entry on EAD XSLT -->
  
  <!-- This XSLT works in combination with unionguide_combiner.xsl and unionguide_combiner_step2.xsl -->
  
  <!-- This file is styling integratedEAD.xml and is producing the html file for the integrated guide -->
  
  <!-- added config-->
  <xsl:include href="../../xslt/config.xsl"/>

  <xsl:output method="html" indent="yes" encoding="utf-8" media-type="text/html"
    doctype-public="-//W3C//DTD HTML 4.0//EN"/>

  <!-- SETS UP THE STRUCTURE & ORDER OF THE OUTPUT DOCUMENT -->

  <xsl:template match="ead">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>
          <xsl:value-of select="descendant::eadheader/filedesc/titlestmt/titleproper"/>
        </title>
      </head>
      <body>

        <h1 class="docTitle">Resources</h1>

        <h2 class="docTitle">Integrated Catalog of Walt Whitman's Literary Manuscripts</h2>

        <!-- THE FOLLOWING SETS THE DISPLAY FOR THE TITLE STATEMENT -->
        <!--<h3>
          <xsl:value-of select="//titlestmt//titleproper"/>
        </h3>-->
        
        <!-- THE FOLLOWING SETS THE DISPLAY FOR THE AUTHOR / SPONSOR INFORMATION -->

        <!--<p>
         
          <xsl:apply-templates select="//titlestmt/author | //sponsor"/>

        </p>-->
        
        

        <!-- THE FOLLOWING GENERATES THE INDIVIDUAL C0 LEVEL ENTRIES -->
        <p>
          <xsl:apply-templates/>
        </p>

        <!-- THE FOLLOWING SETS THE DISPLAY FOR THE RESTRICTIONS AND USE STATEMENTS WHICH APPEARS AT THE END OF THE EAD -->
        <p>
          <hr/>
        </p>

        <p>
          <strong>
            <xsl:value-of select="//descgrp/accessrestrict/head"
            /></strong>&#160;<xsl:apply-templates select="//accessrestrict/p"/>
        </p>

        <xsl:choose>
          <xsl:when test="//userestrict">
            <p>
              <strong>
                <xsl:value-of select="//descgrp/userestrict/head"
                /></strong>&#160;<xsl:apply-templates select="//descgrp/userestrict/p"/>
            </p>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="//altformavail">
            <p>
              <strong>
                <xsl:value-of select="//descgrp/altformavail/head"
                /></strong>&#160;<xsl:apply-templates select="//descgrp/altformavail/p"/>
            </p>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>

        <p>
          <strong>
            <xsl:value-of select="//descgrp/prefercite/head"/>
          </strong> &#160;<xsl:apply-templates select="//descgrp/prefercite/p"/>
        </p>

      </body>
    </html>

  </xsl:template>

  <!-- ################################## 
Main title
-->

  <!--This template rule formats the top-level bioghist element.-->

  <xsl:template match="bioghist">
    <p>
      <span>

        <strong>
          <br/><xsl:value-of select="head"/>:<br/>
        </strong>

      </span>
    </p>

    <p>
      <span>
        <div>
          <xsl:text>For additional biographical information, see </xsl:text>
          <a href="{$siteroot}biography/walt_whitman/index.html" target="_parent"> "Walt
            Whitman,"</a>
          <xsl:text> by Ed Folsom and Kenneth M. Price, and the </xsl:text>
          <a href="{$siteroot}biography/chronology.html" target="_self"> chronology</a>
          <xsl:text> of Whitman's Life.
</xsl:text>
        </div>
      </span>
    </p>
  </xsl:template>

  <!-- ################################### -->
  <!-- The following templates format the display of various RENDER attributes.-->

  <xsl:template match="*[@render='bold']">
    <b>
      <xsl:apply-templates/>
    </b>
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
    <sup>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>
  <xsl:template match="*[@render='quoted']">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  <xsl:template match="*[@render='boldquoted']">
    <b>
      <xsl:text>"</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>"</xsl:text>
    </b>
  </xsl:template>
  <xsl:template match="*[@render='boldunderline']">
    <b>
      <u>
        <xsl:apply-templates/>
      </u>
    </b>
  </xsl:template>
  <xsl:template match="*[@render='bolditalic']">
    <b>
      <i>
        <xsl:apply-templates/>
      </i>
    </b>
  </xsl:template>
  <xsl:template match="*[@render='boldsmcaps']">
    <span class="smallcaps">
      <b>
        <xsl:apply-templates/>
      </b>
    </span>
  </xsl:template>
  <xsl:template match="*[@render='smcaps']">
    <span class="smallcaps">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!--          	   CENTERING		     -->

  <xsl:template match="*[@rend='center']">
    <div class="textCenter">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- suppress eadid -->
  <xsl:template match="//eadid"> </xsl:template>

  <!-- header info -->
  <xsl:template match="//titlestmt"> </xsl:template>

  <xsl:template match="//publicationstmt"> </xsl:template>

  <xsl:template match="//profiledesc"> </xsl:template>

  <xsl:template match="//frontmatter"> </xsl:template>

  <!-- ######################################### -->
  <!-- suppresses archdesc info -->

  <xsl:template match="//archdesc/did/unittitle"/>

  <xsl:template match="//archdesc/did/unitid"> </xsl:template>

  <xsl:template match="//archdesc/did/origination"/>

  <xsl:template match="//archdesc/did/physdesc"/> 

  <xsl:template match="//archdesc/did/repository"/>

  <xsl:template match="//address"/> 

<!-- Styles Abstract -->

  <xsl:template match="//abstract">
    <p>
      <span>
        <strong>Abstract:</strong>
        <br/>
        <br/>
        <xsl:apply-templates/>
        <br/>
        <br/>
      </span>
    </p>
  </xsl:template>

<!-- Surpressing various elements -->

  <xsl:template match="//accessrestrict"> </xsl:template>

  <xsl:template match="//userestrict"> </xsl:template>

  <xsl:template match="//prefercite"> </xsl:template>

  <xsl:template match="//altformavail"> </xsl:template>


  <!-- THE FOLLOWING IS THE TEMPLATE FOR THE SCOPECONTENT SECTION IN THE HEADER -->

  <xsl:template match="//scopecontent[@id='sc001']">
    <p>
      <span>
        <strong>
          <xsl:value-of select="head"/>:&#160; </strong>
      </span>
    </p>

    <xsl:for-each select="p">
      <p>
        <span>
          <xsl:apply-templates select="."/>
        </span>
      </p>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="ead/archdesc/scopecontent/head">
    <b>
      <a name="a3">
        <xsl:apply-templates/>
      </a>
    </b>
  </xsl:template>

  <xsl:template match="//controlaccess">
    <p><strong>
        <br/><xsl:value-of select="head"/>: </strong>&#160; <xsl:for-each select="persname">
        <p class="manuscriptPersname">
          <xsl:apply-templates select="."/>
        </p></xsl:for-each>
      <xsl:for-each select="subject">
        <p class="manuscriptsSubject">
          <xsl:apply-templates select="."/>
        </p>
      </xsl:for-each>
    </p>
  </xsl:template>

  <xsl:template match="title[@render='doublequote']">
    <xsl:choose>
      <xsl:when test="parent::unittitle/parent::did/unitid">
        <xsl:choose>
          <xsl:when test="contains(ancestor::c02/descendant::unitid[@type='WWA'],'##')">
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="IDbase" select="ancestor::c02/descendant::unitid[@type='WWA']"/>
            <xsl:variable name="uniqueID">
              <xsl:value-of select="$IDbase"/>
              <xsl:text>.xml</xsl:text>
            </xsl:variable>
            <xsl:choose>

              <xsl:when test="file:exists(file:new('../../manuscripts/tei/', $uniqueID))"
                xmlns:file="java:java.io.File">
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="$siteroot"/><xsl:text>manuscripts/transcriptions/</xsl:text>
                    <xsl:value-of select="ancestor::c02/descendant::unitid[@type='WWA']"/>.html </xsl:attribute>
                  <xsl:apply-templates/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>"<xsl:apply-templates/>"</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- render italics -->

  <xsl:template match="*[@render='italic']">
    <i>
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <xsl:template match="//dsc/head">
    <hr/>
    <div class="manuscriptsDscHead">
      <h3>
        <xsl:apply-templates/>
      </h3>
    </div>
  </xsl:template>

  <xsl:template match="dsc">
    <xsl:apply-templates>
      <xsl:sort select="descendant::unittitle[@type='sort']/title" order="ascending"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- deals with external links <extref>s -->
  
  <xsl:template match="extref">
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
      <xsl:attribute name="target">_blank</xsl:attribute>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  
  <!-- structuring and ordering the works (all of which are contained within <c01>s) -->

  <xsl:template match="c01[@level='class']">
    <hr/>
    <table width="90%" border="0" cellspacing="0" cellpadding="0" align="center">
      <tr>
        <td>
          <xsl:apply-templates select="child::did"/>

          <xsl:apply-templates select="descendant::c02[@level='item']"/>
        
        </td>
      </tr>
    </table>
    <!--<p/>-->
  </xsl:template>
  
  
  <!-- puts the work title in a specially-styled <h1> -->
  <xsl:template match="unittitle[@type='uniform']">
    <h1 class="eadworktitle"><xsl:value-of select="."/></h1>
  </xsl:template>
  
  <!-- This suppresses the "sort" title in each work. KM -->
  <xsl:template match="unittitle[@type='sort']"/>
  
 
  <!-- new template that orders all of the information within the individual items (<c02>s) -->
  
  <xsl:template match="//c02">
    
    <div class="entry">
     <p><strong>Whitman Archive Title: </strong> <xsl:value-of select="descendant::title[not(@type='repository')]"/><br />
      <strong>Whitman Archive ID: </strong> <xsl:value-of select="descendant::unitid[@type='WWA']"/><br/>
       <!-- the following deals with the repository info -->
       <xsl:choose>
         <xsl:when test="descendant::extptr[@href='wwh.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Whitman_House">The Walt Whitman House in
             Camden</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='yal.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Yale">Yale University: Yale Collection of American Literature, Beinecke Rare
             Book and Manuscript Library</a><br/>
         </xsl:when>
                  
         <xsl:when test="descendant::extptr[@href='amh.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Amherst">Amherst College Archives and Special
             Collections</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='aas.ead01.xml']">
           <b>Repository:</b>&#160;<a href="American_Antiquarian_Society">American Antiquarian Society: Bolton-Stanwood Family
             Papers</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='bec.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Buffalo_Erie_County">Buffalo and Erie County Public Library, Buffalo, New York: James Fraser Gluck Papers</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='bpl.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Boston_Public_Library">Boston Public Library: The Walt Whitman Collection</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='bos.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Boston_U">Boston University: The Alice and Rollo G. Silver Collection</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='bow.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Bowdoin">Bowdoin College Library: Abbott Memorial Collection</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='brl.ead01.xml']">
           <b>Repository:</b>&#160;<a href="British_Library">The British
             Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='brn.ead01.xml']">
         <b>Repository:</b>&#160;<a href="Brown-Hay">Brown University: John Hay Papers</a><br/>
           </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='brn.ead02.xml']">
           <b>Repository:</b>&#160;<a href="Brown-Harris">Brown University: Harris Collection of American Poetry and Plays</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='byu.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Brigham_Young">Brigham Young University: L. Tom Perry Special Collections</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='dar.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Dartmouth">Dartmouth College: The Rauner Special Collections Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='duk.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Duke">Duke University: The Trent Collection of Whitmaniana</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='fol.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Folger_Shakespeare">Folger Shakespeare Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='har.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Harvard">Harvard University: Manuscripts Department, Houghton Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='hav.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Haverford">Haverford College: Quaker and Special
             Collections</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='hun.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Huntington_CA">The Huntington Library, Art Collections, and
             Botanical Gardens</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='hpl.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Huntington_Public_Library">Huntington Public Library, Huntington, New York: Treasures From Walt Whitman</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='ihm.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Iowa_Historical_Museum">Iowa Historical Museum (Des Moines)</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='jhu.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Johns_Hopkins">The Johns Hopkins University: Special Collections, The Milton S.
             Eisenhower Library, The Sheridan Libraries</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='lcl.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Liverpool_Central_Library">Liverpool Central Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='loc.ead02.xml']">
           <b>Repository:</b>&#160;<a href="Library_of_Congress-Feinberg">Library of Congress: The Charles E. Feinberg
             Collection of the Papers of Walt Whitman</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='loc.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Library_of_Congress-Harned">Library of Congress: The Thomas Biggs Harned
             Collection of the Papers of Walt Whitman</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='loc.ead03.xml']">
           <b>Repository:</b>&#160;<a href="Library_of_Congress-Batchelder">Library of Congress: John D. Batchelder
             Collection</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='loc.ead04.xml']">
           <b>Repository:</b>&#160;<a href="Library_of_Congress-Elliot">Library of Congress: Charles N. Elliot Collection</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='loc.ead05.xml']">
           <b>Repository:</b>&#160;<a href="Library_of_Congress-Hellman">Library of Congress: George S. Hellman Collection</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='loc.ead06.xml']">
           <b>Repository:</b>&#160;<a href="Library_of_Congress-Whitman">Library of Congress: Walt Whitman Collection</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='mcf.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Musee_de_la_cooperation">Mus&#233;e de la Coop&#233;ration Franco-Am&#233;ricaine</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='mil.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Mills">Mills College: Albert M. Bender Collection, Special Collections
             Department, F. W. Olin Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='nby.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Newberry">Newberry Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='nyp.ead01.xml']">
           <b>Repository:</b>&#160;<a href="NY_Public_Library-Berg">New York Public Library: The Henry W. and Albert A. Berg
             Collection of English and American Literature</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='nyp.ead02.xml']">
           <b>Repository:</b>&#160;<a href="NY_Public_Library-Lion">New York Public Library: The Oscar Lion Collection of Walt
             Whitman</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='owu.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Ohio_Wesleyan">Ohio Wesleyan
             University, Delaware OH: The Bayley-Whitman Collection</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='pru.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Princeton">Princeton University Library: Manuscripts Division, Department of Rare Books
             and Special Collections</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='pml.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Pierpont_Morgan">The Pierpont Morgan Library, New
             York</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='uri.ead01.xml']">
           <b>Repository:</b>&#160;<a href="U_Rhode_Island">University of Rhode Island: Special Collections and University Archives, Robert L. Carothers Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='rml.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Rosenbach_Museum">Rosenbach Museum and Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='rut.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Rutgers">Rutgers, The State University of New Jersey: Special Collections and University Archives</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='sal.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Salisbury_House">Salisbury House and Gardens, Des Moines, Iowa</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='tem.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Temple">Temple University: Rare Books and Manuscripts, Special Collections</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='ucb.ead01.xml']">
           <b>Repository:</b>&#160;<a href="UC_Berkeley">University of California,
             Berkeley: The Livezey-Walt Whitman Collection, Rare
             Books and Special Collections, The Bancroft Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='unc.ead01.xml']">
           <b>Repository:</b>&#160;<a href="U_North_Carolina">University of North Carolina at Chapel
             Hill: Walt Whitman Papers</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='upa.ead01.xml']">
           <b>Repository:</b>&#160;<a href="U_Pennsylvania">University of Pennsylvania: Walt Whitman Collection, Rare
             Book &#38; Manuscript Library, </a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='usc.ead01.xml']">
           <b>Repository:</b>&#160;<a href="U_South_Carolina">University of South Carolina: Joel
             Myerson Collection of Nineteenth-Century American Literature</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='tex.ead01.xml']">
           <b>Repository:</b>&#160;<a href="U_Texas">The University of Texas at Austin: The Walt Whitman Collection, Harry Ransom
             Humanities Research Center</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='tul.ead01.xml']">
           <b>Repository:</b>&#160;<a href="U_Tulsa">University of
             Tulsa: Walt Whitman Ephemera</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='uva.ead01.xml']">
           <b>Repository:</b>&#160;<a href="U_Virginia">University of Virginia: Papers of Walt Whitman, Clifton
             Waller Barrett Library of American Literature, Albert H. Small Special Collections
             Library</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='wau.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Washington_U">Washington University: George N. Meissner Collection, Department of
             Special Collections</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='med.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Unlocated">Unlocated Manuscripts</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='prc.ead01.xml']">
           <b>Repository:</b>&#160;<a href="Private_Reed">Private Collection of Kendall Reed</a><br/>
         </xsl:when>
         
         <xsl:when test="descendant::extptr[@href='prc.ead02.xml']">
           <b>Repository:</b>&#160;<a href="Private_Folsom">Private Collection of Ed Folsom</a><br/>
         </xsl:when>
         
         <xsl:otherwise/> 
         
       </xsl:choose>
       <!-- end repository info code -->
       
       <!--container info -->
       <xsl:if test="descendant::container[@type='series']"><strong>Series: </strong><xsl:value-of select="descendant::container[@type='series']"/><br/></xsl:if>
       <xsl:if test="descendant::container[@type='box']"><strong>Box: </strong><xsl:value-of select="descendant::container[@type='box']"/><br/></xsl:if>
       <xsl:if test="descendant::container[@type='folder']"><strong>Folder: </strong><xsl:value-of select="descendant::container[@type='folder']"/><br/></xsl:if>
      
      <!-- repository title and ID-->
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
       <xsl:if test="following-sibling::c02[@level='item']">
         <hr width="20%"/> <!-- this places a short horizontal bar after an item, as long as it is NOT the last item in a work section (i.e. as long as it has another item after it) -->
         <br/>
       </xsl:if>
       
     </p>
    </div>
   
  </xsl:template>
  
  <!-- this suppresses work IDs -->
  <xsl:template match="//unitid[@type='work']"/>

</xsl:stylesheet>

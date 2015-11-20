<?xml version="1.0"?>

<!-- this stylesheet was created by Brian L. Pytlik Zillig -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1">

   <xsl:output method="xml" indent="yes" encoding="utf-8"/>

   <xsl:strip-space elements="*"/>

   <xsl:template match="ead">

      <xsl:document>

         <xsl:processing-instruction name="xml-stylesheet">
            href="../../saxon/whitman/xmlfindaids/shared/styles/eadwhit.xsl" type="text/xsl" </xsl:processing-instruction>

         <ead audience="external" relatedencoding="MARC21">
            <eadheader audience="internal" langencoding="iso639-2b" scriptencoding="iso15924"
               relatedencoding="marc21" repositoryencoding="iso15511" countryencoding="iso3166-1"
               dateencoding="iso8601" findaidstatus="edited-full-draft" id="a0">
               <eadid countrycode="us" mainagencycode="NbU" identifier="union.ead01"
                  >union.ead01</eadid>
               <filedesc>
                  <titlestmt>
                     <titleproper encodinganalog="245$a">An Integrated Catalog of Walt
                        Whitman's Literary Manuscripts</titleproper>
                     <author>Original records created or revised by the <emph render="italic">Walt
                        Whitman Archive</emph> and the University of Nebraska-Lincoln Libraries. </author>
                     <sponsor>Encoded Archival Description completed through the assistance of the
                        Gladys Krieble Delmas Foundation, the University of Nebraska Research
                        Council, the Institute for Museum and Library Services, and the National
                        Endowment for the Humanities.</sponsor>
                  </titlestmt>
                  <publicationstmt>
                     <publisher encodinganalog="260$b">Published by <emph render="italic">The Walt
                        Whitman Archive</emph> in collaboration with the University of
                        Nebraska-Lincoln Libraries. </publisher>
                     <date encodinganalog="260$c">2015</date>
                     <address>
               <addressline>29 Love Library </addressline>
               <addressline>P.O. Box 884100</addressline>
               <addressline>University of Nebraska-Lincoln</addressline>
               <addressline>Lincoln, NE 68508</addressline>
            </address>
                  </publicationstmt>
               </filedesc>
               <profiledesc>
                  <creation>Machine-readable catalog and XSLT stylesheets created by Andrew
                     Jewell, <emph render="italic">The Walt Whitman Archive</emph>, Mary Ellen
                     Ducey, Brian Pytlik Zillig, and Brett Barney, University of Nebraska-Lincoln
                     Libraries. <date>2003</date>. Revised and expanded by Kevin McMullen, Caterina
                     Bernardini, and Janel Cayer, <emph render="italic">The Walt Whitman
                     Archive</emph>, and Brett Barney, University of Nebraska-Lincoln Libraries.
                     <date>2014</date></creation>
                  <langusage>Finding aid written in <language encodinganalog="546" langcode="eng"
                     >English</language>.</langusage>
               </profiledesc>
            </eadheader>
            <frontmatter>
               <titlepage id="tp001">
                  <titleproper encodinganalog="245$a"/>
                  <publisher>Published by <emph render="italic">The Walt Whitman Archive</emph> in
                     collaboration with the University of Nebraska-Lincoln Libraries. </publisher>
                  <date>2015</date>
               </titlepage>
            </frontmatter>
            <archdesc audience="external" level="otherlevel" type="inventory"
               relatedencoding="marc21">
               <did id="al">
                  <unittitle audience="external" label="Title:" encodinganalog="245$a">An Integrated
                     Finding Guide to Walt Whitman's Literary Manuscripts</unittitle>
                  <unitid audience="external" label="Collection Number:" encodinganalog="099"
                     repositorycode="XXXXX" countrycode="us">N/A</unitid>
                  <origination audience="external" label="Creator:">
                     <persname encodinganalog="100">Whitman, Walt, 1819-1892</persname>
                  </origination>
                  <physdesc audience="external" encodinganalog="300$a">
                     <genreform>Manuscripts</genreform>
                  </physdesc>
                  <repository encodinganalog="852$a" label="Repository:">
                     <corpname encodinganalog="852$a">
                        <emph render="italic">The Walt Whitman Archive</emph>
                     </corpname>

                  </repository>
                  <abstract>This Integrated Catalog was created by the <emph render="italic">Walt Whitman Archive</emph> through the work of the EAD Project Team at the University of Nebraska-Lincoln. The machine-readable catalog, EAD encoding, and XSLT stylesheets were created by Brett Barney, Caterina Bernardini, Janel Cayer, Mary Ellen Ducey, Andrew Jewell, Courtney Lawton, Elizabeth Lorang, Kevin McMullen, and Brian Pytlik Zillig, University of Nebraska-Lincoln Libraries and English Department. Kenneth M. Price, co-editor of the Walt Whitman Archive, and Katherine L. Walter were primary investigators for an initial grant received from the Institute for Museum and Library Services, which provided major funding for an early stage of this project. Additional funding provided by the Gladys Krieble Delmas Foundation and the University of Nebraska Research Council helped further advance our early work on an Integrated Guide to Walt Whitman's Poetry Manuscripts. After completion of the poetry manuscripts integrated guide, we sought to extend the project to all Whitman manuscripts, poetry and prose alike.  That work has received generous support from the National Endowment for the Humanities. Our recent efforts have been dedicated to writing item-level entries for those prose manuscripts which could be identified as contributing directly to a published work. We hope ultimately to extend our treatment of Whitman's prose to all manuscripts, whether or not the manuscript led to a known publication.</abstract>
               </did>
               <descgrp id="ds001" type="admininfo">
                  <accessrestrict audience="external" encodinganalog="506" id="a14">
                     <head>Restrictions on Original Materials:</head>
                     <p>Please consult with individual repositories.</p>
                  </accessrestrict>
                  <userestrict encodinganalog="540" id="a15">
                     <head>Copyright:</head>
                     <p>The use of Archives and Special Collections material is governed by the U.S.
                        Copyright Law (title 17 U.S. Code). </p>
                  </userestrict>
                  <prefercite encodinganalog="524" id="a18">
                     <head>Preferred Citation:</head>
                     <p>To identify this Integrated Catalog as a source, see the <emph render="italic"
                        >Archive's </emph><extref href="www.whitmanarchive.org/fair_use/index.html"
                        >"Conditions of Use"</extref> page.</p>
                  </prefercite>

                  <altformavail type="paper" encodinganalog="530" id="a17">
                     <head>Alternative Format:</head>
                     <p>For information on original Whitman manuscripts held at specific
                        institutions, please visit the individual repository catalogs through
                        the link provided under the "Repository" heading of each entry.</p>
                  </altformavail>
               </descgrp>
               <scopecontent id="sc001">
                  <head>Scope and Content</head>
                  <p>This Integrated Catalog of Walt Whitman's Literary Manuscripts provides item-level descriptions and, when available, images of all identified literary manuscripts located in
                     archival repositories around the world. This Catalog deals only with items <emph render="italic">Whitman Archive</emph> staff have deemed poetry and/or prose manuscripts. Nearly all of Whitman's poetry manuscripts are represented in the Catalog. Because of the sheer volume of manuscripts that could be categorized as "prose" (in effect, any item handwritten by Whitman that was not poetry, correspondence, or marginalia) we have limited our item-level descriptions of prose material to only those items that can be identified, with reasonable confidence, as having contributed to a piece of published prose. However, we intend to eventually include item-level descriptions for all prose manuscripts.</p>
                  
                  <p>This Integrated Catalog is organized alphabetically by uniform work title and chronologically by composition date within each work. We define a "work" as the abstract idea of an individual piece of writing (poem, prose section, prose essay, etc.). We derive the uniform work title from the final published title used by Whitman during his lifetime. In most cases this is the title assigned in the final printing of <emph render="italic">Leaves of Grass</emph> (1891-92) or <emph render="italic">Complete Prose Works</emph> (1892). It should be noted, however, that some poems and prose pieces were published in earlier volumes but were not retained in these final volumes. Thus, for example, a poem that appeared in the 1860, 1867, and 1872 editions of <emph render="italic">Leaves of Grass</emph> but then was dropped from future printings would take as its uniform title that which Whitman gave to it in the 1872 edition. If we are unable to determine a particular manuscript's relationship to a published work, we consider it a work unto itself and assign a uniform work title based on the first words appearing on the manuscript.</p>
                  
                  <p>Uniform work titles are displayed in large font, with individual items related to each work described in detail below them. The grouping of individual manuscripts by work is intended both for the navigational ease of the site's users (since users are most familiar with Whitman’s final titles) as well as to reflect the complex nature of Whitman's composition and revision methods, in which a single manuscript may contain bits of text that eventually found their way into several different works. Thus, a manuscript may appear multiple times within the Integrated Catalog, listed separately under each work to which it contributed.</p>
                  
                  <p>Each item-level entry provides a title, date, genre, repository location information, physical characteristics, and a description of the textual content of the item. Access to images of the original item are also provided whenever possible.</p>
                     
                    
               </scopecontent>

               <bioghist id="bh001">
                  <head>Biographical Information</head>
                  <p/>
               </bioghist>

               <controlaccess id="ca001">
                  <head>Subjects</head>
                  <persname encodinganalog="600">Whitman, Walt, 1819-1892</persname>
                  <subject encodinganalog="650">Whitman, Walt, 1819-1892--Manuscripts</subject>
                  <subject encodinganalog="650">Poets, American--19th century</subject>
               </controlaccess>
               <dsc id="dc001" type="in-depth">

                  <xsl:call-template name="c01"/>


               </dsc>
            </archdesc>
            <tmp/>
         </ead>

      </xsl:document>
   </xsl:template>

   <xsl:template match="//eadheader">
      <xsl:copy-of select="."/>
   </xsl:template>

   <xsl:template match="//frontmatter">
      <xsl:copy-of select="."/>
   </xsl:template>

   <xsl:template name="c01">
      <xsl:for-each select="//unitid[@type='work'][not(.=following::unitid)]">
         <xsl:variable name="worksfile">../../work_files/<xsl:value-of select="."
            />.xml</xsl:variable>
         <xsl:variable name="workID">
            <xsl:value-of select="."/>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="contains(.,'##')"><!-- hide any temp workIDs --></xsl:when>
            <xsl:when test="not(contains(., 'xxx'))"/>

            <xsl:otherwise>
               <c01 level="class">
                  <did>
                     <unittitle type="uniform">
                        <xsl:element name="title">
                           <xsl:value-of
                              select="document($worksfile)//titleStmt/title[@type='uniform']"/>
                        </xsl:element>
                     </unittitle>
                     <unittitle type="sort">
                        <xsl:element name="title">
                           <xsl:variable name="uniformTitle">
                              <xsl:value-of select="document($worksfile)//titleStmt/title[@type='uniform']"/>
                           </xsl:variable>
                           <!-- <xsl:value-of select="lower-case($uniformTitle)"></xsl:value-of>-->
                          <!-- <xsl:choose>
                              <xsl:when test="substring-after($uniformTitle,'''')"><xsl:value-of select=""></xsl:value-of><xsl:value-of select="lower-case(substring-after($uniformTitle,''''))"/></xsl:when>
                              <xsl:otherwise><xsl:value-of select="lower-case($uniformTitle)"/></xsl:otherwise>
                           </xsl:choose>-->
                           <xsl:value-of select="lower-case(replace($uniformTitle, '[^(^\w)^\s]', ''))"/>
                        </xsl:element>
                     </unittitle>
                     <unitid type="work">
                        <xsl:value-of select="."/>
                     </unitid>
                  </did>

                  <!-- the following generates the correct c02s within the appropriate c01s -->
                  <!-- Here we gather all of the c02s for each work and place them in a variable. This is done in order to sort the c02s by date in the output file.  -->
                  <xsl:variable name="tempc02Group">
                     <xsl:for-each select="ancestor::ead//unitid[@type='work']">
                        <xsl:choose>
                           <xsl:when test="contains(., '##')"
                              ><!-- hide these temp entries --></xsl:when>
                           <xsl:when test="contains(., $workID)">

                              <c02 level="item">
                                 <did>
                                    <!-- <unitid type="work"><xsl:value-of select="." /></unitid> -->
                                    <xsl:copy-of
                                       select="ancestor-or-self::c01/descendant::container[@type='series']"/>
                                    <xsl:copy-of
                                       select="ancestor-or-self::c01/descendant::container[@type='box']"/>
                                    <xsl:copy-of
                                       select="ancestor-or-self::c01/descendant::container[@type='folder']"/>
                                    <xsl:copy-of select="ancestor-or-self::c01/descendant::unitid"/>
                                    <xsl:copy-of
                                       select="ancestor-or-self::c01/descendant::unittitle"/>
                                    <xsl:copy-of select="ancestor-or-self::c01/descendant::unitdate"/>
                                    <xsl:copy-of select="ancestor-or-self::c01/descendant::physdesc"/>
                                    <xsl:copy-of select="ancestor-or-self::c01/descendant::dao"/>
                                 </did>
                                 <xsl:copy-of
                                    select="ancestor-or-self::c01/descendant::scopecontent"/>
                                 <xsl:copy-of select="ancestor-or-self::c01/descendant::extptr"/>
                              </c02>

                           </xsl:when>
                           <xsl:otherwise>
                              <!-- hide all nodes not equal to value of the current node -->
                           </xsl:otherwise>
                        </xsl:choose>

                     </xsl:for-each>
                  </xsl:variable>

                  <!-- here we call the variable for the c02s that we defined above, and sort the items in it by date. -->
                  <xsl:for-each select="$tempc02Group/child::c02">
                     <xsl:sort select="descendant::unitdate/@normal" data-type="text"
                        order="ascending"/>
                     <xsl:copy-of select="."/>
                  </xsl:for-each>




               </c01>
            </xsl:otherwise>

         </xsl:choose>
      </xsl:for-each>



   </xsl:template>







</xsl:stylesheet>

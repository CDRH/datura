<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1">

   <xsl:output method="xml" indent="yes" encoding="utf-8"/>

   <xsl:strip-space elements="*"/>

   <xsl:template match="ead">
      <!-- All of this metadata is not actually being pulled into the final output file, so any edits made here will not be reflected on the live site. Edits to metadata (such as titles, abstract, scope and content descriptions, etc., should be made in the "unionguide_combiner_step2.xsl" file. KM -->
      <xsl:document>
         <ead audience="external" relatedencoding="MARC21">
            <eadheader audience="internal" langencoding="iso639-2b" scriptencoding="iso15924"
               relatedencoding="marc21" repositoryencoding="iso15511" countryencoding="iso3166-1"
               dateencoding="iso8601" findaidstatus="edited-full-draft" id="a0">
               <eadid countrycode="us" mainagencycode="NbU" identifier="union.ead01">union.ead01</eadid>
               <filedesc>
                  <titlestmt>
                     <titleproper encodinganalog="245$a">An Integrated Catalog of Walt
                        Whitman's Literary Manuscripts</titleproper>
                     <author>Original records created or revised by the <emph render="italic">Walt
                           Whitman Archive</emph> and the University of Nebraska-Lincoln Libraries. </author>
                     <sponsor>Encoded Archival Description completed through the assistance of the
                        Gladys Krieble Delmas Foundation, the University of Nebraska Research
                        Council, the Institute for Museum and Library Services, and the National Endowment for the Humanities.</sponsor>
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
                  <creation>Machine-readable finding aid and XSLT conflation created by Andrew
                     Jewell, <emph render="italic">The Walt Whitman Archive</emph>, Mary Ellen
                     Ducey, Brian Pytlik Zillig, and Brett Barney, University of Nebraska-Lincoln
                     Libraries. <date>2003</date>. Revised and expanded by Kevin McMullen, Caterina Bernardini, and Janel Cayer, <emph render="italic">The Walt Whitman Archive</emph>, and Brett Barney, University of Nebraska-Lincoln Libraries. <date>2014</date></creation>
                  <langusage>Finding aid written in <language encodinganalog="546" langcode="eng"
                        >English</language>.</langusage>
               </profiledesc>
            </eadheader>
            <frontmatter>
               <titlepage id="tp001">
                  <titleproper encodinganalog="245$a"/>
                  <publisher>Published by <emph render="italic">The Walt Whitman Archive</emph> in
                     collaboration with the University of Nebraska-Lincoln Libraries. </publisher>
                  <date>2014</date>
               </titlepage>
            </frontmatter>
            <archdesc audience="external" level="otherlevel" type="inventory"
               relatedencoding="marc21">
               <did id="al">
                  <unittitle audience="external" label="Title:" encodinganalog="245$a">An Integrated Catalog of Walt Whitman's Literary Manuscripts</unittitle>
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

                  </repository><!-- This abstract is not actually the one being pulled into the final output file, so any edits made here will not be reflected on the live site. Edits should be made in the "unionguide_combiner_step2.xsl" file. KM -->
                  <abstract>This integrated electronic guide was created by the <emph
                        render="italic">Walt Whitman Archive</emph> through the work of the EAD
                     Project Team at the University of Nebraska-Lincoln. The machine-readable
                     finding aid, EAD encoding, and XSLT conflation were completed by Andrew Jewell,
                     Mary Ellen Ducey, Brian Pytlik Zillig, and Brett Barney, University of
                     Nebraska-Lincoln Libraries. Kenneth M. Price, co-editor of the <emph
                        render="italic">Walt Whitman Archive</emph>, and Katherine L. Walter are
                     primary investigators for a grant received from the Institute for Museum and
                     Library Services, which provided major funding for the completion of this
                     project. Additional funding was provided by the Gladys Krieble Delmas
                     Foundation and the University of Nebraska Research Council.</abstract>
               </did>
               <descgrp id="ds001" type="admininfo">
                  <accessrestrict audience="external" encodinganalog="506" id="a14">
                     <head>Restrictions on Original Materials:</head>
                     <p>Please consult with repository.</p>
                  </accessrestrict>
                  <userestrict encodinganalog="540" id="a15">
                     <head>Copyright:</head>
                     <p>The use of Archives and Special Collections material is governed by the U.S.
                        Copyright Law (title 17 U.S. Code). </p>
                  </userestrict>
                  <prefercite encodinganalog="524" id="a18">
                     <head>Preferred Citation:</head>
                     <p>To identify this finding aid as a source, see the <emph render="italic"
                           >Archive's </emph><extref
                           href="www.whitmanarchive.org/fair_use/index.html">"Conditions of
                        Use"</extref> page.</p>
                  </prefercite>

                  <altformavail type="paper" encodinganalog="530" id="a17">
                     <head>Alternative Format</head>
                     <p>For information on original Whitman manuscripts held at specific
                        institutions, please visit the complete finding aids for those items through
                        the links provided after each item entry.</p>
                  </altformavail>
               </descgrp>
               <scopecontent id="sc001">
                  <head>Scope and Content </head>
                  <p>This union guide to Whitman's literary manuscripts arranges by title all
                     identified poetry manuscripts located in archival repositories throughout the
                     United States and the United Kingdom. Each entry provides a title, date, and
                     specific information about each item, including a physical description when
                     available. We also include a a uniform title based whenever possible on the
                     final printing of Whitman's writings in <emph render="italic">Leaves of
                     Grass</emph> (1891-92) or <emph render="italic">Complete Prose Works</emph>
                     (1892). Works that went through multiple revisions but did not appear in either
                     one of these final collections of Whitman's poetry and prose use the final
                     title as the uniform title. (That is, for example, a poem that appeared in the
                     1860, 1867, and 1872 editions of <emph render="italic">Leaves of Grass</emph>
                     but then was dropped from furture printings would take as its uniform title
                     that given to it in the 1872 edition.) Access to an image of the original item,
                     a transcription of the item, and a link to the original finding aid are
                     provided.</p>
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
                  <head>head</head>
                  
                  <!-- Originally, the file paths for the individual files below read ead/filename.xml (e.g. ead/yal.ead01.xml)
                       However, since the location of the xsl directory moved last year, the file paths needed to change. gk 07/24/14-->

                  <!-- American Antiquarian Society -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/aas.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">aas.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Amherst College Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/amh.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">amh.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Boston Public Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/bpl.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">bpl.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Boston University -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/bos.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">bos.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Brigham Young University -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/byu.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">byu.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>


                  <!-- British Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/brl.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">brl.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Buffalo and Erie Contry Public Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/bec.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">bec.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Brown University, John Hay Collection -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/brn.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">brn.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Brown University, Harris Collection -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/brn.ead02.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">brn.ead02.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Bowdoin College -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/bow.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">bow.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Bancroft Library, University of California, Berkeley -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/ucb.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">ucb.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Dartmouth College -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/dar.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">dar.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Duke University -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/duk.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">duk.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Folger Shakespeare Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/fol.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">fol.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Harvard University -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/har.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">har.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Haverford College -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/hav.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">hav.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Johns Hopkins University -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/jhu.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">jhu.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Huntington Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/hun.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">hun.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Huntington Public Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/hpl.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">hpl.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Iowa Historical Museum -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/ihm.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">ihm.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Liverpool Central Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/lcl.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">lcl.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Batchelder Collection, The Library of Congress -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/loc.ead03.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">loc.ead03.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Elliot Collection, The Library of Congress -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/loc.ead04.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">loc.ead04.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Feinberg Collection, The Library of Congress -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/loc.ead02.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <!-- following rule added to try to pull in series info; will have to come back to this. KM-->
                        <did><xsl:if test="ancestor::c01[@level='series']"><container type="series"><xsl:value-of select="ancestor::c01[@level='series']/did/unittitle"/></container></xsl:if>
                           <xsl:copy-of select="./did/descendant::*"/></did>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">loc.ead02.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Harned Collection, The Library of Congress -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/loc.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">loc.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Hellman Collection, The Library of Congress -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/loc.ead05.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">loc.ead05.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                 
                  <!-- Walt Whitman Collection, The Library of Congress -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/loc.ead06.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">loc.ead06.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Manchester University, C. F. Sixsmith Collection of Miscellanea
<xsl:for-each select="document('../../../docs/M1330.xml')//did/parent::*[@level='item']">
<xsl:element name="c01">
<xsl:attribute name="level">item</xsl:attribute>
<xsl:copy-of select="./did"/>
<xsl:copy-of select="./scopecontent"/>
<xsl:element name="extptr">
<xsl:attribute name="href">M1330.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute></xsl:element>
</xsl:element>
</xsl:for-each>
-->

                  <!-- Manchester University, C. F. Sixsmith Collection of Printed and Photographic Material
<xsl:for-each select="document('../../../docs/M1331.xml')//did/parent::*[@level='item']">
<xsl:element name="c01">
<xsl:attribute name="level">item</xsl:attribute>
<xsl:copy-of select="./did"/>
<xsl:copy-of select="./scopecontent"/>
<xsl:element name="extptr">
<xsl:attribute name="href">M1331.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute></xsl:element>
</xsl:element>
</xsl:for-each>
 -->

                  <!-- Manchester University, C. F. Sixsmith Collection of Traubel Correspondence
<xsl:for-each select="document('../../../docs/M1172.xml')//did/parent::*[@level='item']">
<xsl:element name="c01">
<xsl:attribute name="level">item</xsl:attribute>
<xsl:copy-of select="./did"/>
<xsl:copy-of select="./scopecontent"/>
<xsl:element name="extptr">
<xsl:attribute name="href">M1172.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute></xsl:element>
</xsl:element>
</xsl:for-each>
 -->

                  <!-- Manchester University, C. F. Sixsmith Walt Whitman Collection
<xsl:for-each select="document('../../../docs/M1170.xml')//did/parent::*[@level='item']">
<xsl:element name="c01">
<xsl:attribute name="level">item</xsl:attribute>
<xsl:copy-of select="./did"/>
<xsl:copy-of select="./scopecontent"/>
<xsl:element name="extptr">
<xsl:attribute name="href">M1170.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute></xsl:element>
</xsl:element>
</xsl:for-each>
 -->

                  <!-- Manchester University, Papers Relating to J.W. Wallace and the Bolton Whitman Fellowship
<xsl:for-each select="document('../../../docs/M1186.xml')//did/parent::*[@level='item']">
<xsl:element name="c01">
<xsl:attribute name="level">item</xsl:attribute>
<xsl:copy-of select="./did"/>
<xsl:copy-of select="./scopecontent"/>
<xsl:element name="extptr">
<xsl:attribute name="href">M1186.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute></xsl:element>
</xsl:element>
</xsl:for-each>
 -->

                  <!-- Mills College, Albert M. Bender Collection -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/mil.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">mil.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Mus&#233;e de la Coop&#233;ration Franco-Am&#233;ricaine -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/mcf.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">mcf.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                                    
                  <!-- Newberry Library -->
                  <xsl:for-each select="document('../../manuscripts/ead/nby.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">nby.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- New York Public Library, Henry W. and Albert A. Berg Collection -->
                  <xsl:for-each select="document('../../manuscripts/ead/nyp.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">nyp.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- New York Public Library, Oscar Lion Collection -->
                  <xsl:for-each select="document('../../manuscripts/ead/nyp.ead02.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">nyp.ead02.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  
                  <!-- Ohio Wesleyan University, The Bayley-Whitman Collection -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/owu.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">owu.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  

                  <!-- Pennsylvania, University of, Walt Whitman Collection -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/upa.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">upa.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- The Pierpont Morgan Library, New York -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/pml.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">pml.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Princeton University -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/pru.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">pru.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- University of Rhode Island -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/uri.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">uri.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Rosenbach Museum and Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/rml.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">rml.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Rutgers University -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/rut.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">rut.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Salisbury House -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/sal.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">sal.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Temple University -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/tem.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">tem.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- University of North Carolina at Chapel Hill -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/unc.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">unc.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- University of South Carolina -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/usc.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">usc.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- University of Texas (HRC) -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/tex.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">tex.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- University of Tulsa -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/tul.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">tul.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- University of Virginia -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/uva.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">uva.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Walt Whitman House in Camden -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/wwh.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">wwh.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Washington University, George N. Meissner Collection -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/wau.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">wau.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>

                  <!-- Yale Collection of American Literature, Beinecke Rare Book and Manuscript Library -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/yal.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">yal.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Unlocated manuscripts -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/med.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">med.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Private Collection of Kendall Reed -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/prc.ead01.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">prc.ead01.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
                  
                  <!-- Private Collection of Ed Folsom -->
                  <xsl:for-each
                     select="document('../../manuscripts/ead/prc.ead02.xml')//did/parent::*[@level='item']">
                     <xsl:element name="c01">
                        <xsl:attribute name="level">item</xsl:attribute>
                        <xsl:copy-of select="./did"/>
                        <xsl:copy-of select="./scopecontent"/>
                        <xsl:element name="extptr">
                           <xsl:attribute name="href">prc.ead02.xml</xsl:attribute><xsl:attribute name="type">repositoryID</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>


               </dsc>
            </archdesc>
         </ead>

      </xsl:document>

   </xsl:template>


</xsl:stylesheet>

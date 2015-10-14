<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xpath-default-namespace="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output indent="yes"/>
    
    
    
    <!-- Fields -->
    
    <!-- 
   id
   creator
   creator_sort
   date
   date_sort
   type
   subtype
   title
   repository
   place
   text
   text_type
	-->
    
    <xsl:template match="/">
        <add>
            <doc>
                
                <field name="text_type">
                    <xsl:value-of select="/TEI/text/@type"/>
                </field>
                
                
                
                <field name="id">
                    <!-- Get the filename -->
                    <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
                    
                    <!-- Split the filename using '\.' -->
                    <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
                    
                    <!-- Remove the file extension -->
                    <xsl:value-of select="$filenamepart"/>
                </field>
                
                <!-- image_id. Note used in marginalia yet. This field is only generated if there are page breaks withi @facs, and the only value pulled is for the first pb w/ @facs. -->
               <!-- <xsl:for-each select="//pb[@facs]">
                    <xsl:variable name="facs_count">
                        <xsl:number count="//pb[@facs]" level="any"/>
                    </xsl:variable>
                    <xsl:if test="number($facs_count = 1)">
                        <field name="image_id">
                            <xsl:value-of select="@facs"/>
                        </field>
                    </xsl:if>
                </xsl:for-each>-->
                
                <!-- path: path where the TEI file is on the server. -->
                <field name="path">
                    <xsl:text>/data/public/whitmanarchive/manuscripts/marginalia/tei/</xsl:text>
                </field>
                
                
                <!-- image_path: thumbnail image of the first pb @facs is on the server. -->
                <!--<field name="image_path">
                    <xsl:text>/data/public/whitmanarchive/biography/correspondence/thumbnails</xsl:text>
                </field>-->
                
                
                <field name="type">
                    <xsl:text>manuscripts</xsl:text>
                </field>
                
                <field name="subtype">
                    <xsl:text>annotations_and_marginalia</xsl:text>
                </field>
                
                
                <!-- ==================== -->
                
                <field name="title">
                    <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@level='m' and @type='main']"></xsl:value-of>
                </field>
                
                <!-- Date -->
                    <xsl:choose>
                        <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@notBefore">
                            <field name="date">
                                <xsl:call-template name="extractDate">
                                    <xsl:with-param name="date"><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notBefore"/></xsl:with-param>
                                </xsl:call-template>
                                <!--<xsl:text> - </xsl:text>
                                <xsl:call-template name="extractDate">
                                    <xsl:with-param name="date"><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notAfter"/></xsl:with-param>
                                </xsl:call-template>-->
                                </field>
                        </xsl:when>
                        <xsl:otherwise>
                            <field name="date">
                                <xsl:choose>
                                    <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@when">
                                        <xsl:call-template name="extractDate">
                                            <xsl:with-param name="date"><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date[1]/@when"/></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="not(/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@when)">NO DATE</xsl:when>
                                    <xsl:otherwise>NOT REGULARIZED</xsl:otherwise>
                                </xsl:choose>
                            </field></xsl:otherwise>
                    </xsl:choose>
                
                
                <!-- date_sort-->
                <xsl:choose>
                    <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@notBefore">
                        <field name="date_sort"><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@notBefore"/><!--<xsl:text> - </xsl:text><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notAfter"/>--></field>
                    </xsl:when>
                    <xsl:otherwise>
                        <field name="date_sort">
                            <xsl:choose>
                                <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@when">
                                    <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date[1]/@when"/>
                                </xsl:when>
                                <xsl:when test="not(/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date/@when)">NO DATE</xsl:when>
                                <xsl:otherwise>NOT REGULARIZED</xsl:otherwise>
                            </xsl:choose>
                        </field></xsl:otherwise>
                </xsl:choose>
                
               
                

                <xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author">
                    <xsl:if test=". != ''">
                        <field name="creator">
                            <xsl:value-of select="."/>
                        </field>
                    </xsl:if>
                </xsl:for-each>

                <field name="creator_sort">
                    <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author"/>
                </field>

 
  
                <field name="repository">
                    <xsl:value-of select="TEI/teiHeader/fileDesc/sourceDesc/bibl/orgName"></xsl:value-of>
                </field>
                
                <field name="marginalia_place">
                    <xsl:variable name="filename_prefix" select="substring(/TEI/@xml:id, 1, 3)"/>
                    <xsl:if test="$filename_prefix='loc'"><xsl:text>Library of Congress</xsl:text></xsl:if>
                    <xsl:if test="$filename_prefix='duk'"><xsl:text>Duke University</xsl:text></xsl:if>
                    <xsl:if test="$filename_prefix='nyp'"><xsl:text>New York Public Library</xsl:text></xsl:if>
                    <xsl:if test="$filename_prefix='mid'"><xsl:text>Middlebury College</xsl:text></xsl:if>
                    <xsl:if test="$filename_prefix='yal'"><xsl:text>Yale University</xsl:text></xsl:if>
                    <xsl:if test="$filename_prefix='bmr'"><xsl:text>Bryn Mawr College</xsl:text></xsl:if>
                    <xsl:if test="$filename_prefix='rut'"><xsl:text>Rutgers University</xsl:text></xsl:if>
                    <xsl:if test="$filename_prefix='owu'"><xsl:text>Ohio Wesleyan University</xsl:text></xsl:if>
                    <xsl:if test="$filename_prefix='tex'"><xsl:text>Harry Ransom Center</xsl:text></xsl:if> 
                </field>
                
                <field name="text">
<xsl:value-of select="TEI/teiHeader/fileDesc/sourceDesc/bibl/idno"></xsl:value-of><xsl:text>&#10;</xsl:text>
<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author"></xsl:value-of>, <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/title"></xsl:value-of>, <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/publisher"></xsl:value-of>, <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/pubPlace"></xsl:value-of>, <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when"></xsl:value-of>
                    <xsl:value-of select="//text"/>
                </field>
            </doc>
        </add>
        
    </xsl:template>	
    
    <!-- ================ -->
    
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

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace=""
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    
    
    
    <xsl:param name="date"/>
    <xsl:param name="string"/>
    <xsl:param name="site_location">http://rosie.unl.edu/transmississippi/</xsl:param>
    <xsl:param name="file_location">http://rosie.unl.edu/data/projects/</xsl:param>
    
    <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
    <!-- The part of the url after the main document structure and before the filename. 
			Collected so we can link to files, even if they are nested, i.e. whitmanarchive/manuscripts -->
    <xsl:variable name="slug" select="substring-before(substring-before(substring-after(base-uri(.),'data/projects/'),$filename),'/')"/>
    
    <!-- Split the filename using '\.' -->
    <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
    
    <!-- I used this online converter with the default options to get the XML.
    http://www.convertcsv.com/csv-to-xml.htm
    I had to edit the spreadsheet to remove "/"'s first.
    -->
    
    <!-- ==============================
	resource identification 
	===================================-->
    
    <!-- id -->
    <!-- slug -->
    <!-- project -->
    <!-- uri -->
    <!-- uriXML -->
    <!-- uriHTML -->
    <!-- dataType -->
    
    
    <!-- ==============================
	Dublin Core 
	===================================-->
    
    <!-- title -->
    <!-- titleSort -->
    <!-- creator -->
    <!-- creators -->
    <!-- subject -->
    <!-- subjects -->
    <!-- description -->
    <!-- publisher -->
    <!-- contributor -->
    <!-- contributors -->
    <!-- date -->
    <!-- dateDisplay -->
    <!-- type -->
    <!-- format -->
    <!-- language -->
    <!-- relation -->
    <!-- coverage -->
    <!-- source -->
    <!-- rightsHolder -->
    <!-- rights -->
    <!-- rightsURI -->
    
    
    <!-- ==============================
	Other elements 
	===================================-->
    
    <!-- principalInvestigator -->
    <!-- principalInvestigators -->
    <!-- place -->
    <!-- placeName -->
    
    <!-- ==============================
	CDRH specific 
	===================================-->
    
    <!-- category -->
    <!-- subCategory -->
    <!-- topic -->
    <!-- keywords -->
    <!-- people -->
    <!-- places -->
    <!-- works -->

    <xsl:template match="/">

        <add>

            <xsl:for-each select="/ROWSET/ROW">
                
                <xsl:if test="id != ''">
                <doc>
                    
                    <!-- ==============================
	               Project specific dynamic fields 
	               ===================================-->
                    
                    <xsl:if test="pages != ''">
                        <field name="pages_i">
                            <xsl:value-of select="pages"/>
                        </field>
                    </xsl:if>
                    
                    <xsl:if test="collection != ''">
                        <field name="collection_s">
                            <xsl:value-of select="collection"/>
                        </field>
                    </xsl:if>
                    
                    <!-- ==============================
	               resource identification 
	               ===================================-->
                    
                    <!-- id -->
                    
                    <field name="id">
                        <xsl:value-of select="id"/>
                    </field>
                    
                    <!-- slug -->
                    
                    <field name="slug"><xsl:value-of select="$slug"/></field>
                    
                    <!-- project -->
                    
                    <field name="project"><xsl:text>Trans-Mississippi and International Exposition</xsl:text></field>
                    
                    <!-- uri-->
                    <field name="uri">http://trans-mississippi.unl.edu/files/<xsl:value-of select="id"/>.html</field>
                    
                    <!-- uriXML -->
                    
                    <!--<field name="uriXML">
                        <xsl:value-of select="$file_location"/>
                        <xsl:value-of select="$slug"/>
                        <xsl:text>/tei/</xsl:text>
                        <xsl:value-of select="$filenamepart"/>
                        <xsl:text>.xml</xsl:text>
                    </field>-->
                    
                    <!-- uriHTML -->
                    
                    <field name="uriHTML">
                        <xsl:value-of select="$file_location"/>
                        <xsl:value-of select="$slug"/>
                        <xsl:text>/html/</xsl:text>
                        <xsl:value-of select="$filenamepart"/>
                        <xsl:text>.xml.txt</xsl:text>
                    </field>
                    
                    <!-- dataType -->
                    
                    <field name="dataType">
                        <xsl:text>csv</xsl:text>
                    </field>
                    
                    
                    <!-- ==============================
	                Dublin Core 
                	===================================-->
                    
                    <!-- title -->
                    
                    <xsl:variable name="title">
                        <xsl:choose>
                            <xsl:when test="title != ''">
                                <xsl:value-of select="title"/>
                            </xsl:when>
                            <xsl:when test="subject_location != ''">
                                <xsl:value-of select="subject_location"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:text>No Title</xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <field name="title">
                        <xsl:value-of select="$title"/>
                    </field>
                    
                    <!-- titleSort -->
                    
                    <field name="titleSort">
                        <xsl:call-template name="normalize_name">
                            <xsl:with-param name="string">
                                <xsl:value-of select="$title"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </field>
                    
                    <!-- creator -->
                    
                    <field name="creator">
                        <xsl:value-of select="creator"/>
                    </field>
                    
                    <!-- creators -->
                    <!-- subject -->
                    
                    <!-- empty -->
                    <!--<field name="subject">
                        <xsl:value-of select="subject"/>
                    </field>-->
                    
                    <!-- subjects -->
                    <!-- description -->
                    
                    <field name="description">
                        <xsl:value-of select="description"/>
                    </field>
                    
                    <!-- publisher -->
                    <!-- contributor -->
                    
                    <!--<field name="contributor">
                        <xsl:value-of select="contributor"/>
                    </field>-->
                    
                    <!-- contributors -->
                    <!-- date -->
                    
                    <xsl:if test="date != ''">
                        <field name="date">
                            <xsl:value-of select="dateNormalized"/>
                            <xsl:text>T00:00:00Z</xsl:text>
                        </field>
                    </xsl:if>
                    
                    <!-- dateDisplay -->
                    
                    <xsl:if test="dateDisplay != ''">
                        <field name="dateDisplay">
                            <xsl:value-of select="date"/>
                         </field>
                    </xsl:if>
                    
                    <!-- type -->
                    <!-- format -->
                    
                   <!-- <field name="format">
                        <xsl:value-of select="medium"/>
                    
                    <xsl:text> - </xsl:text>
                   
                        <xsl:value-of select="extent_size"/>
                    </field>-->
                    
                    <!-- medium -->
                    
                    <field name="medium">
                        <xsl:value-of select="medium"/>
                    </field>
                    
                    <!-- extent -->
                    
                    <field name="extent">
                        <xsl:value-of select="size"/>
                    </field>
                    
                    <!-- language -->
                    
                    <!--<field name="language">
                        <xsl:value-of select="language"/>
                    </field>-->
                    
                    <!-- relation -->
                    
                    <field name="relation">
                        <xsl:value-of select="old_id"/>
                    </field>
                    
                    <!-- coverage -->
                    <!-- source -->
                    
                    <!--<field name="source">
                        <xsl:value-of select="source"/>
                    </field>-->
                    
                    <!-- rightsHolder -->
                    
                    <field name="rightsHolder">
                        <xsl:text>Omaha Public Library</xsl:text>
                    </field>
                    
                    <!-- rights -->
                    
                    <!--<field name="rights">
                        <xsl:value-of select="rights"/>
                    </field>-->
                    
                    <!-- rightsURI -->
                    
                    
                    <!-- ==============================
	                Other elements 
	                ===================================-->
                    
                    <!-- principalInvestigator -->
                    <!-- principalInvestigators -->
                    <!-- place -->
                    
                    <xsl:if test="latitude != '' and longitude != ''">
                    <field name="place">
                        <xsl:value-of select="latitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="longitude"/>
                    </field>
                    </xsl:if>
                    
                    <!-- placeName -->
                    
                    <field name="placeName">
                        <xsl:choose>
                            <xsl:when test="location != ''">
                                <xsl:value-of select="location"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:text>Unknown</xsl:text></xsl:otherwise>
                        </xsl:choose>
                        
                    </field>
                    
                    
                    <!-- ==============================
	                CDRH specific 
	                ===================================-->
                    
                    <!-- category -->
                    
                    <field name="category"><xsl:value-of select="category"/></field>
                    
                    <!-- subCategory -->
                    
                    <field name="subCategory"><xsl:value-of select="sub_category"/></field>
                    
                    <!-- topic -->
                    <!-- keywords -->
                    
                    <xsl:if test="keywords != ''">
                        <xsl:for-each select="tokenize(keywords, ',')">
                            <field name="keywords"><xsl:value-of select="normalize-space(.)"></xsl:value-of></field>
                        </xsl:for-each>                        
                    </xsl:if>
                    <!-- people -->
                    <!-- places -->
                    <!-- works -->
        
                    
                </doc>
                </xsl:if>

              


            </xsl:for-each>

        </add>
    </xsl:template>
    
    
    
    <!-- ========================================================
	Helper Templates
	==========================================================-->
    
    <xsl:template name="date_standardize">
        <xsl:param name="datebefore"/>
        <xsl:choose>
            <xsl:when test="count(tokenize($datebefore,'-')) = 1">
                <!-- Make sure it is the correct string length -->
                <xsl:if test="string-length($datebefore) = 4">
                    <xsl:value-of select="$datebefore"/>
                    <xsl:text>-01-01</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when test="count(tokenize($datebefore,'-')) = 2">
                <!-- Make sure it is the correct string length -->
                <xsl:if test="string-length($datebefore) = 7">
                    <xsl:value-of select="$datebefore"/>
                    <xsl:text>-01</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when test="count(tokenize($datebefore,'-')) = 3">
                <!-- Make sure it is the correct string length -->
                <xsl:if test="string-length($datebefore) = 10">
                    <xsl:value-of select="$datebefore"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise><!-- do nothing because date is not in proper format --></xsl:otherwise>
        </xsl:choose>
        
        
        
    </xsl:template>
    
    
    <xsl:template name="normalize_name">
        <xsl:param name="string"><xsl:value-of select="$string"/></xsl:param>
        
        <xsl:variable name="string_lower"><xsl:value-of select="normalize-space(translate(lower-case($string), '“‘&quot;', ''))"/></xsl:variable>
        
        <xsl:choose>
            <xsl:when test="starts-with($string_lower, 'a ')">
                <xsl:value-of select="substring-after($string_lower, 'a ')"></xsl:value-of>
            </xsl:when>
            <xsl:when test="starts-with($string_lower, 'the ')">
                <xsl:value-of select="substring-after($string_lower, 'the ')"></xsl:value-of>
            </xsl:when>
            <xsl:when test="starts-with($string_lower, 'an ')">
                <xsl:value-of select="substring-after($string_lower, 'an ')"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string_lower"></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
    
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

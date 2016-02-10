<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace=""
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xs" version="2.0">
    
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
        <xsl:param name="string"/>
        
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
            <!--<xsl:when test="not(contains('0123456789', substring($date,1,1)))"> Works, but dumb -->
            <xsl:when test="matches($date, '([A-Za-z])')"><!-- if date contains a letter, show as is. todo fix date handling -->
                
                <xsl:value-of select="$date"/>
            </xsl:when>
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

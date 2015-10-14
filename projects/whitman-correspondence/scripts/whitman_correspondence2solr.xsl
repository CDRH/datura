<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xpath-default-namespace="http://www.whitmanarchive.org/namespace"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output indent="yes"/>
    
    <!-- Created by Liz Lorang based on a model from
        Karin Dalziel on 2014-05-19. -->
    
    <!-- Last updated by Liz Lorang 2014-05-22 -->
    
    <!-- This stylesheet takes correspondence TEI files as input and populates an XML
        file for importing into Solr index. -->
    
    <!-- Fields:
        id
        image_id
        path
        image_path
        type
        subtype
        title
        date
        date_sort
        creator
        creator_sort
        *correspondence_recipient
        *corrsepondence_recipient_sort
        repository
        text
    -->
    
    <xsl:template match="/">        
        <add>
            <doc>
                
                <!-- First field is item ID (WWA ID) pulled from the filename, in case there are mistakes in declaring the ID in the file itself. -->
                <field name="id">
                    <!-- Get the filename -->
                    <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
                    
                    <!-- Split the filename using '\.' -->
                    <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
                    
                    <!-- Remove the file extension -->
                    <xsl:value-of select="$filenamepart"/>
                </field>
                
                
                <!-- Second field is an image id. This field is only generated if there are page breaks withi @facs, and the only value pulled is for the first pb w/ @facs. -->
                <xsl:for-each select="//pb[@facs]">
                    <xsl:variable name="facs_count">
                        <xsl:number count="//pb[@facs]" level="any"/>
                    </xsl:variable>
                    <xsl:if test="number($facs_count = 1)">
                        <field name="image_id">
                            <xsl:value-of select="@facs"/>
                        </field>
                    </xsl:if>
                </xsl:for-each>
                
                
                
                <!-- Third field is the path where the TEI file is on the server. -->
                <field name="path">
                    <xsl:text>/data/public/whitmanarchive/biography/correspondence/tei/</xsl:text>
                </field>
                
                
                <!-- Fourth field is where the thumbnail image of the first pb @facs is on the server. -->
                <field name="image_path">
                    <xsl:text>/data/public/whitmanarchive/biography/correspondence/thumbnails</xsl:text>
                </field>
                
                
                <!-- Fifth field is the item type, based on the main section where the item apears on the Whitman Archive. Should be represented in all lowercase letters with _ between words rather than spaces.-->
                <field name="type">
                    <xsl:text>life_and_letters</xsl:text>
                </field>
                
                
                <!-- Sixth field is the item subtype, based on the subsection section where the item apears on the Whitman Archive. Should be represented in all lowercase letters with _ between words rather than spaces.-->
                <field name="subtype">
                    <xsl:text>letters</xsl:text>
                </field>
                
                
                <!-- Seventh field is the item title, pulled from the source description. -->
                <field name="title">
                    <xsl:value-of select="//sourceDesc/bibl/title"/>
                </field>
                
                
                <!-- Eighth field is the item date in human-readable format, pulled from the date in source description. -->
                <field name="date">
                    <xsl:value-of select="//sourceDesc/bibl/date"/>
                </field>
                
                
                <!-- Ninth field is a sortable version of the date in the format yyyy-mm-dd pulled from @when or @notBefore on date element in the source description. -->
                <field name="date_sort">
                    <xsl:choose>
                        <xsl:when test="//sourceDesc/bibl/date/attribute::notBefore">
                            <xsl:value-of select="//sourceDesc/bibl/date/attribute::notBefore"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//sourceDesc/bibl/date/attribute::when"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </field>
                
                
                <!-- Tenth element (can be repeated) is the creator of the letter (the sender). The field "creator" will repeat for each sender identified for the letter, so long as the original encoding designates each sender separately. -->
                <xsl:for-each select="//profileDesc/particDesc/person[@role='sender']">
                    <field name="creator">
                        <xsl:value-of select="persName/attribute::key"/>
                    </field>
                </xsl:for-each>
                
                
                <!-- Eleventh element (cannot be repeated) is a sortable list of creators, based on the sender of the letter. If there is a single sender/creator, then just the one name value is given in the format last name, first name. If there are multiple senders/creators, then a list is generated in the format last name, first name; last name, first name, etc, so long as the original encoding designates each sender separately. Right now, accounts for up to three senders. This is not very elegant, but it works. -->
                <field name="creator_sort">
                    <xsl:if test="count(//person[@role='sender']) = 1"><xsl:value-of select="//person[@role='sender']/persName/attribute::key"/></xsl:if>
                    <xsl:if test="count(//person[@role='sender']) = 2">
                        <xsl:value-of select="//person[@role='sender'][1]/persName/attribute::key"/>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="//person[@role='sender'][2]/persName/attribute::key"/>
                    </xsl:if>
                    <xsl:if test="count(//person[@role='sender']) = 3">
                        <xsl:value-of select="//person[@role='sender'][1]/persName/attribute::key"/>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="//person[@role='sender'][2]/persName/attribute::key"/>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="//person[@role='sender'][3]/persName/attribute::key"/>
                    </xsl:if>
                </field>
                
                
                <!-- Twelfth element (can be repeated) is the recipient of the letter. The field "correspondence_recipient" will repeat for each recipient identified for the letter, so long as the original encoding designates each recipient separately. -->
                <xsl:for-each select="//profileDesc/particDesc/person[@role='recipient']">
                    <field name="correspondence_recipient">
                        <xsl:value-of select="persName/attribute::key"/>
                    </field>
                </xsl:for-each>
                
                
                <!-- Thirteenth element (cannot be repeated) is a sortable list of recipients. If there is a single recipient, then just the one name value is given in the format last name, first name. If there are multiple recipients, then a list is generated in the format last name, first name; last name, first name, etc., so long as the original encoding designates each recipient separately. Right now, accounts for up to three recipients. This is not very elegant, but it works. -->
                <field name="correspondence_recipient_sort">
                    <xsl:if test="count(//person[@role='recipient']) = 1"><xsl:value-of select="//person[@role='recipient']/persName/attribute::key"/></xsl:if>
                    <xsl:if test="count(//person[@role='recipient']) = 2">
                        <xsl:value-of select="//person[@role='recipient'][1]/persName/attribute::key"/>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="//person[@role='recipient'][2]/persName/attribute::key"/>
                    </xsl:if>
                    <xsl:if test="count(//person[@role='recipient']) = 3">
                        <xsl:value-of select="//person[@role='recipient'][1]/persName/attribute::key"/>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="//person[@role='recipient'][2]/persName/attribute::key"/>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="//person[@role='recipient'][3]/persName/attribute::key"/>
                    </xsl:if>
                    <xsl:if test="count(//person[@role='recipient']) &gt; 3">
                        <xsl:value-of select="//person[@role='recipient'][1]/persName/attribute::key"/>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="//person[@role='recipient'][2]/persName/attribute::key"/>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="//person[@role='recipient'][3]/persName/attribute::key"/>
                        <xsl:text> and others</xsl:text><!--
                        <xsl:value-of select="//person[@role='recipient'][4]/persName/attribute::key"/>-->
                    </xsl:if>
                    
                    
                </field>
                
                
                <!-- Fourteenth element is the repository that holds the original item, as declared in source description. -->
                <field name="repository">
                    <xsl:value-of select="//sourceDesc/bibl/orgName"/>
                </field>
                
                
                <!-- Fifrtheen element is the text element, which includes the text of the letter, all project notes from the TEI header, all editorial notes created for web display through a combination of mark-up and xslt, and all footnotes for the letter, which are stored in an an external file. -->
                <field name="text">
                    <!-- To duplicate 'Editorial notes' section of metadata box in web view -->
                    <!-- 1. Notes in others' hand on the document -->
                    <xsl:for-each select="//body//note[@type='editorial']">
                        <xsl:variable name="person_name"><xsl:value-of select="substring-after(@resp, '#')"/></xsl:variable>
                        <xsl:text>The annotation, "</xsl:text><xsl:value-of select="//body//note[@type='editorial']"/><xsl:text>," is in the hand of </xsl:text> <xsl:value-of select="//handNote[@xml:id=$person_name]/persName"/><xsl:text>. </xsl:text>
                    </xsl:for-each>
                    <!-- 2. Notes about the document, such as about other items on the same leaf. -->
                    <xsl:if test="//note[@type='project']"><xsl:value-of select="//note"/></xsl:if>
                    
                    
                    <!-- Everything from text element -->
                    <xsl:value-of select="//text"/>
                    
                    
                    <!-- Footnotes -->
                   <xsl:for-each select="//ptr">
                        <xsl:variable name="ptr_target">
                            <xsl:value-of select="@target"></xsl:value-of>
                        </xsl:variable>                            
                        
                       <xsl:value-of select="document('notes.xml')//body/descendant::note[@xml:id=$ptr_target]"/><xsl:text>&#13;</xsl:text>
                    </xsl:for-each>
                    
                    <xsl:for-each select="//profileDesc//persName[@ref]">
                        <xsl:variable name="ref_target">
                            <xsl:value-of select="@ref"/>
                        </xsl:variable>
                        <xsl:value-of select="document('notes.xml')//body/descendant::note[@xml:id=$ref_target]"/><xsl:text>&#13;</xsl:text>
                    </xsl:for-each>
                </field>
            </doc>
        </add>
        
    </xsl:template>	
    
</xsl:stylesheet>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    >
    <xsl:output indent="no" omit-xml-declaration="yes" media-type="application/javascript"/>
    
   
    
    <xsl:template match="/">
        
        
        
<xsl:text>callback({
    "type": "FeatureCollection",
    "features": [</xsl:text>
        
        <xsl:for-each select="/response/result/doc">        
<xsl:text>
            {
            "type": "Feature",
            "properties": </xsl:text>
            
            
<xsl:text>{
                "id": "</xsl:text>
                
            <xsl:value-of select="str[@name='id']"/>
                
<xsl:text>",</xsl:text>
            
            <xsl:text>
                "time": "</xsl:text>
            
            <xsl:value-of select="date[@name='date_dt']"/>
            
            <xsl:text>"</xsl:text>

            
            <xsl:text>},
            "geometry": {
                "type": "Point",
                "coordinates": [
                    
                    </xsl:text>
        
        
            <xsl:value-of select="substring-after(str[@name='latlong_p'],',')"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="substring-before(str[@name='latlong_p'],',')"/>
<xsl:text>                ]
            }
        }</xsl:text>
        
            <xsl:if test="position() != last()">,</xsl:if>
        
 <xsl:text>
                  
</xsl:text>       
        </xsl:for-each>
<xsl:text>       
    ]
})</xsl:text>
  
        
</xsl:template>
    
    
    
    
</xsl:stylesheet>

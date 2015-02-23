<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <!-- You'll need to edit this line to reflect your configuration -->
    <!-- 
        for example, you might change the contents of the xsl:variable tag to be:
          http://example.com/~user/project/quills/
    -->
    <xsl:variable name="dev_siteroot">http://spacely.unl.edu/cocoon/transmississippi/</xsl:variable>
    <xsl:variable name="dev_searchroot">http://cdrhsearch.unl.edu:8080/solr/api_transmississippi_test/select/?version=2.2&amp;indent=on</xsl:variable>
    <xsl:variable name="dev_externalfileroot">http://spacely.unl.edu/cocoon/transmississippi/files/</xsl:variable>
    
    
    
    <xsl:variable name="prod_siteroot">http://spacely.unl.edu/cocoon/transmississippi/</xsl:variable>
    <xsl:variable name="prod_searchroot">http://cdrhsearch.unl.edu:8080/solr/api_transmississippi/select/?version=2.2&amp;indent=on</xsl:variable>
    <xsl:variable name="prod_externalfileroot">http://spacely.unl.edu/cocoon/transmississippi/files/</xsl:variable>

</xsl:stylesheet>

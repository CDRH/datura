<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="#all">


  <xsl:template name="personography">
    <xsl:param name="filenamepart"/>
    <xsl:for-each select="//person">
      <doc>
        <!-- ==============================
        resource identification 
        ===================================-->

        <!-- id -->
        <xsl:call-template name="id">
          <xsl:with-param name="id" select="@xml:id"/>
        </xsl:call-template>

        <!-- slug -->
        <xsl:call-template name="slug"/>

        <!-- project -->
        <xsl:call-template name="project"/>

        <!-- uri -->
        <xsl:call-template name="uri">
          <xsl:with-param name="id" select="@xml:id"/>
        </xsl:call-template>

        <!-- uriXML -->
        <xsl:call-template name="uriXML">
          <xsl:with-param name="id" select="$filenamepart"/>
        </xsl:call-template>

        <!-- uriHTML -->
        <xsl:call-template name="uriHTML">
          <xsl:with-param name="id" select="@xml:id"/>
        </xsl:call-template>

        <!-- dataType -->
        <field name="dataType"><xsl:text>tei</xsl:text></field>

        <!-- image_id -->
        <xsl:call-template name="image_id"/>

        <!-- ==============================
        Dublin Core and CDRH Fields
        ===================================-->

        <!-- title -->
        <xsl:call-template name="perTitle"/>

        <!-- creator and creators -->
        <xsl:call-template name="perCreators"/>

        <!-- contributors -->
        <xsl:call-template name="contributors"/>

        <!-- keywords -->
        <xsl:call-template name="keywords"/>

        <!-- people -->
        <xsl:call-template name="perPeople"/>

        <!-- places -->
        <xsl:call-template name="places"/>

        <!-- description -->
        <field name="description">
          <!-- make the person searchable -->
          <xsl:value-of select="note"/>
        </field>

        <!-- format -->
        <!-- <xsl:call-template name="format"/> -->

        <!-- category -->
        <field name="category">Life</field>

        <!-- subCategory -->
        <field name="subCategory">Personography</field>

        <!-- topics -->
        <xsl:call-template name="topic"/>

      </doc>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="perPeople">
    <field name="people">
      <xsl:value-of select="./persName[@type='display']"/>
    </field>
  </xsl:template>

  <xsl:template name="perTitle">
    <field name="title">
      <xsl:value-of select="./persName[@type='display']"/>
    </field>
  </xsl:template>

  <xsl:template name="perCreators">
    <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/author[1]/text()">
      <xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author">
        <field name="creator">
          <xsl:value-of select="./text()"/>
        </field>
        <field name="creators">
          <xsl:value-of select="./text()"/>
        </field>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>



</xsl:stylesheet>



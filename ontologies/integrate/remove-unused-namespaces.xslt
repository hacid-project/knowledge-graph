<!--
  XSLT for removing unused namespaces from an XML file.

  Author: Dimitre Novatchev
  Source: https://stackoverflow.com/a/4594626
  License: CC BY-SA, https://creativecommons.org/licenses/by-sa/2.5/

  Usage:

      xmlstarlet tr remove-unused-namespaces.xslt -

  Processes stdin and writes the result to stdout.  
-->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:output omit-xml-declaration="yes" indent="yes"/>
 <!-- <xsl:strip-space elements="*"/> -->
 <xsl:preserve-space elements="*" />

 <xsl:template match="node()|@*" priority="-2">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
 </xsl:template>

 <xsl:template match="*">
  <xsl:element name="{name()}" namespace="{namespace-uri()}">
   <xsl:variable name="vtheElem" select="."/>

   <xsl:for-each select="namespace::*">
     <xsl:variable name="vPrefix" select="name()"/>

     <xsl:if test=
      "$vtheElem/descendant::*
              [(namespace-uri()=current()
             and 
              substring-before(name(),':') = $vPrefix)
             or
              @*[substring-before(name(),':') = $vPrefix]
              ]
      ">
      <xsl:copy-of select="."/>
     </xsl:if>
   </xsl:for-each>
   <xsl:apply-templates select="node()|@*"/>
  </xsl:element>
 </xsl:template>
</xsl:stylesheet>


<!DOCTYPE stylesheet [<!ENTITY nbsp "&#160;" >]>

<xsl:stylesheet version="1.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:items="http://www.koha-community.org/items"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="marc items">

<xsl:import href="UNIMARCslimUtils.xsl"/>
<xsl:output method = "html" indent="yes" omit-xml-declaration = "yes" encoding="UTF-8"/>
<xsl:template match="/">
 <xsl:apply-templates/>
</xsl:template>

<xsl:template match="marc:record">
 <xsl:variable name="Show856uAsImage" select="marc:sysprefs/marc:syspref[@name='Display856uAsImage']"/>
 <xsl:variable name="leader" select="marc:leader"/>
 <xsl:variable name="leader6" select="substring($leader,7,1)"/>
 <xsl:variable name="leader7" select="substring($leader,8,1)"/>
 <xsl:variable name="biblionumber" select="marc:datafield[@tag=090]/marc:subfield[@code='a']"/>


 <xsl:if test="marc:datafield[@tag=200]">
 <xsl:for-each select="marc:datafield[@tag=200]">
 <h1>
 <xsl:call-template name="addClassRtl" />
 <xsl:variable name="title" select="marc:subfield[@code='a']"/>
 <xsl:variable name="ntitle"
         select="translate($title, '&#x0098;&#x009C;&#xC29C;&#xC29B;&#xC298;&#xC288;&#xC289;','')"/>
 <xsl:value-of select="$ntitle" />
 <xsl:if test="marc:subfield[@code='e']">
 <xsl:text> : </xsl:text>
 <xsl:for-each select="marc:subfield[@code='e']">
 <xsl:value-of select="."/>
 </xsl:for-each>
 </xsl:if>
 <xsl:if test="marc:subfield[@code='b']">
 <xsl:text> [</xsl:text>
 <xsl:value-of select="marc:subfield[@code='b']"/>
 <xsl:text>]</xsl:text>
 </xsl:if>
 <xsl:if test="marc:subfield[@code='f']">
 <xsl:text> / </xsl:text>
 <xsl:value-of select="marc:subfield[@code='f']"/>
 </xsl:if>
 <xsl:if test="marc:subfield[@code='g']">
 <xsl:text> ; </xsl:text>
 <xsl:value-of select="marc:subfield[@code='g']"/>
 </xsl:if>
 </h1>
 </xsl:for-each>
 </xsl:if>
 <xsl:call-template name="tag_4xx" />

 <xsl:call-template name="tag_7xx">
 <xsl:with-param name="tag">700</xsl:with-param>
 <xsl:with-param name="label">Autor principal</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_7xx">
 <xsl:with-param name="tag">710</xsl:with-param>
 <xsl:with-param name="label">Autor institucional (Principal)</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_7xx">
 <xsl:with-param name="tag">701</xsl:with-param>
 <xsl:with-param name="label">Coautor</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_7xx">
 <xsl:with-param name="tag">702</xsl:with-param>
 <xsl:with-param name="label">Autor secundario</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_7xx">
 <xsl:with-param name="tag">711</xsl:with-param>
 <xsl:with-param name="label">Autor institucional (Coautor)</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_7xx">
 <xsl:with-param name="tag">712</xsl:with-param>
 <xsl:with-param name="label">Autor institucional (Secundario)</xsl:with-param>
 </xsl:call-template>

 <xsl:if test="marc:datafield[@tag=101]">
 <li>
 <strong>Idioma: </strong>
 <xsl:for-each select="marc:datafield[@tag=101]">
 <xsl:for-each select="marc:subfield">
 <xsl:choose>
 <xsl:when test="@code='b'">de texto intermedio,</xsl:when>
 <xsl:when test="@code='c'">de trabajo original,</xsl:when>
 <xsl:when test="@code='d'">de resumen, </xsl:when>
 <xsl:when test="@code='e'">de página de contenidos, </xsl:when>
 <xsl:when test="@code='f'">de página principal</xsl:when>
 <xsl:when test="@code='g'">de siguiente título,</xsl:when>
 <xsl:when test="@code='h'">de libreto, </xsl:when>
 <xsl:when test="@code='i'">de material adjunto,</xsl:when>
 <xsl:when test="@code='j'">de subtítulos</xsl:when>n> </xsl:choose>
 <xsl:value-of select="text()"/>
 <xsl:choose>
 <xsl:when test="position()=last()">
 <xsl:text>.</xsl:text>
 </xsl:when>
 <xsl:otherwise>
 <xsl:text> ; </xsl:text>
 </xsl:otherwise>
 </xsl:choose>
 </xsl:for-each>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=102]">
 <li>
 <strong>País: </strong>
 <xsl:for-each select="marc:datafield[@tag=102]">
 <xsl:for-each select="marc:subfield">
 <xsl:value-of select="text()"/>
 <xsl:choose>
 <xsl:when test="position()=last()">
 <xsl:text>.</xsl:text>
 </xsl:when>
 <xsl:otherwise><xsl:text>, </xsl:text>
 </xsl:otherwise>
 </xsl:choose>
 </xsl:for-each>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:call-template name="tag_210" />

 <xsl:call-template name="tag_215" />

<xsl:if test="marc:controlfield[@tag=009]">
 <li><strong>Campo 009: </strong>
 <xsl:value-of select="marc:controlfield[@tag=009]"/>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=010]/marc:subfield[@code='a']">
 <li><strong>ISBN: </strong>
 <xsl:for-each select="marc:datafield[@tag=010]">
 <xsl:variable name="isbn" select="marc:subfield[@code='a']"/>
 <xsl:value-of select="marc:subfield[@code='a']"/>
 <xsl:choose>
 <xsl:when test="position()=last()">
 <xsl:text>.</xsl:text>
 </xsl:when>
 <xsl:otherwise>
 <xsl:text> ; </xsl:text>
 </xsl:otherwise>
 </xsl:choose>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=011]">
 <li>
 <strong>ISSN: </strong>
 <xsl:for-each select="marc:datafield[@tag=011]">
 <xsl:value-of select="marc:subfield[@code='a']"/>
 <xsl:choose>
 <xsl:when test="position()=last()">
 <xsl:text>.</xsl:text>
 </xsl:when>
 <xsl:otherwise>
 <xsl:text>; </xsl:text>
 </xsl:otherwise>
 </xsl:choose>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:call-template name="tag_title">
 <xsl:with-param name="tag">225</xsl:with-param>
 <xsl:with-param name="label">Series</xsl:with-param>
 </xsl:call-template>

 <xsl:if test="marc:datafield[@tag=676]">
 <li>
 <strong>Dewey: </strong>
 <xsl:for-each select="marc:datafield[@tag=676]">
 <xsl:value-of select="marc:subfield[@code='a']"/>
 <xsl:if test="marc:subfield[@code='v']">
 <xsl:text>, </xsl:text>
 <xsl:value-of select="marc:subfield[@code='v']"/>
 </xsl:if>
 <xsl:if test="marc:subfield[@code='z']">
 <xsl:text>, </xsl:text>
 <xsl:value-of select="marc:subfield[@code='z']"/>
 </xsl:if>
 <xsl:if test="not (position()=last())">
 <xsl:text> ; </xsl:text>
 </xsl:if>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=686]">
 <li>
 <strong>Clasificación: </strong>
 <xsl:for-each select="marc:datafield[@tag=686]">
 <xsl:value-of select="marc:subfield[@code='a']"/>
 <xsl:if test="marc:subfield[@code='b']">
 <xsl:text>, </xsl:text>
 <xsl:value-of select="marc:subfield[@code='b']"/>
 </xsl:if>
 <xsl:if test="marc:subfield[@code='c']">
 <xsl:text>, </xsl:text>
 <xsl:value-of select="marc:subfield[@code='c']"/>
 </xsl:if>
 <xsl:if test="not (position()=last())"><xsl:text> ; </xsl:text></xsl:if>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=327]">
 <li>
 <strong>Nota de contenidos: </strong>
 <xsl:for-each select="marc:datafield[@tag=327]">
 <xsl:call-template name="chopPunctuation">
 <xsl:with-param name="chopString">
 <xsl:call-template name="subfieldSelect">
 <xsl:with-param name="codes">abcdjpvxyz</xsl:with-param>
 <xsl:with-param name="subdivCodes">jpxyz</xsl:with-param>
 <xsl:with-param name="subdivDelimiter">-- </xsl:with-param>
 </xsl:call-template>
 </xsl:with-param>
 </xsl:call-template>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=330]">
 <li>
 <strong>Resumen: </strong>
 <xsl:for-each select="marc:datafield[@tag=330]">
 <xsl:value-of select="marc:subfield[@code='a']"/>
 <xsl:choose>
 <xsl:when test="position()=last()">
 <xsl:text>.</xsl:text>
 </xsl:when>
 <xsl:otherwise>
 <xsl:text>; </xsl:text>
 </xsl:otherwise>
 </xsl:choose>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=317]">
 <li>
 <strong>Nota de procedencia: </strong>
 <xsl:for-each select="marc:datafield[@tag=317]">
 <xsl:value-of select="marc:subfield[@code='a']"/>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=320]">
 <li>
 <strong>Bibliografía: </strong>
 <xsl:for-each select="marc:datafield[@tag=320]">
 <xsl:value-of select="marc:subfield[@code='a']"/>
 <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=328]">
 <li>
 <strong>Tesis: </strong>
 <xsl:for-each select="marc:datafield[@tag=328]">
 <xsl:value-of select="marc:subfield[@code='a']"/>
 <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=333]">
 <li>
 <strong>Audiencia: </strong>
 <xsl:for-each select="marc:datafield[@tag=333]">
 <xsl:value-of select="marc:subfield[@code='a']"/>
 <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:if test="marc:datafield[@tag=955]">
 <li>
 <strong>Historial SUDOC de publicación periódica: </strong>
 <xsl:for-each select="marc:datafield[@tag=955]">
 <xsl:value-of select="marc:subfield[@code='9']"/>: <xsl:value-of select="marc:subfield[@code='r']"/>
 <xsl:choose><xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when><xsl:otherwise><xsl:text>; </xsl:text></xsl:otherwise></xsl:choose>
 </xsl:for-each>
 </li>
 </xsl:if>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">600</xsl:with-param>
 <xsl:with-param name="label">Tema - Nombre personal</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">601</xsl:with-param>
 <xsl:with-param name="label">Tema - Autor institucional</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">602</xsl:with-param>
 <xsl:with-param name="label">Tema - Familia</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">604</xsl:with-param>
 <xsl:with-param name="label">Tema - Autor/título</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">606</xsl:with-param>
 <xsl:with-param name="label">Tema - Nombre de tópico</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">607</xsl:with-param>
 <xsl:with-param name="label">Tema - Nombre geográfico</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">608</xsl:with-param>
 <xsl:with-param name="label">Tema - Forma</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">610</xsl:with-param>
 <xsl:with-param name="label">Tema</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">615</xsl:with-param>
 <xsl:with-param name="label">Categoría de temas</xsl:with-param>
 </xsl:call-template>

 <xsl:call-template name="tag_subject">
 <xsl:with-param name="tag">616</xsl:with-param>
 <xsl:with-param name="label">Marca comercial</xsl:with-param>
 </xsl:call-template>

 <xsl:if test="marc:datafield[@tag=856]">
 <li>
 <strong>Recursos en línea: </strong>
 <xsl:for-each select="marc:datafield[@tag=856]">
 <xsl:variable name="SubqText"><xsl:value-of select="marc:subfield[@code='q']"/></xsl:variable>
 <a>
 <xsl:attribute name="href">
 <xsl:value-of select="marc:subfield[@code='u']"/>
 </xsl:attribute>
 <xsl:choose>
 <xsl:when test="($Show856uAsImage='Details' or $Show856uAsImage='Both') and (substring($SubqText,1,6)='image/' or $SubqText='img' or $SubqText='bmp' or $SubqText='cod' or $SubqText='gif' or $SubqText='ief' or $SubqText='jpe' or $SubqText='jpeg' or $SubqText='jpg' or $SubqText='jfif' or $SubqText='png' or $SubqText='svg' or $SubqText='tif' or $SubqText='tiff' or $SubqText='ras' or $SubqText='cmx' or $SubqText='ico' or $SubqText='pnm' or $SubqText='pbm' or $SubqText='pgm' or $SubqText='ppm' or $SubqText='rgb' or $SubqText='xbm' or $SubqText='xpm' or $SubqText='xwd')">
 <xsl:element name="img"><xsl:attribute name="src"><xsl:value-of select="marc:subfield[@code='u']"/></xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="marc:subfield[@code='y']"/></xsl:attribute><xsl:attribute name="height">100</xsl:attribute></xsl:element><xsl:text></xsl:text>
 </xsl:when>
 <xsl:when test="marc:subfield[@code='y' or @code='3' or @code='z']">
 <xsl:call-template name="subfieldSelect">
 <xsl:with-param name="codes">y3z</xsl:with-param>
 </xsl:call-template>
 </xsl:when>
 <xsl:when test="not(marc:subfield[@code='y']) and not(marc:subfield[@code='3']) and not(marc:subfield[@code='z'])">
 Haga clic aquí para acceso en línea </xsl:when>
 </xsl:choose>
 </a>
 <xsl:choose>
 <xsl:when test="position()=last()"></xsl:when>
 <xsl:otherwise> | </xsl:otherwise>
 </xsl:choose>
 </xsl:for-each>
 </li>
 </xsl:if>

 <!-- 780 -->
 <xsl:if test="marc:datafield[@tag=780]">
 <xsl:for-each select="marc:datafield[@tag=780]">
 <li>
 <xsl:choose>
 <xsl:when test="@ind2=0">
 <strong>Continúa:</strong>
 </xsl:when>
 <xsl:when test="@ind2=1">
 <strong>Continuado en parte:</strong>
 </xsl:when>
 <xsl:when test="@ind2=2">
 <strong>Reemplaza:</strong>
 </xsl:when>
 <xsl:when test="@ind2=3">
 <strong>Reemplaza en parte:</strong>
 </xsl:when>
 <xsl:when test="@ind2=4">
 <strong>Formado por la unión: ... y: ...</strong>
 </xsl:when>
 <xsl:when test="@ind2=5">
 <strong>Absorbido:</strong>
 </xsl:when>
 <xsl:when test="@ind2=6">
 <strong>Absorbido en parte:</strong>
 </xsl:when>
 <xsl:when test="@ind2=7">
 <strong>Separado desde:</strong>
 </xsl:when>
 </xsl:choose>

 <xsl:variable name="f780">
 <xsl:call-template name="subfieldSelect">
 <xsl:with-param name="codes">a_t</xsl:with-param>
 </xsl:call-template>
 </xsl:variable>
 <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=<xsl:value-of select="translate($f780, '()', '')"/></xsl:attribute>
 <xsl:value-of select="translate($f780, '()', '')"/>
 </a>
 </li>

 <xsl:choose>
 <xsl:when test="@ind1=0">
 <li><xsl:value-of select="marc:subfield[@code='n']"/></li>
 </xsl:when>
 </xsl:choose>

 </xsl:for-each>
 </xsl:if>

 <!-- 785 -->
 <xsl:if test="marc:datafield[@tag=785]">
 <xsl:for-each select="marc:datafield[@tag=785]">
 <li>
 <xsl:choose>
 <xsl:when test="@ind2=0">
 <strong>Continuado por:</strong>
 </xsl:when>
 <xsl:when test="@ind2=1">
 <strong>Continúa en parte por:</strong>
 </xsl:when>
 <xsl:when test="@ind2=2">
 <strong>Reemplazado por:</strong>
 </xsl:when>
 <xsl:when test="@ind2=3">
 <strong>Reemplazado en parte por:</strong>
 </xsl:when>
 <xsl:when test="@ind2=4">
 <strong>Absorbido por:</strong>
 </xsl:when>
 <xsl:when test="@ind2=5">
 <strong>Absorbida en parte por:</strong>
 </xsl:when>
 <xsl:when test="@ind2=6">
 <strong>Dividido en .. y ...:</strong>
 </xsl:when>
 <xsl:when test="@ind2=7">
 <strong>Combinar con ... para formar ...</strong>
 </xsl:when>
 <xsl:when test="@ind2=8">
 <strong>Cambiado de nuevo a:</strong>
 </xsl:when>
 </xsl:choose>
 <xsl:variable name="f785">
 <xsl:call-template name="subfieldSelect">
 <xsl:with-param name="codes">a_t</xsl:with-param>
 </xsl:call-template>
 </xsl:variable>

 <a><xsl:attribute name="href">/cgi-bin/koha/catalogue/search.pl?q=<xsl:value-of select="translate($f785, '()', '')"/></xsl:attribute>
 <xsl:value-of select="translate($f785, '()', '')"/>
 </a>

 </li>
 </xsl:for-each>
 </xsl:if>

 </xsl:template>

 <xsl:template name="nameABCDQ">
 <xsl:call-template name="chopPunctuation">
 <xsl:with-param name="chopString">
 <xsl:call-template name="subfieldSelect">
 <xsl:with-param name="codes">aq</xsl:with-param>
 </xsl:call-template>
 </xsl:with-param>
 <xsl:with-param name="punctuation">
 <xsl:text>:,;/ </xsl:text>
 </xsl:with-param>
 </xsl:call-template>
 <xsl:call-template name="termsOfAddress"/>
 </xsl:template>

 <xsl:template name="nameABCDN">
 <xsl:for-each select="marc:subfield[@code='a']">
 <xsl:call-template name="chopPunctuation">
 <xsl:with-param name="chopString" select="."/>
 </xsl:call-template>
 </xsl:for-each>
 <xsl:for-each select="marc:subfield[@code='b']">
 <xsl:value-of select="."/>
 </xsl:for-each>
 <xsl:if test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='n']">
 <xsl:call-template name="subfieldSelect">
 <xsl:with-param name="codes">cdn</xsl:with-param>
 </xsl:call-template>
 </xsl:if>
 </xsl:template>

 <xsl:template name="nameACDEQ">
 <xsl:call-template name="subfieldSelect">
 <xsl:with-param name="codes">acdeq</xsl:with-param>
 </xsl:call-template>
 </xsl:template>
 <xsl:template name="termsOfAddress">
 <xsl:if test="marc:subfield[@code='b' or @code='c']">
 <xsl:call-template name="chopPunctuation">
 <xsl:with-param name="chopString">
 <xsl:call-template name="subfieldSelect">
 <xsl:with-param name="codes">bc</xsl:with-param>
 </xsl:call-template>
 </xsl:with-param>
 </xsl:call-template>
 </xsl:if>
 </xsl:template>

 <xsl:template name="part">
 <xsl:variable name="partNumber">
 <xsl:call-template name="specialSubfieldSelect">
 <xsl:with-param name="axis">n</xsl:with-param>
 <xsl:with-param name="anyCodes">n</xsl:with-param>
 <xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
 </xsl:call-template>
 </xsl:variable>
 <xsl:variable name="partName">
 <xsl:call-template name="specialSubfieldSelect">
 <xsl:with-param name="axis">p</xsl:with-param>
 <xsl:with-param name="anyCodes">p</xsl:with-param>
 <xsl:with-param name="afterCodes">fghkdlmor</xsl:with-param>
 </xsl:call-template>
 </xsl:variable>
 <xsl:if test="string-length(normalize-space($partNumber))">
 <xsl:call-template name="chopPunctuation">
 <xsl:with-param name="chopString" select="$partNumber"/>
 </xsl:call-template>
 </xsl:if>
 <xsl:if test="string-length(normalize-space($partName))">
 <xsl:call-template name="chopPunctuation">
 <xsl:with-param name="chopString" select="$partName"/>
 </xsl:call-template>
 </xsl:if>
 </xsl:template>

 <xsl:template name="specialSubfieldSelect">
 <xsl:param name="anyCodes"/>
 <xsl:param name="axis"/>
 <xsl:param name="beforeCodes"/>
 <xsl:param name="afterCodes"/>
 <xsl:variable name="str">
 <xsl:for-each select="marc:subfield">
 <xsl:if test="contains($anyCodes, @code)      or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis])      or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
 <xsl:value-of select="text()"/>
 <xsl:text> </xsl:text>
 </xsl:if>
 </xsl:for-each>
 </xsl:variable>
 <xsl:value-of select="substring($str,1,string-length($str)-1)"/>
 </xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8" ?>
<!--
	In every selected Link Set, keep only the first N Links and move
	the rest to a Truncated element.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="link-set-name" />
	<xsl:param name="keep-first" />

	<xsl:variable name="folders" select="/kml:kml/kml:Document/kml:Folder" />
	<xsl:variable name="link-sets" select="$folders/kml:Placemark/kmlpipe:LinkSet[@name = $link-set-name]" />

	<xsl:template match="/">
		<xsl:if test="not($link-set-name)">
			<xsl:message terminate="yes">ERROR: link-set-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not($keep-first)">
			<xsl:message terminate="yes">ERROR: keep-first parameter must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($folders)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML, or contains no folders</xsl:message>
		</xsl:if>

		<xsl:if test="not($link-sets)">
			<xsl:message terminate="yes">ERROR: input does not contain any Link Set named "<xsl:value-of select="$link-set-name" />"</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet/kmlpipe:Link">
		<xsl:choose>
			<xsl:when test="../@name = $link-set-name and count(preceding-sibling::kmlpipe:Link) &gt;= $keep-first">
				<kmlpipe:Truncated>
					<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
				</kmlpipe:Truncated>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

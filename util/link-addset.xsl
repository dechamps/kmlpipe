<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Add an empty link set to every place in the input.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="link-set-name" />

	<xsl:template match="/">
		<xsl:if test="not($link-set-name)">
			<xsl:message terminate="yes">ERROR: link-set-name parameter must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:LinkSet>
				<xsl:attribute name="name"><xsl:value-of select="$link-set-name" /></xsl:attribute>
			</kmlpipe:LinkSet>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

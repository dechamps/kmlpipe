<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Renames a folder in a KML document.

	Currently, only supports KML files that only contain a single folder.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="new-folder-name" />

	<xsl:template match="/">
		<xsl:if test="not($new-folder-name)">
			<xsl:message terminate="yes">ERROR: new-folder-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>
		<xsl:variable name="folder-count" select="count(/kml:kml/kml:Document/kml:Folder)" />
		<xsl:if test="$folder-count != 1">
			<xsl:message terminate="yes">ERROR: input contains <xsl:value-of select="$folder-count" /> folders, expected 1</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder">
		<xsl:copy>
			<xsl:apply-templates select="@*" />

			<kml:name><xsl:value-of select="$new-folder-name" /></kml:name>
			<kmlpipe:Renamed>
				<xsl:attribute name="from"><xsl:value-of select="kml:name" /></xsl:attribute>
			</kmlpipe:Renamed>

			<xsl:apply-templates select="node()[count(.|../kml:name) != 1]" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

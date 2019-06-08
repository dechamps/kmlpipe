<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Removes the specified Folder.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="folder-name" />

	<!-- Completely remove folder instead of shelving it into a separate Element. -->
	<xsl:param name="obliterate" />

	<xsl:template match="/">
		<xsl:if test="not($folder-name)">
			<xsl:message terminate="yes">ERROR: folder-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder[kml:name=$folder-name])">
			<xsl:message terminate="yes">ERROR: input does not contain a <xsl:value-of select="$folder-name" /> folder</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
		<kmlpipe:RemovedFolder>
			<xsl:attribute name="name"><xsl:value-of select="$folder-name" /></xsl:attribute>
		</kmlpipe:RemovedFolder>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder">
		<xsl:choose>
			<xsl:when test="kml:name != $folder-name">
				<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not($obliterate)">
					<kmlpipe:RemovedFolder>
						<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
					</kmlpipe:RemovedFolder>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
	</xsl:template>
</xsl:stylesheet>

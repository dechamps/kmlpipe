<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Removes Hyperoptic sites depending on their status.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="drop-taking-orders" select="false" />
	<xsl:param name="drop-registering-interest" select="false" />
	<xsl:param name="drop-installation-agreed" select="false" />
	<xsl:param name="drop-going-live" select="false" />

	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:variable name="status-id" select="kmlpipe:Hyperoptic/@status-id" />
		<xsl:choose>
			<xsl:when test="($status-id = 0 and $drop-taking-orders) or ($status-id = 1 and $drop-registering-interest) or ($status-id = 2 and $drop-installation-agreed) or ($status-id = 3 and $drop-going-live)">
				<kmlpipe:HyperopticFilteredStatus>
					<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
				</kmlpipe:HyperopticFilteredStatus>
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

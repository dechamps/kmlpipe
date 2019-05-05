<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Tallies up partial scores, producing a total per property.

	Note: the reason why this is not done in compute-partial-scores.xsl directly is because of limitations of XSLT 1.0, which doesn't allow *resulting* nodes to be used as input to functions.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:ComputedTotalScores />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<kmlpipe:TotalScore>
				<xsl:attribute name="value"><xsl:value-of select="sum(kmlpipe:PartialScore/@value)" /></xsl:attribute>
			</kmlpipe:TotalScore>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

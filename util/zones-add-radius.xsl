<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Add the specified value to the radius of all Zones.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="additional-radius-miles" />

	<xsl:template match="/">
		<xsl:if test="not($additional-radius-miles)">
			<xsl:message terminate="yes">ERROR: additional-radius-miles parameter must be specified</xsl:message>
                </xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:AddedRadius>
				<xsl:attribute name="miles"><xsl:value-of select="$additional-radius-miles" /></xsl:attribute>
			</kmlpipe:AddedRadius>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:Radius">
		<xsl:variable name="place-id" select="../kmlpipe:Place/@place-id" />
		<xsl:if test="not(@miles)">
			<xsl:message terminate="yes">ERROR: zone place ID "<xsl:value-of select="$place-id" />" doesn't have a radius</xsl:message>
		</xsl:if>

		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:Added>
				<xsl:attribute name="miles"><xsl:value-of select="$additional-radius-miles" /></xsl:attribute>
			</kmlpipe:Added>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:Radius/@miles">
		<xsl:attribute name="miles"><xsl:value-of select=". + $additional-radius-miles" /></xsl:attribute>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

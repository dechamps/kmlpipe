<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Takes all Links from the specified Link Set name and outputs
	the coordinates of the source and destination, with one Link
	per line:
		source_longitude,source_latitude destination_longitude,destination_latitude

	This is most useful as a helper for distance calculators.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="link-set-name" />
	<xsl:output method="text" />
	<xsl:key name="place-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />

	<xsl:template match="/">
		<xsl:if test="not($link-set-name)">
			<xsl:message terminate="yes">ERROR: link-set-name parameter must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML, or contains no folders</xsl:message>
		</xsl:if>

		<xsl:variable name="link-sets" select="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet[@name = $link-set-name]" />
		<xsl:if test="not($link-sets)">
			<xsl:message terminate="yes">ERROR: could not find any Link Sets named "<xsl:value-of select="$link-set-name" />"</xsl:message>
		</xsl:if>

		<xsl:for-each select="$link-sets/kmlpipe:Link">
			<xsl:variable name="source-coordinates" select="../../kml:Point/kml:coordinates" />
			<xsl:if test="not($source-coordinates)">
				<xsl:message terminate="yes">ERROR: place "<xsl:value-of select="../../kml:name" />" (place ID "<xsl:value-of select="../../kmlpipe:Place/@place-id" />") doesn't have Point coordinates</xsl:message>
			</xsl:if>

			<xsl:variable name="destination" select="key('place-id', @place-id)" />
			<xsl:if test="not($destination)">
				<xsl:message terminate="yes">ERROR: Link refers to unknown Place ID "<xsl:value-of select="@place-id" />"</xsl:message>
			</xsl:if>

			<xsl:variable name="destination-coordinates" select="$destination/kml:Point/kml:coordinates" />
			<xsl:if test="not($destination-coordinates)">
				<xsl:message terminate="yes">ERROR: place "<xsl:value-of select="$destination/kml:name" />" (place ID "<xsl:value-of select="$destination/kmlpipe:Place/@place-id" />") doesn't have Point coordinates</xsl:message>
			</xsl:if>

			<xsl:value-of select="$source-coordinates" /><xsl:text> </xsl:text><xsl:value-of select="$destination-coordinates" /><xsl:text>&#xa;</xsl:text>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>

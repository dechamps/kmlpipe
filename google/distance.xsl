<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Internal helper for the "distance" script.

	Given an input KML file and a distances XML file for a specific
	Link Set name, adds the distance information to the links.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="distances-file" />
	<xsl:variable name="distances-document" select="document($distances-file)" />
	<xsl:param name="link-set-name" />
	<xsl:key name="place-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />
	<xsl:key name="distance-from-coordinates" match="/Distances/GoogleDistance" use="concat(@source, ' ', @destination)" />

	<xsl:variable name="link-sets" select="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet[@name = $link-set-name]" />
	<xsl:variable name="links" select="$link-sets/kmlpipe:Link" />
	<xsl:variable name="distances" select="$distances-document/Distances/Distance" />

	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML, or contains no folders</xsl:message>
		</xsl:if>
		<xsl:if test="not($distances-document/Distances)">
			<xsl:message terminate="yes">ERROR: distances document is invalid</xsl:message>
		</xsl:if>
		<xsl:if test="not($link-sets)">
			<xsl:message terminate="yes">ERROR: could not find any Link Sets named "<xsl:value-of select="$link-set-name" />"</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet/kmlpipe:Link">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<xsl:if test="../@name = $link-set-name">
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

				<xsl:for-each select="$distances-document">
					<xsl:variable name="distance" select="key('distance-from-coordinates', concat($source-coordinates, ' ', $destination-coordinates))" />
					<xsl:if test="not($distance)">
						<xsl:message terminate="yes">ERROR: unable to find distance for source coordinates <xsl:value-of select="$source-coordinates" /> and destination coordinates <xsl:value-of select="$destination-coordinates" /></xsl:message>
					</xsl:if>

					<kmlpipe:GoogleDistance>
						<xsl:copy-of select="$distance/*" />
					</kmlpipe:GoogleDistance>
				</xsl:for-each>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Takes a response page from the Google Maps Nearby Search or Text Search
	API and converts it to KML for downstream processing within the kmlpipe
	framework.

	To ensure the conversion is lossless, a <Google> node is added below
	each <Placemark> that contains a full copy of the Google result. There
	is also a <Google> node under the KML folder element that contains a
	copy of the parts of the input that are not under a specific result,
	such that no data is thrown away.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:template match="/">
		<xsl:if test="not(PlaceSearchResponse)">
			<xsl:message terminate="yes">ERROR: document is not a Google Maps Place Search response</xsl:message>
		</xsl:if>
		<xsl:if test="PlaceSearchResponse/status != 'OK'">
			<xsl:message terminate="yes">ERROR: response contains a non-OK status (<xsl:value-of select="PlaceSearchResponse/status" />)</xsl:message>
		</xsl:if>

		<kml:kml>
			<kml:Document>
				<kml:Folder>
					<kml:name>Google Place Search Response Page</kml:name>
					<xsl:apply-templates select="/PlaceSearchResponse/result" />
					<kmlpipe:Google>
						<xsl:apply-templates select="/" mode="copy" />
					</kmlpipe:Google>
				</kml:Folder>
			</kml:Document>
		</kml:kml>
	</xsl:template>

	<xsl:template match="/PlaceSearchResponse/result">
		<kml:Placemark>
			<kmlpipe:Place>
				<xsl:attribute name="place-id">google-place-id:<xsl:value-of select="place_id" /></xsl:attribute>
			</kmlpipe:Place>
			<kml:name><xsl:value-of select="name" /></kml:name>
			<kml:description>https://www.google.com/maps/search/?api=1&amp;query=<xsl:value-of select="geometry/location/lat" />,<xsl:value-of select="geometry/location/lng" />&amp;query_place_id=<xsl:value-of select="place_id" /></kml:description>
			<kml:Point><kml:coordinates><xsl:value-of select="geometry/location/lng" />,<xsl:value-of select="geometry/location/lat" /></kml:coordinates></kml:Point>
			<xsl:if test="vicinity">
				<kml:address><xsl:value-of select="vicinity" /></kml:address>
			</xsl:if>

			<kmlpipe:Google>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()" mode="copy" />
				</xsl:copy>
			</kmlpipe:Google>
		</kml:Placemark>
	</xsl:template>

	<xsl:template match="/PlaceSearchResponse/result" mode="copy" />

	<xsl:template match="@*|node()" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Removes Links to Zones that Placemarks do not fall into.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
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

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:FilteredZones />
		</xsl:copy>
	</xsl:template>

	<xsl:key name="placemarks-by-place-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet/kmlpipe:Link">
		<xsl:variable name="link-set" select=".." />
		<xsl:choose>
			<xsl:when test="$link-set/@name = $link-set-name">
				<xsl:variable name="source" select="$link-set/.." />
				<xsl:variable name="source-place-id" select="$source/kmlpipe:Place/@place-id" />
				<xsl:variable name="destination" select="key('placemarks-by-place-id', @place-id)" />
				<xsl:if test="not($destination)">
					<xsl:message terminate="yes">ERROR: place ID "<xsl:value-of select="$place-id" />" is linking to missing place ID "<xsl:value-of select="@place-id" />"</xsl:message>
				</xsl:if>
				<xsl:variable name="destination-place-id" select="$destination/kmlpipe:Place/@place-id" />

				<xsl:variable name="distance-meters" select="kmlpipe:Distance/@meters" />
				<xsl:if test="not($distance-meters)">
					<xsl:message terminate="yes">ERROR: place ID "<xsl:value-of select="$source-place-id" />" is missing distance information to zone place ID "<xsl:value-of select="$destination-place-id" />"</xsl:message>
				</xsl:if>

				<xsl:variable name="destination-radius-miles" select="$destination/kmlpipe:Radius/@miles" />
				<xsl:if test="not($destination-radius-miles)">
					<xsl:message terminate="yes">ERROR: zone place ID "<xsl:value-of select="@place-id" />" doesn't have a radius</xsl:message>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$distance-meters &lt; $destination-radius-miles * 1609.34">
						<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<kmlpipe:OutOfRadius>
							<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
						</kmlpipe:OutOfRadius>
					</xsl:otherwise>
				</xsl:choose>
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

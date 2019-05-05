<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Removes Placemarks whose kmlpipe Place ID already appears earlier in the input.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:key name="placemarks-by-place-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:RemovedDuplicates />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:variable name="place-id" select="kmlpipe:Place/@place-id" />
		<xsl:if test="not($place-id)">
			<xsl:message terminate="yes">ERROR: Placemark is missing Place ID</xsl:message>
		</xsl:if>

		<xsl:variable name="duplicate-places" select="key('placemarks-by-place-id', $place-id)" />
		<xsl:if test="not($duplicate-places)">
			<xsl:message terminate="yes">ERROR: unable to find place ID <xsl:value-of select="$place-id" /></xsl:message>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="count($duplicate-places[1] | .) > 1">
				<kmlpipe:RemovedDuplicate>
					<xsl:copy>
						<xsl:apply-templates select="@*|node()" />
					</xsl:copy>
				</kmlpipe:RemovedDuplicate>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()" />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

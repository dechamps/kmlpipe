<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Assigns partial scores to each property based on various criteria, leveraging the annotations from the widening step.

	TODO: take supermarket distance into account.
	TODO: introduce zone weight and take them into account.
	TODO: take listings keywords into account.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<!-- For each additional minute of commute, remove penalty-per-commute-minute points. -->
	<xsl:param name="penalty-per-commute-minute" />

	<xsl:template match="/">
		<xsl:if test="not($penalty-per-commute-minute)">
			<xsl:message terminate="yes">ERROR: penalty-per-commute-minute must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:ComputedPartialScores />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder[kml:name='Nestoria Listings']/kml:Placemark">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<xsl:variable name="place-id" select="kmlpipe:Place/@place-id" />

			<xsl:variable name="commute-duration" select="kmlpipe:LinkSet[@name='Workplace']/kmlpipe:Link/kmlpipe:GoogleDistance/DistanceMatrixResponse/row/element/duration" />
			<xsl:if test="count($commute-duration/value) != 1">
				<xsl:message terminate="yes">ERROR: invalid commute distance information on place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>

			<kmlpipe:PartialScore>
				<xsl:attribute name="value"><xsl:value-of select="-($commute-duration/value div 60) * $penalty-per-commute-minute" /></xsl:attribute>
				<xsl:attribute name="description">Commute: <xsl:value-of select="$commute-duration/text" /></xsl:attribute>
			</kmlpipe:PartialScore>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

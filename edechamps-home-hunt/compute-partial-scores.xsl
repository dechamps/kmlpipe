<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Assigns partial scores to each property based on various criteria, leveraging the annotations from the widening step.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<!-- For each additional minute of commute, remove penalty-per-commute-minute points. -->
	<xsl:param name="penalty-per-commute-minute" />

	<!-- For each additional minute of supermarket walking time, remove penalty-per-supermarket-minute points. -->
	<xsl:param name="penalty-per-supermarket-minute" />

	<!-- Load a keyword list from this file, adjust scores based on their presence. -->
	<xsl:param name="keywords-file" />

	<xsl:key name="place-by-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />

	<xsl:variable name="keywords" select="document($keywords-file)/Keywords" />

	<xsl:template match="/">
		<xsl:if test="not($penalty-per-commute-minute)">
			<xsl:message terminate="yes">ERROR: penalty-per-commute-minute must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($penalty-per-supermarket-minute)">
			<xsl:message terminate="yes">ERROR: penalty-per-supermarket-minute must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($keywords)">
			<xsl:message terminate="yes">ERROR: invalid keywords file</xsl:message>
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

			<xsl:variable name="zone" select="key('place-by-id', kmlpipe:LinkSet[@name='Nestoria Zone']/kmlpipe:Link/@place-id)" />
			<xsl:if test="not($zone)">
				<xsl:message terminate="yes">ERROR: could not find zone for place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<xsl:variable name="zone-bias" select="$zone/kmlpipe:ScoreBias/@value" />
			<xsl:if test="not($zone-bias)">
				<xsl:message terminate="yes">ERROR: could not find zone bias for place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<kmlpipe:PartialScore>
				<xsl:attribute name="value"><xsl:value-of select="$zone-bias" /></xsl:attribute>
				<xsl:attribute name="description">Zone: <xsl:value-of select="$zone/kml:name" /></xsl:attribute>
			</kmlpipe:PartialScore>

			<xsl:variable name="commute-duration" select="kmlpipe:LinkSet[@name='Workplace']/kmlpipe:Link/kmlpipe:GoogleDistance/DistanceMatrixResponse/row/element/duration" />
			<xsl:if test="count($commute-duration/value) != 1">
				<xsl:message terminate="yes">ERROR: invalid commute distance information on place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<kmlpipe:PartialScore>
				<xsl:attribute name="value"><xsl:value-of select="-($commute-duration/value div 60) * $penalty-per-commute-minute" /></xsl:attribute>
				<xsl:attribute name="description">Commute: <xsl:value-of select="$commute-duration/text" /></xsl:attribute>
			</kmlpipe:PartialScore>

			<xsl:variable name="supermarket-duration" select="kmlpipe:LinkSet[@name='Supermarkets']/kmlpipe:Link/kmlpipe:GoogleDistance/DistanceMatrixResponse/row/element/duration" />
			<xsl:if test="count($commute-duration/value) != 1">
				<xsl:message terminate="yes">ERROR: invalid supermarket distance information on place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<kmlpipe:PartialScore>
				<xsl:attribute name="value"><xsl:value-of select="-($supermarket-duration/value div 60) * $penalty-per-supermarket-minute" /></xsl:attribute>
				<xsl:attribute name="description">Supermarket: <xsl:value-of select="$supermarket-duration/text" /></xsl:attribute>
			</kmlpipe:PartialScore>

			<xsl:variable name="nestoria-keywords" select="kmlpipe:Nestoria/listings/@keywords" />
			<xsl:if test="not($nestoria-keywords)">
				<xsl:message terminate="yes">ERROR: no Nestoria keywords on place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>

			<xsl:for-each select="$keywords/Keyword">
				<xsl:if test="contains(concat(', ', $nestoria-keywords, ', '), concat(', ', @word, ', '))">
					<kmlpipe:PartialScore>
						<xsl:attribute name="value"><xsl:value-of select="@value" /></xsl:attribute>
						<xsl:attribute name="description">'<xsl:value-of select="@word" />' keyword</xsl:attribute>
					</kmlpipe:PartialScore>
				</xsl:if>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

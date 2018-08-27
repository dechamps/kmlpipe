<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Merges a KML Annex document into the main KML document.

	Given a <kml> input, and a <kml> annex, this appends the <Document>
	children (such as <Placemark>s) from the annex to the main input. The
	<Annex> is retained, but its <Document> children are removed to avoid
	useless duplication of data.

	See annex.xsl for how to add annexes to an XML document.

	You probably want to use the "merge" command instead of this stylesheet,
	as it's easier to use and supports more then 2 operands.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="annex-id" />

	<xsl:key name="annex-id" match="/kml:kml/kmlpipe:Annex" use="@annex-id" />

	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>
		<xsl:if test="not($annex-id)">
			<xsl:message terminate="yes">ERROR: must specify the annex-id to merge from</xsl:message>
		</xsl:if>
		<xsl:if test="not(key('annex-id', $annex-id))">
			<xsl:message terminate="yes">ERROR: annex "<xsl:value-of select="$annex-id" />" not found in input</xsl:message>
		</xsl:if>
		<xsl:if test="not(key('annex-id', $annex-id)/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: annex "<xsl:value-of select="$annex-id" />" does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<xsl:apply-templates select="key('annex-id', $annex-id)/kml:kml/kml:Document/*" mode="merge" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kmlpipe:Annex/kml:kml/kml:Document/*" mode="merge">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:MergedFrom>
				<xsl:attribute name="annex-id"><xsl:value-of select="$annex-id" /></xsl:attribute>
			</kmlpipe:MergedFrom>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kmlpipe:Annex">
		<xsl:if test="@annex-id = $annex-id">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" />
				<kmlpipe:Merged />
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/kml:kml/kmlpipe:Annex/kml:kml/kml:Document/*">
		<xsl:if test="../../@annex-id != $annex-id">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" />
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

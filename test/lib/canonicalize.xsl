<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Removes non-deterministic information from a KML file.

	This includes things like time and file paths. This is required
	when comparing against golden output files to avoid spurious
	differences that would make the test scenario fail.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kmlpipe="http://edechamps.fr/kmlpipe" xmlns:kml="http://www.opengis.net/kml/2.2">
	<xsl:template match="/kml:kml/kmlpipe:Command/@name"><xsl:attribute name="name">[STRIPPED FOR CANONICALIZATION]</xsl:attribute></xsl:template>
	<xsl:template match="/kml:kml/kmlpipe:Command/@args"><xsl:attribute name="args">[STRIPPED FOR CANONICALIZATION]</xsl:attribute></xsl:template>
	<xsl:template match="/kml:kml/kmlpipe:Command/@run-id"><xsl:attribute name="run-id">[STRIPPED FOR CANONICALIZATION]</xsl:attribute></xsl:template>
	<xsl:template match="/kml:kml/kmlpipe:Command/@time"><xsl:attribute name="time">[STRIPPED FOR CANONICALIZATION]</xsl:attribute></xsl:template>

	<xsl:template match="kmlpipe:MergedDocument/@from"><xsl:attribute name="from">[STRIPPED FOR CANONICALIZATION]</xsl:attribute></xsl:template>

	<!-- By default, copy the input to the output. -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

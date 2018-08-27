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
		<xsl:if test="count($links) != count($distances)">
			<xsl:message terminate="yes">ERROR: input contains <xsl:value-of select="count($links)" /> links under name "<xsl:value-of select="$link-set-name" />", but distances file contains <xsl:value-of select="count($distances)" /> distances</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet/kmlpipe:Link">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<xsl:if test="../@name = $link-set-name">
				<!-- TODO: this is O(N²). -->
				<xsl:variable name="offset" select="count(preceding::kmlpipe:Link[../@name = $link-set-name]) + 1" />
				<xsl:variable name="distance-meters" select="$distances[$offset]/@meters" />
				<xsl:if test="not($distance-meters)">
					<xsl:message terminate="yes">ERROR: unable to find distance for Link #<xsl:value-of select="$offset" /></xsl:message>
				</xsl:if>
				<kmlpipe:Distance>
					<xsl:attribute name="meters"><xsl:value-of select="$distance-meters" /></xsl:attribute>
				</kmlpipe:Distance>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

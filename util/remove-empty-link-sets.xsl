<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Removes Placemarks that have an empty Link Set with the specified name.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="link-set-name" />

	<!-- Completely remove placemarks instead of shelving them into a separate Element. -->
	<xsl:param name="obliterate" />

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
			<kmlpipe:RemovedEmptyLinkSets>
				<xsl:attribute name="name"><xsl:value-of select="$link-set-name" /></xsl:attribute>
			</kmlpipe:RemovedEmptyLinkSets>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:variable name="link-set" select="kmlpipe:LinkSet[@name=$link-set-name]" />
		<xsl:choose>
			<xsl:when test="$link-set and count($link-set/kmlpipe:Link) = 0">
				<xsl:if test="not($obliterate)">
					<kmlpipe:RemovedEmptyLinkSet>
						<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
					</kmlpipe:RemovedEmptyLinkSet>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
	</xsl:template>
</xsl:stylesheet>

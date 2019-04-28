<?xml version="1.0" encoding="UTF-8" ?>
<!--
	If places in two folders have an identical ID, remove from first folder.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="remove-from-folder-name" />
	<xsl:param name="compare-against-folder-name" />

	<!-- Completely remove places instead of shelving them into a separate Element. -->
	<xsl:param name="obliterate" />

	<xsl:template match="/">
		<xsl:if test="not($remove-from-folder-name)">
			<xsl:message terminate="yes">ERROR: remove-from-folder-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not($compare-against-folder-name)">
			<xsl:message terminate="yes">ERROR: compare-against-folder-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder[kml:name=$remove-from-folder-name])">
			<xsl:message terminate="yes">ERROR: input does not contain a <xsl:value-of select="$remove-from-folder-name" /> folder</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder[kml:name=$compare-against-folder-name])">
			<xsl:message terminate="yes">ERROR: input does not contain a <xsl:value-of select="$compare-against-folder-name" /> folder</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder">
		<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>

		<xsl:if test="kml:name = $remove-from-folder-name">
			<kmlpipe:FolderDifference>
				<xsl:attribute name="compared-against-folder-name"><xsl:value-of select="$compare-against-folder-name" /></xsl:attribute>
			</kmlpipe:FolderDifference>
		</xsl:if>
	</xsl:template>

	<xsl:key name="placemarks-by-place-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:choose>
			<xsl:when test="../kml:name=$remove-from-folder-name">
				<xsl:variable name="place-id" select="kmlpipe:Place/@place-id" />
				<xsl:if test="not($place-id)">
					<xsl:message terminate="yes">ERROR: placemark does not have a place ID</xsl:message>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="key('placemarks-by-place-id', $place-id)/../kml:name=$compare-against-folder-name">
						<xsl:if test="not($obliterate)">
							<kmlpipe:DifferenceRemoved>
								<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
							</kmlpipe:DifferenceRemoved>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
					</xsl:otherwise>
				</xsl:choose>
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

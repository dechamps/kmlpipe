<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Merges a Folder in a KML document into another Folder.

	Folder children that are not Placemarks (e.g. name) are set
	aside in a kmlpipe:MergedFolder element.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="source-folder-name" />
	<xsl:param name="destination-folder-name" />

	<xsl:template match="/">
		<xsl:if test="not($source-folder-name)">
			<xsl:message terminate="yes">ERROR: source-folder-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not($destination-folder-name)">
			<xsl:message terminate="yes">ERROR: destination-folder-name parameter must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder[kml:name = $source-folder-name])">
			<xsl:message terminate="yes">ERROR: document does not contain a "<xsl:value-of select="$source-folder-name" />" folder</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder[kml:name = $destination-folder-name])">
			<xsl:message terminate="yes">ERROR: document does not contain a "<xsl:value-of select="$destination-folder-name" />" folder</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML, or contains no folders</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder">
		<xsl:choose>
			<xsl:when test="kml:name = $source-folder-name">
				<kmlpipe:MergedFolder>
					<xsl:attribute name="from"><xsl:value-of select="$source-folder-name" /></xsl:attribute>
					<xsl:attribute name="to"><xsl:value-of select="$destination-folder-name" /></xsl:attribute>

					<xsl:copy-of select="@*" />
					<xsl:copy-of select="node()[count(. | ../kml:Placemark) > count(../kml:Placemark)]" />
				</kmlpipe:MergedFolder>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()" />
					<xsl:if test="kml:name = $destination-folder-name">
						<xsl:copy-of select="/kml:kml/kml:Document/kml:Folder[kml:name = $source-folder-name]/kml:Placemark" />
					</xsl:if>
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

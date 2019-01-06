<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Sorts the Links inside each selected Link Set by increasing
	distance.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="link-set-name" />

	<xsl:variable name="folders" select="/kml:kml/kml:Document/kml:Folder" />
	<xsl:variable name="link-sets" select="$folders/kml:Placemark/kmlpipe:LinkSet[@name = $link-set-name]" />

	<xsl:template match="/">
		<xsl:if test="not($folders)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML, or contains no folders</xsl:message>
		</xsl:if>

		<xsl:if test="not($link-sets)">
			<xsl:message terminate="yes">ERROR: input does not contain any Link Set named "<xsl:value-of select="$link-set-name" />"</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="@name = $link-set-name">
					<xsl:apply-templates select="@*|node()[not(self::kmlpipe:Link)]" />
					<xsl:apply-templates select="kmlpipe:Link">
						<xsl:sort select="kmlpipe:Distance/@meters" data-type="number" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*|node()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Add a link to a all link sets that have the specified name.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="link-set-name" />
	<xsl:param name="destination-place-id" />

	<xsl:template match="/">
		<xsl:if test="not($link-set-name)">
			<xsl:message terminate="yes">ERROR: link-set-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not($destination-place-id)">
			<xsl:message terminate="yes">ERROR: destination-place-id parameter must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<xsl:if test="@name=$link-set-name">
				<kmlpipe:Link>
					<xsl:attribute name="place-id"><xsl:value-of select="$destination-place-id" /></xsl:attribute>
				</kmlpipe:Link>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

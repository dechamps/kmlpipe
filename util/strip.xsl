<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Strips a KML document from most elements, only preserving core KML element and kmlpipe Place elements.

	This is mostly intended to remove cruft that accumulates in KML documents as they move through kmlpipe modules.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="@*">
		<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
	</xsl:template>

	<xsl:template match="
		/kml:kml|
		/kml:kml/kml:Document|
		/kml:kml/kml:Document/kml:Style|
		/kml:kml/kml:Document/kml:Style//*|
		/kml:kml/kml:Document/kml:Folder|
		/kml:kml/kml:Document/kml:Folder/kml:name|
		/kml:kml/kml:Document/kml:Folder/kml:Placemark|
		/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:Place|
		/kml:kml/kml:Document/kml:Folder/kml:Placemark/kml:name|
		/kml:kml/kml:Document/kml:Folder/kml:Placemark/kml:description|
		/kml:kml/kml:Document/kml:Folder/kml:Placemark/kml:styleUrl|
		/kml:kml/kml:Document/kml:Folder/kml:Placemark/kml:Point|
		/kml:kml/kml:Document/kml:Folder/kml:Placemark/kml:Point/kml:coordinates
	">
		<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
	</xsl:template>

	<xsl:template match="*" />
</xsl:stylesheet>

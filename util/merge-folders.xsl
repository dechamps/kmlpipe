<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Merges all Folders in a KML document into the first folder.

	Folder children that are not Placemarks (e.g. name) are set
	aside in a kmlpipe:MergedFolder element.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML, or contains no folders</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder">
		<xsl:variable name="merged-folder" select="../kml:Folder[1]" />
		<xsl:if test="count(.|$merged-folder) = 1">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" />

				<xsl:for-each select="../kml:Folder[count(.|$merged-folder) != 1]">
					<xsl:for-each select="kml:Placemark">
						<xsl:copy>
							<xsl:apply-templates select="@*|node()" />
							<kmlpipe:MergedFolder>
								<xsl:attribute name="name"><xsl:value-of select="../kml:name" /></xsl:attribute>
							</kmlpipe:MergedFolder>
						</xsl:copy>
					</xsl:for-each>
					<kmlpipe:MergedFolder>
						<xsl:apply-templates select="(@*|node())[count(.|../kml:Placemark) != count(../kml:Placemark)]" />
					</kmlpipe:MergedFolder>
				</xsl:for-each>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

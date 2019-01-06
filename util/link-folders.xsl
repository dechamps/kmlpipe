<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Creates place links from one folder to another.

	For each Placemark in the "source" folder, create a link set
	containing links to all places in the "destination" folder.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="source-folder-name" />
	<xsl:param name="destination-folder-name" />
	<xsl:param name="link-set-name" />

	<xsl:template match="/">
		<xsl:if test="not($source-folder-name)">
			<xsl:message terminate="yes">ERROR: source-folder-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not($destination-folder-name)">
			<xsl:message terminate="yes">ERROR: destination-folder-name parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not($link-set-name)">
			<xsl:message terminate="yes">ERROR: link-set-name parameter must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML, or contains no folders</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder[kml:name = $source-folder-name])">
			<xsl:message terminate="yes">ERROR: source folder "<xsl:value-of select="$source-folder-name" />" not found</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder[kml:name = $destination-folder-name])">
			<xsl:message terminate="yes">ERROR: destination folder "<xsl:value-of select="$destination-folder-name" />" not found</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="../kml:name = $source-folder-name">
					<xsl:apply-templates select="@*|node()" />
					
					<kmlpipe:LinkSet>
						<xsl:attribute name="name"><xsl:value-of select="$link-set-name" /></xsl:attribute>
						<xsl:for-each select="/kml:kml/kml:Document/kml:Folder[kml:name = $destination-folder-name]/kml:Placemark">
							<kmlpipe:Link>
								<xsl:variable name="place-id" select="kmlpipe:Place/@place-id" />
								<xsl:if test="not($place-id)">
									<xsl:message terminate="yes">ERROR: destination place "<xsl:value-of select="kml:name" />" does not have a kmlpipe Place ID</xsl:message>
								</xsl:if>
								<xsl:attribute name="place-id"><xsl:value-of select="$place-id" /></xsl:attribute>
							</kmlpipe:Link>
						</xsl:for-each>
					</kmlpipe:LinkSet>
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

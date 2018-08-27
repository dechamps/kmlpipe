<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Takes a response page from the Nestoria search listings API
	(i.e. the output from search-listings) and converts it to KML
	for downstream processing within the kmlpipe framework.

	To ensure the conversion is lossless, a <Nestoria> node is added below
	each <Placemark> that contains a full copy of the Nestoria <listings>.
	There is also a <Nestoria> node in the KML folder that contains a copy
	of the parts of the input that are not under a <listings>, such that no
	data is thrown away.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="folder-name" />

	<xsl:template match="/">
		<xsl:if test="not($folder-name)">
			<xsl:message terminate="yes">ERROR: no folder name specified</xsl:message>
		</xsl:if>
		<xsl:if test="not(/opt/response/@total_results)">
			<xsl:message terminate="yes">ERROR: input does not look like a healthy Nestoria search listing response</xsl:message>
		</xsl:if>

		<kml:kml>
			<kml:Document>
				<kml:Folder>
					<kml:name><xsl:value-of select="$folder-name" /></kml:name>
					<xsl:apply-templates select="/opt/response/listings" />
					<kmlpipe:Nestoria>
						<xsl:apply-templates select="/" mode="copy" />
					</kmlpipe:Nestoria>
				</kml:Folder>
			</kml:Document>
		</kml:kml>
	</xsl:template>

	<xsl:template match="/opt/response/listings">
		<kml:Placemark>
			<kmlpipe:Place>
				<!-- Try to extract a sensible unique ID by removing the cruft at the end of lister_url. -->
				<xsl:variable name="place-id" select="substring-before(@lister_url, '/title/')" />
				<xsl:if test="not($place-id)">
					<xsl:message terminate="yes">ERROR: unable to compute a place-id from <xsl:value-of select="@lister_url" /></xsl:message>
				</xsl:if>

				<xsl:attribute name="place-id"><xsl:value-of select="$place-id" /></xsl:attribute>
			</kmlpipe:Place>

			<kml:name><xsl:value-of select="@title" /></kml:name>

			<!-- Barebones description for convenience. Sophisticated presentation is out of scope for this stylesheet. -->
			<kml:description><xsl:value-of select="@lister_url" /></kml:description>

			<kml:Point><kml:coordinates><xsl:value-of select="@longitude" />,<xsl:value-of select="@latitude" /></kml:coordinates></kml:Point>

			<kmlpipe:Nestoria>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()" mode="copy" />
				</xsl:copy>
			</kmlpipe:Nestoria>
		</kml:Placemark>
	</xsl:template>
	
	<xsl:template match="/opt/response/listings" mode="copy" />

	<xsl:template match="@*|node()" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

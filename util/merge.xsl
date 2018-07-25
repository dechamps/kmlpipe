<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Merges a KML document into the input KML document.

	Specifically, this appends to the input <Document> any children from
	the other <Document> (such as <Placemark>s). Everything else is copied
	as-is from the input document.

	To keep the merge lossless and preserve document-level information (such
	as tracing), the output <kml> will also contain a <Merged> element that
	contains the original <kml> from the other document, with the <Document>
	children stripped off.

	You probably want to use the "merge" command instead of this stylesheet,
	as it's easier to use and supports more then 2 operands.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="from" />

	<!-- Unique identifier for this merge, for traceability. -->
	<xsl:param name="merge-id" />

	<xsl:variable name="from-document" select="document($from)" />

	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>
		<xsl:if test="not($from-document/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: other document does not look like valid KML</xsl:message>
		</xsl:if>
		<xsl:if test="not($merge-id)">
			<xsl:message terminate="yes">ERROR: must specify a merge-id</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml">
		<xsl:param name="origin" />

		<xsl:if test="$origin != 'from'">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" />

				<kmlpipe:Merged>
					<xsl:attribute name="merge-id"><xsl:value-of select="$merge-id" /></xsl:attribute>
					<xsl:attribute name="from"><xsl:value-of select="$from" /></xsl:attribute>
					<kml:kml>
						<xsl:apply-templates select="$from-document/kml:kml/*">
							<xsl:with-param name="origin" select="'from'" />
						</xsl:apply-templates>
					</kml:kml>
				</kmlpipe:Merged>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:param name="origin" />

		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:if test="$origin != 'from'">
				<xsl:apply-templates select="node()" />

				<xsl:for-each select="$from-document/kml:kml/kml:Document/*">
					<xsl:copy>
						<xsl:apply-templates select="@*|node()" />

						<kmlpipe:Merged>
							<xsl:attribute name="merge-id"><xsl:value-of select="$merge-id" /></xsl:attribute>
						</kmlpipe:Merged>
					</xsl:copy>
				</xsl:for-each>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

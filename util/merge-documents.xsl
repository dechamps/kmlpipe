<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Merges two KML documents.

	Given a KML input and a KML "from" document, appends the KML Folders
	in the from document to the input.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="from" />
	<xsl:variable name="from-document" select="document($from)" />
	<xsl:variable name="input-document" select="/" />

	<xsl:key name="folder-name" match="/kml:kml/kml:Document/kml:Folder" use="kml:name" />

	<xsl:template match="/">
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>
		<xsl:if test="not($from-document/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: from document "<xsl:value-of select="$from" />" does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<kmlpipe:MergedDocument>
				<xsl:attribute name="from"><xsl:value-of select="$from" /></xsl:attribute>
				<xsl:apply-templates select="$from-document" mode="from" />
			</kmlpipe:MergedDocument>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:name" mode="from">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="from" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="/kml:kml/kml:Document/kml:Folder/*" mode="from" />

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<xsl:apply-templates select="$from-document/kml:kml/kml:Document/kml:Folder" mode="merge-from" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder" mode="merge-from">
		<xsl:variable name="folder-name" select="kml:name" />
		<xsl:for-each select="$input-document">
			<xsl:if test="key('folder-name', $folder-name)">
				<xsl:message terminate="yes">ERROR: folder name "<xsl:value-of select="$folder-name" />" exists both in input and from document</xsl:message>
			</xsl:if>
		</xsl:for-each>

		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="merge-from" />

			<kmlpipe:MergedDocument>
				<xsl:attribute name="from"><xsl:value-of select="$from" /></xsl:attribute>
			</kmlpipe:MergedDocument>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@*|node()" mode="merge-from">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="merge-from" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@*|node()" mode="from">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="from" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

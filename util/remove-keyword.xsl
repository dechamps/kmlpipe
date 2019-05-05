<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Removes places based on a keyword appearing in its name.

	The keyword is matched based on whole words, and is case-sensitive.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="keyword" />

	<xsl:template match="/">
		<xsl:if test="not($keyword)">
			<xsl:message terminate="yes">ERROR: keyword parameter must be specified</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:RemovedKeyword>
				<xsl:attribute name="keyword"><xsl:value-of select="$keyword" /></xsl:attribute>
			</kmlpipe:RemovedKeyword>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:choose>
			<xsl:when test="contains(concat(' ', kml:name, ' '), concat(' ', $keyword, ' '))">
				<kmlpipe:RemovedFromKeyword>
					<xsl:attribute name="keyword"><xsl:value-of select="$keyword" /></xsl:attribute>
					<xsl:copy>
						<xsl:apply-templates select="@*|node()" />
					</xsl:copy>
				</kmlpipe:RemovedFromKeyword>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()" />
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

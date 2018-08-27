<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Adds an XML document as a <kmlpipe:Annex> into the input XML document.

	Specifically, this adds an Annex element to the root element of the
	input document; the Annex element contains the root element of the
	specified "from" document.

	For example, if the input is:

		<Input>input</Input>

	And the other ("from") document is:

		<From>from</From>

	Then the result will be:

		<Input>
			input
			<kmlpipe:Annex>
				<From>from</From>
			</kmlpipe:Annex>
		</Input>

	This tool forms the basis of how seperate KML files can be joined
	together for further processing. Downstream tools will typically use the
	main KML document as one side of some join operation, and a specific
	Annex (identified by its ID) as the other side. If you're looking to
	merge two KML documents together without keeping one of them in an
	Annex, see the merge tool.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:param name="from" />

	<!-- Unique identifier for this annex, for future reference. -->
	<xsl:param name="annex-id" />

	<xsl:variable name="from-document" select="document($from)" />

	<xsl:template match="/*">
		<xsl:param name="origin" />

		<xsl:if test="not($annex-id)">
			<xsl:message terminate="yes">ERROR: must specify an annex-id</xsl:message>
		</xsl:if>

		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<xsl:if test="$origin != 'from'">
				<kmlpipe:Annex>
					<xsl:attribute name="annex-id"><xsl:value-of select="$annex-id" /></xsl:attribute>
					<xsl:attribute name="from"><xsl:value-of select="$from" /></xsl:attribute>
					<xsl:apply-templates select="$from-document/*">
						<xsl:with-param name="origin" select="'from'" />
					</xsl:apply-templates>
				</kmlpipe:Annex>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

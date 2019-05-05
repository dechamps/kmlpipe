<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Adds a child <Command> element below the root element that contains
	information about a particular run of a kmlpipe command.
	The input is otherwise copied unchanged.
	This is meant to add tracing information to aid with debugging and
	troubleshooting.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe">
	<xsl:param name="name" />
	<xsl:param name="args" />
	<xsl:param name="time" />
	<xsl:param name="run-id" />

	<xsl:template match="/*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<kmlpipe:Command>
				<xsl:attribute name="name"><xsl:value-of select="$name" /></xsl:attribute>
				<xsl:attribute name="args"><xsl:value-of select="$args" /></xsl:attribute>
				<xsl:attribute name="time"><xsl:value-of select="$time" /></xsl:attribute>
				<xsl:attribute name="run-id"><xsl:value-of select="$run-id" /></xsl:attribute>
			</kmlpipe:Command>
		</xsl:copy>
	</xsl:template>

	<!-- By default, copy the input to the output. -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Assigns partial scores to each property based on various criteria, leveraging the annotations from the widening step.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<!-- The commute time from which to start adding a penalty. -->
	<xsl:param name="commute-allowance-minutes" />
	<!-- For each additional minute of commute, remove penalty-per-commute-minute points. -->
	<xsl:param name="penalty-per-commute-minute" />
	<!-- Commute times above this threshold are unacceptable. -->
	<xsl:param name="max-commute-minutes" />

	<!-- The supermarket walking time from which to start adding a penalty. -->
	<xsl:param name="supermarket-allowance-minutes" />
	<!-- For each additional minute of supermarket walking time, remove penalty-per-supermarket-minute points. -->
	<xsl:param name="penalty-per-supermarket-minute" />
	<!-- Supermarket times above this threshold are unacceptable. -->
	<xsl:param name="max-supermarket-minutes" />

	<!-- How many points to remove per meter of distance to closest Hyperoptic site. -->
	<xsl:param name="hyperoptic-penalty-per-meter" />
	<!-- Maximum number of points to remove for Hyperoptic distance. -->
	<xsl:param name="hyperoptic-max-penalty" />

	<!-- Load a keyword list from this file, adjust scores based on their presence. -->
	<xsl:param name="keywords-file" />

	<xsl:key name="place-by-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />

	<xsl:variable name="keywords" select="document($keywords-file)/Keywords" />

	<xsl:template match="/">
		<xsl:if test="not($commute-allowance-minutes)">
			<xsl:message terminate="yes">ERROR: commute-allowance-minutes must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($max-commute-minutes)">
			<xsl:message terminate="yes">ERROR: max-commute-minutes must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($penalty-per-commute-minute)">
			<xsl:message terminate="yes">ERROR: penalty-per-commute-minute must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($supermarket-allowance-minutes)">
			<xsl:message terminate="yes">ERROR: supermarket-allowance-minutes must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($max-supermarket-minutes)">
			<xsl:message terminate="yes">ERROR: max-supermarket-minutes must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($penalty-per-supermarket-minute)">
			<xsl:message terminate="yes">ERROR: penalty-per-supermarket-minute must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($hyperoptic-penalty-per-meter)">
			<xsl:message terminate="yes">ERROR: hyperoptic-penalty-per-meter must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($hyperoptic-max-penalty)">
			<xsl:message terminate="yes">ERROR: hyperoptic-max-penalty must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not($keywords)">
			<xsl:message terminate="yes">ERROR: invalid keywords file</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kmlpipe:ComputedPartialScores />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder[kml:name='Nestoria Listings']/kml:Placemark">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<xsl:variable name="place-id" select="kmlpipe:Place/@place-id" />

			<xsl:variable name="zone" select="key('place-by-id', kmlpipe:LinkSet[@name='Nestoria Zone']/kmlpipe:Link/@place-id)" />
			<xsl:if test="not($zone)">
				<xsl:message terminate="yes">ERROR: could not find zone for place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<xsl:variable name="zone-bias" select="$zone/kmlpipe:ScoreBias/@value" />
			<xsl:if test="not($zone-bias)">
				<xsl:message terminate="yes">ERROR: could not find zone bias for place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<kmlpipe:PartialScore>
				<xsl:attribute name="value"><xsl:value-of select="$zone-bias" /></xsl:attribute>
				<xsl:attribute name="description">Zone: <xsl:value-of select="$zone/kml:name" /></xsl:attribute>
			</kmlpipe:PartialScore>

			<xsl:variable name="commute-duration" select="kmlpipe:LinkSet[@name='Workplace']/kmlpipe:Link/kmlpipe:GoogleDistance/DistanceMatrixResponse/row/element/duration" />
			<xsl:if test="count($commute-duration/value) != 1">
				<xsl:message terminate="yes">ERROR: invalid commute distance information on place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<xsl:variable name="commute-minutes" select="$commute-duration/value div 60" />
			<xsl:variable name="commute-penalty" select="($commute-minutes - $commute-allowance-minutes) * $penalty-per-commute-minute" />
			<xsl:variable name="commute-penalty-adjusted">
				<xsl:choose>
					<xsl:when test="$commute-penalty &lt; 0">0</xsl:when>
					<xsl:when test="$commute-minutes &gt; $max-commute-minutes"><xsl:value-of select="$commute-penalty + 1000" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="$commute-penalty" /></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<kmlpipe:PartialScore>
				<xsl:attribute name="value"><xsl:value-of select="-$commute-penalty-adjusted" /></xsl:attribute>
				<xsl:attribute name="description">Commute: <xsl:value-of select="$commute-duration/text" /></xsl:attribute>
			</kmlpipe:PartialScore>

			<xsl:variable name="supermarket-duration" select="kmlpipe:LinkSet[@name='Supermarkets']/kmlpipe:Link/kmlpipe:GoogleDistance/DistanceMatrixResponse/row/element/duration" />
			<xsl:if test="count($commute-duration/value) != 1">
				<xsl:message terminate="yes">ERROR: invalid supermarket distance information on place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<xsl:variable name="supermarket-minutes" select="$supermarket-duration/value div 60" />
			<xsl:variable name="supermarket-penalty" select="($supermarket-minutes - $supermarket-allowance-minutes) * $penalty-per-supermarket-minute" />
			<xsl:variable name="supermarket-penalty-adjusted">
				<xsl:choose>
					<xsl:when test="$supermarket-penalty &lt; 0">0</xsl:when>
					<xsl:when test="$supermarket-minutes &gt; $max-supermarket-minutes"><xsl:value-of select="$supermarket-penalty + 1000" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="$supermarket-penalty" /></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<kmlpipe:PartialScore>
				<xsl:attribute name="value"><xsl:value-of select="-$supermarket-penalty-adjusted" /></xsl:attribute>
				<xsl:attribute name="description">Supermarket: <xsl:value-of select="$supermarket-duration/text" /></xsl:attribute>
			</kmlpipe:PartialScore>

			<xsl:variable name="hyperoptic-meters" select="kmlpipe:LinkSet[@name='Hyperoptic']/kmlpipe:Link/kmlpipe:Distance/@meters" />
			<xsl:if test="count($hyperoptic-meters) != 1">
				<xsl:message terminate="yes">ERROR: invalid Hyperoptic distance information on place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>
			<xsl:variable name="hyperoptic-penalty" select="$hyperoptic-meters * $hyperoptic-penalty-per-meter" />
			<xsl:variable name="hyperoptic-penalty-adjusted">
				<xsl:choose>
					<xsl:when test="$hyperoptic-penalty &lt; $hyperoptic-max-penalty"><xsl:value-of select="$hyperoptic-penalty" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="$hyperoptic-max-penalty" /></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<kmlpipe:PartialScore>
				<xsl:attribute name="value"><xsl:value-of select="-$hyperoptic-penalty-adjusted" /></xsl:attribute>
				<xsl:attribute name="description">Hyperoptic: <xsl:value-of select="$hyperoptic-meters" />m</xsl:attribute>
			</kmlpipe:PartialScore>

			<xsl:variable name="nestoria-keywords" select="kmlpipe:Nestoria/listings/@keywords" />
			<xsl:if test="not($nestoria-keywords)">
				<xsl:message terminate="yes">ERROR: no Nestoria keywords on place ID <xsl:value-of select="$place-id" /></xsl:message>
			</xsl:if>

			<xsl:for-each select="$keywords/Keyword">
				<xsl:if test="contains(concat(', ', $nestoria-keywords, ', '), concat(', ', @word, ', '))">
					<kmlpipe:PartialScore>
						<xsl:attribute name="value"><xsl:value-of select="@value" /></xsl:attribute>
						<xsl:attribute name="description">'<xsl:value-of select="@word" />' keyword</xsl:attribute>
					</kmlpipe:PartialScore>
				</xsl:if>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

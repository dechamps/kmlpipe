<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Sorts and annotates final Edechamps Home Hunt pipeline output for human consumption.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="http://edechamps.fr/kmlpipe">
	<xsl:variable name="listings" select="/kml:kml/kml:Document/kml:Folder[kml:name='Nestoria Listings']" />

	<xsl:key name="place-by-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />

	<xsl:template match="/">
		<xsl:if test="not($listings)">
			<xsl:message terminate="yes">ERROR: input does not contain Nestoria Listings</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<kml:Style id="hyperoptic">
				<kml:IconStyle><kml:Icon><kml:href>https://www.hyperoptic.com/wp-content/themes/hyperoptic3/favicon.ico</kml:href></kml:Icon></kml:IconStyle>
			</kml:Style>
			<kmlpipe:Presented />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="count(. | $listings) > 1">
					<xsl:apply-templates select="@*|node()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*|node()">
						<xsl:sort select="kmlpipe:TotalScore/@value" data-type="number" order="descending" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<xsl:if test="kmlpipe:Hyperoptic">
				<kml:styleUrl>#hyperoptic</kml:styleUrl>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kml:description">
		<xsl:variable name="placemark" select=".." />
		<xsl:variable name="folder" select="$placemark/.." />
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="count($folder | $listings) > 1">
					<xsl:apply-templates select="@*|node()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="longitude" select="substring-before($placemark/kml:Point/kml:coordinates, ',')" />
					<xsl:variable name="latitude" select="substring-after($placemark/kml:Point/kml:coordinates, ',')" />
					<xsl:if test="not($latitude and $longitude)">
						<xsl:message terminate="yes">ERROR: place <xsl:value-of select="$placemark/kmlpipe:Place/@place-id" /> does not have valid coordinates</xsl:message>
					</xsl:if>

					<xsl:variable name="nestoria" select="$placemark/kmlpipe:Nestoria/listings" />

					<xsl:variable name="workplace" select="key('place-by-id', $placemark/kmlpipe:LinkSet[@name='Workplace']/kmlpipe:Link/@place-id)" />
					<xsl:variable name="workplace-longitude" select="substring-before($workplace/kml:Point/kml:coordinates, ',')" />
					<xsl:variable name="workplace-latitude" select="substring-after($workplace/kml:Point/kml:coordinates, ',')" />
					<xsl:variable name="commute-url">https://www.google.com/maps/dir/?api=1&amp;origin=<xsl:value-of select="$latitude" />,<xsl:value-of select="$longitude" />&amp;destination=<xsl:value-of select="$workplace-latitude" />,<xsl:value-of select="$workplace-longitude" />&amp;travelmode=transit</xsl:variable>

					<xsl:variable name="supermarket" select="key('place-by-id', $placemark/kmlpipe:LinkSet[@name='Supermarkets']/kmlpipe:Link/@place-id)" />
					<xsl:variable name="supermarket-longitude" select="substring-before($supermarket/kml:Point/kml:coordinates, ',')" />
					<xsl:variable name="supermarket-latitude" select="substring-after($supermarket/kml:Point/kml:coordinates, ',')" />
					<xsl:variable name="supermarket-url">https://www.google.com/maps/dir/?api=1&amp;origin=<xsl:value-of select="$latitude" />,<xsl:value-of select="$longitude" />&amp;destination=<xsl:value-of select="$supermarket-latitude" />,<xsl:value-of select="$supermarket-longitude" />&amp;travelmode=walking</xsl:variable>

					<xsl:variable name="hyperoptic" select="key('place-by-id', $placemark/kmlpipe:LinkSet[@name='Hyperoptic']/kmlpipe:Link/@place-id)" />
					<xsl:variable name="hyperoptic-status-string">
						<xsl:choose>
							<xsl:when test="$hyperoptic/kmlpipe:Hyperoptic/@status-id = 0">building-live</xsl:when>
							<xsl:otherwise>register-interest</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="hyperoptic-url">https://www.hyperoptic.com/<xsl:value-of select="$hyperoptic-status-string" />/?siteid=<xsl:value-of select="$hyperoptic/kmlpipe:Hyperoptic/@site-id" /></xsl:variable>

					<xsl:variable name="score" select="$placemark/kmlpipe:TotalScore/@value" />
					<xsl:if test="not($score)">
						<xsl:message terminate="yes">ERROR: place <xsl:value-of select="$placemark/kmlpipe:Place/@place-id" /> does not have a total score</xsl:message>
					</xsl:if>

					&lt;a href="<xsl:value-of select="$nestoria/@lister_url" />"&gt;&lt;img src="<xsl:value-of select="$nestoria/@img_url" />" width="<xsl:value-of select="$nestoria/@img_width" />" height="<xsl:value-of select="$nestoria/@img_height" />"&gt;&lt;/a&gt;&lt;br&gt;
					<xsl:value-of select="$nestoria/@price_formatted" /> - &lt;a href="<xsl:value-of select="$commute-url" />"&gt;Commute&lt;/a&gt; - &lt;a href="<xsl:value-of select="$supermarket-url" />"&gt;Supermarket&lt;/a&gt; - &lt;a href="<xsl:value-of select="$hyperoptic-url" />"&gt;Hyperoptic&lt;/a&gt;&lt;br&gt;
					<xsl:for-each select="$placemark/kmlpipe:PartialScore">
						&lt;b&gt;<xsl:value-of select="@description" />&lt;/b&gt; [<xsl:value-of select="@value" />]&lt;br&gt;
					</xsl:for-each>
					Total: <xsl:value-of select="$score" />&lt;br&gt;
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

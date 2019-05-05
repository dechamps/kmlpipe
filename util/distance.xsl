<?xml version="1.0" encoding="UTF-8" ?>
<!--
	For each Link from the selected Link Sets, calculates the great-circle
	("as the crow flies") distance between the Places on both sides of the
	Link. The result is added to the Link element.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:kmlpipe="https://github.com/dechamps/kmlpipe" xmlns:math="http://exslt.org/math">
	<xsl:param name="link-set-name" />

	<xsl:key name="place-id" match="/kml:kml/kml:Document/kml:Folder/kml:Placemark" use="kmlpipe:Place/@place-id" />

	<xsl:template match="/">
		<xsl:if test="not($link-set-name)">
			<xsl:message terminate="yes">ERROR: link-set-name parameter must be specified</xsl:message>
		</xsl:if>

		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder)">
			<xsl:message terminate="yes">ERROR: input does not look like valid KML, or contains no folders</xsl:message>
		</xsl:if>
		<xsl:if test="not(/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet[@name = $link-set-name])">
			<xsl:message terminate="yes">ERROR: could not find any Link Sets named "<xsl:value-of select="$link-set-name" />"</xsl:message>
		</xsl:if>

		<xsl:apply-templates select="@*|node()" />
	</xsl:template>

	<xsl:template match="/kml:kml/kml:Document/kml:Folder/kml:Placemark/kmlpipe:LinkSet/kmlpipe:Link">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />

			<xsl:if test="../@name = $link-set-name">
				<xsl:variable name="source-coordinates" select="../../kml:Point/kml:coordinates" />
				<xsl:if test="not($source-coordinates)">
					<xsl:message terminate="yes">ERROR: place "<xsl:value-of select="../../kml:name" />" (place ID "<xsl:value-of select="../../kmlpipe:Place/@place-id" />") doesn't have Point coordinates</xsl:message>
				</xsl:if>

				<xsl:variable name="destination" select="key('place-id', @place-id)" />
				<xsl:if test="not($destination)">
					<xsl:message terminate="yes">ERROR: Link refers to unknown Place ID "<xsl:value-of select="@place-id" />"</xsl:message>
				</xsl:if>

				<xsl:variable name="destination-coordinates" select="$destination/kml:Point/kml:coordinates" />
					<xsl:if test="not($destination-coordinates)">
					<xsl:message terminate="yes">ERROR: place "<xsl:value-of select="$destination/kml:name" />" (place ID "<xsl:value-of select="$destination/kmlpipe:Place/@place-id" />") doesn't have Point coordinates</xsl:message>
				</xsl:if>

				<xsl:variable name="source-longitude" select="substring-before($source-coordinates, ',')" />
				<xsl:variable name="source-latitude" select="substring-after($source-coordinates, ',')" />
				<xsl:variable name="destination-longitude" select="substring-before($destination-coordinates, ',')" />
				<xsl:variable name="destination-latitude" select="substring-after($destination-coordinates, ',')" />

				<!-- Implements the formula described at: http://www.movable-type.co.uk/scripts/latlong.html -->
				<xsl:variable name="lng1" select="$source-longitude * math:constant('PI', 10) div 180" />
				<xsl:variable name="lat1" select="$source-latitude * math:constant('PI', 10) div 180" />
				<xsl:variable name="lng2" select="$destination-longitude * math:constant('PI', 10) div 180" />
				<xsl:variable name="lat2" select="$destination-latitude * math:constant('PI', 10) div 180" />
				<xsl:variable name="R" select="6371000" />
				<xsl:variable name="delta-lat" select="math:abs($lat1 - $lat2)" />
				<xsl:variable name="delta-lng" select="math:abs($lng1 - $lng2)" />
				<xsl:variable name="a" select="math:power(math:sin($delta-lat div 2), 2) + math:cos($lat1) * math:cos($lat2) * math:power(math:sin($delta-lng div 2), 2)" />
				<xsl:variable name="c" select="2 * math:atan2(math:sqrt($a), math:sqrt(1 - $a))" />
				<xsl:variable name="distance-meters" select="$R * $c" />

				<xsl:if test="not($distance-meters &gt;= 0 and $distance-meters &lt; 21000000)">
					<xsl:message terminate="yes">ERROR: unable to calculate distance for source coordinates <xsl:value-of select="$source-coordinates" /> and destination coordinates <xsl:value-of select="$destination-coordinates" /></xsl:message>
				</xsl:if>

				<kmlpipe:Distance>
					<xsl:attribute name="meters"><xsl:value-of select="$distance-meters" /></xsl:attribute>
				</kmlpipe:Distance>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>

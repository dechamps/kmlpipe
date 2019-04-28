# Converts a Hyperoptic site list in JSON format to KML.
#
# The input is the JSON response to the Hyperoptic map /api/map/getMarkers HTTP
# API call. See README.md for details.
#
# Example run:
#   jq --raw-output --from-file hyperoptic-map.jq \
#     hyperoptic-london-20190428.json
"<?xml version='1.0' encoding='UTF-8'?>\n" +
"<kml xmlns='http://www.opengis.net/kml/2.2' xmlns:kmlpipe='http://edechamps.fr/kmlpipe'><Document><Folder>" +
"<name>Hyperoptic map</name>" +
(map(
	"<Placemark>" +
	@html "<kmlpipe:Place place-id='hyperoptic:\(.siteId)'/>" +
	@html "<name>\(.siteName)</name>" +
	@html "<description>Status: \(.status)</description>" +
	@html "<Point><coordinates>\(.longitude),\(.latitude)</coordinates></Point>" +
	@html "<kmlpipe:Hyperoptic status-id='\(.statusId)'>\(. | tojson)</kmlpipe:Hyperoptic>" +
	"</Placemark>\n"
) | join("")) +
"<kmlpipe:Hyperoptic /></Folder></Document>" +
"</kml>"

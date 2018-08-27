# Converts a Sainsbury's Store Locator store list in JSON format to KML.
#
# The input is the JSON response to the Store Locator /api/v1/stores HTTP API
# call. See README.md for details.
#
# Example run:
#   jq --raw-output --from-file sainsburys-map.jq \
#     sainsburys-london-main-closest25-20180725.json
"<?xml version='1.0' encoding='UTF-8'?>\n" +
"<kml xmlns='http://www.opengis.net/kml/2.2' xmlns:kmlpipe='http://edechamps.fr/kmlpipe'><Document><Folder>" +
"<name>Sainsbury's Store Locator Results Page</name>" +
(.results | map(
	"<Placemark>" +
	@html "<name>\(.name)</name>" +
	@html "<description>Type: \(.store_type)</description>" +
	@html "<Point><coordinates>\(.location.lon),\(.location.lat)</coordinates></Point>" +
	@html "<kmlpipe:Sainsburys>\(. | tojson)</kmlpipe:Sainsburys>" +
	@html "<address>\(.contact.address1) \(.contact.city) \(.contact.post_code)</address>" +
	"</Placemark>\n"
) | join("")) +
@html "<kmlpipe:Sainsburys>\(. | del(.results))</kmlpipe:Sainsburys>" +
"</Folder></Document>" +
"</kml>"

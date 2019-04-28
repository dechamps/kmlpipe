# Hyperoptic sites

The goal of this module is to convert the data from [Hyperoptic's site map][] to KML form so that kmlpipe can use it.

The Hyperoptic website uses a clean HTTP API to fetch the site list in JSON format, but sadly, the API includes (apparently homegrown) countermeasures against reverse engineering. kmlpipe does not include tools to bypass such measures. Therefore the procedure requires manual steps, as described below.

## Getting a site list

Note: as an alternative to getting the JSON site list by hand, you can use the sample file `hyperoptic-london-20190428.json`, which contains all Hyperoptic sites within and around the M25 as of 2019-04-28.

1. Go to the [Hyperoptic's site map][].
2. Start tracing network requests using your browser's developer tools.
3. Configure your Store Locator filters and map view.
4. In the network activity, look for a request to `/api/map/getMarkers`. The JSON response to this request is the file you're looking for, and contains all the sites that are located inside the current map view.
5. You can use that JSON response as the input of `hyperoptic-map.jq`, which will convert it to KML for you.

[Hyperoptic's site map]: https://www.hyperoptic.com/map/

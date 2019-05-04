# Sainsbury's store locator

The goal of this module is to convert the data from [Sainsbury's store locator][] to KML form so that kmlpipe can use it.

The store locator website uses a clean HTTP API to fetch the store list in JSON format, but sadly, the API includes (apparently homegrown) countermeasures against reverse engineering (`token` and `handshake` HTTP headers). kmlpipe does not include tools to bypass such measures. Therefore the procedure requires manual steps, as described below.

## Getting a store list

Note: as an alternative to getting the JSON store list by hand, you can use the sample file `sainsburys-london-main-closest25-20190504.json`, which contains the 25 *super* (main) stores closest to the center of London as of 2019-05-04.

1. Go to the [Sainsbury's store locator][].
2. Start tracing network requests using your browser's developer tools.
3. Configure your Store Locator filters and map view.
4. In the network activity, look for the last request to `/api/v1/stores`. The JSON response to this request is the file you're looking for, and contains the same data as is visible on screen. (Note that the response only contains data for the current page of results.)
5. You can use that JSON response as the input of `sainsburys-map.jq`, which will convert it to KML for you.

[sainsbury's store locator]: https://stores.sainsburys.co.uk/

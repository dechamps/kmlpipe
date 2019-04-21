#!/bin/bash

# Use a consistent, deterministic timestamp for all tests.
export KMLPIPE_TIMESTAMP="$(date --date='2019-01-01 12:00' '+%s')"

source "${BASH_SOURCE%/*}/../../lib/common.bash" || exit 1

kmlpipe_regolden_enabled() {
	[[ -n "${KMLPIPE_REGOLDEN-}" ]]
}

kmlpipe_validate_xml() {
	local file="$1"
	kmlpipe_xmlstarlet val --err --quiet "$file"
}

kmlpipe_validate_kml() {
	local file="$1"
	kmlpipe_validate_xml "$file"
	local found_kml="$(kmlpipe_xmlstarlet sel -N 'kml=http://www.opengis.net/kml/2.2' --template --match '/kml:kml/kml:Document/kml:Folder' --output 'found' "$file")"
	[[ -n "$found_kml" ]] || kmlpipe_error "unable to find a valid KML folder in $file"
}

kmlpipe_check_golden() {
	local golden="$1"

	if kmlpipe_regolden_enabled
	then
		tee -- "$golden.new"
	else
		cat
	fi |
	{ diff --unified -- "$golden" - >&2 || kmlpipe_regolden_enabled; }

	if kmlpipe_regolden_enabled
	then
		mv "$golden.new" "$golden"
	fi
}

kmlpipe_check_golden_xml() {
	kmlpipe_xmlstarlet tr "$kmlpipe_dir/test/lib/canonicalize.xsl" - |
	kmlpipe_xmlstarlet fo --nsclean - |
	kmlpipe_check_golden "$@"
}

kmlpipe_create_tmpdir

export KMLPIPE_FETCH_HERMETIC='test'


set -o errtrace
set -o noclobber
set -o nounset
set -o pipefail
shopt -s dotglob
shopt -s extglob
shopt -s globstar
shopt -s nullglob

kmlpipe_debug_enabled() {
	[[ -n "${KMLPIPE_DEBUG-}" ]]
}

kmlpipe_msg() {
	while IFS='' read -r line
	do
		printf '[kmlpipe] %(%Y-%m-%dT%H:%M:%S%z)T %s %s\n' -1 "$kmlpipe_run_id" "$line" >&2
	done <<< "$*"
}

kmlpipe_debug() {
	kmlpipe_debug_enabled && kmlpipe_msg "[debug] $*"
	return 0
}

kmlpipe_info() {
	if [[ -z "${KMLPIPE_QUIET-}" ]]
	then
		kmlpipe_msg "[info] $*"
	fi
}

kmlpipe_cmd_verbose() {
	kmlpipe_info "${*@Q}"
	"$@"
}

kmlpipe_cmd() {
	kmlpipe_debug "${*@Q}"
	"$@"
}

kmlpipe_error() {
	kmlpipe_msg "[ERROR] $*"
	kmlpipe_onerror
}

kmlpipe_run_id=''
kmlpipe_init() {
	if [[ -z "${KMLPIPE_TIMESTAMP-}" ]]
	then
		printf -v KMLPIPE_TIMESTAMP '%(%s)T' -1
		kmlpipe_debug "using timestamp: $KMLPIPE_TIMESTAMP"
	fi
	printf -v kmlpipe_run_id '%(%s)T-%s-%s' -1 "$$" "$RANDOM"
	kmlpipe_debug "${0@Q} ${kmlpipe_args[*]@Q}"
}

[[ "${#BASH_SOURCE[@]}" -ge 2 ]] || kmlpipe_error "invalid kmlpipe common.bash invocation"
kmlpipe_dir="${BASH_SOURCE[0]%/*}/.."
[[ -n "$kmlpipe_dir" && -e "$kmlpipe_dir/lib/common.bash" ]] || kmlpipe_error "$kmlpipe_dir doesn't look like a valid kmlpipe distribution"
kmlpipe_script_dir="${BASH_SOURCE[-1]%/*}"

kmlpipe_tmpdir=''
kmlpipe_create_tmpdir() {
	local MKTEMP_ARGS=(--directory --suffix=".kmlpipe.$kmlpipe_run_id")
	if [[ -n "${KMLPIPE_TMPDIR-}" ]]
	then
		MKTEMP_ARGS+=(--tmpdir="$KMLPIPE_TMPDIR")
	fi
	kmlpipe_tmpdir="$(mktemp "${MKTEMP_ARGS[@]}")"
	kmlpipe_debug "Using temporary directory: $kmlpipe_tmpdir"

	# For convenience
	printf '%(%Y-%m-%dT%H:%M:%S%z)T %s %s\n' -1 "$kmlpipe_run_id" "${0@Q} ${kmlpipe_args[*]@Q}" > "$kmlpipe_tmpdir/KMLPIPE_COMMAND"
}

kmlpipe_onexit() {
	kmlpipe_debug "EXITING from ${0@Q} ${kmlpipe_args[*]@Q}"

	if [[ -n "$kmlpipe_tmpdir" ]]
	then
		if [[ -n "${KMLPIPE_TMPDIR-}" ]]
		then
			kmlpipe_debug "Not deleting custom temporary directory: $kmlpipe_tmpdir"
		else
			kmlpipe_debug "Deleting temporary directory: $kmlpipe_tmpdir"
			rm -rf "$kmlpipe_tmpdir"
		fi
	fi
}

kmlpipe_onerror() {
	local status="$?"

	kmlpipe_msg "FATAL ERROR ($status) in $BASHPID ${0@Q} ${kmlpipe_args[*]@Q}"

	local frame caller
	for (( frame=0; ; frame++ ))
	do
		caller="$(caller "$frame" || true)"
		if [[ -z "$caller" ]]
		then
			break
		fi
		kmlpipe_msg "  $caller"
	done

	kmlpipe_msg "$(pstree -a -A -T -s -l -p $$ || true)"

	exit 1
}

kmlpipe_usage_define() {
	read -r -d '' kmlpipe_usage || true
}

kmlpipe_usage_error() {
	kmlpipe_msg "invalid command line: $0 ${kmlpipe_args[*]@Q}"
	echo >&2
	echo "$kmlpipe_usage" >&2
	exit 1
}

kmlpipe_args_pop() {
	if [[ "${#kmlpipe_args_stack[@]}" -lt 1 ]]
	then
		return 1
	fi
	printf -v "$1" %s "${kmlpipe_args_stack[0]}"
	kmlpipe_args_stack=("${kmlpipe_args_stack[@]:1}")
}

kmlpipe_args_pop_or_error() {
	if ! kmlpipe_args_pop "$@"
	then
		kmlpipe_usage_error
	fi
}

kmlpipe_args_end() {
	if [[ "${#kmlpipe_args_stack[@]}" -gt 0 ]]
	then
		kmlpipe_usage_error
	fi
}

kmlpipe_xmlstarlet() {
	kmlpipe_cmd xmlstarlet "$@"
}

kmlpipe_jq() {
	kmlpipe_cmd jq "$@"
}

kmlpipe_output_xml() {
	local now args
	printf -v now '%(%Y-%m-%dT%H:%M:%S%z)T' -1
	args="${kmlpipe_args[*]@Q}"
	# xmlstarlet tr does not support string arguments that contain both quotes and single-quotes. *facepalm*
	# To work around this limitation, we replace " with '$'\042'', which should hopefully preserve the intent of the command line.
	args="${args//\"/\'\$\'\\042\'\'}"
	kmlpipe_xmlstarlet tr "$kmlpipe_dir/lib/command.xsl" -s "name=${0@Q}" -s "args=$args" -s "time=$now" -s "run-id=$kmlpipe_run_id" "$@" |
	kmlpipe_xmlstarlet fo --nsclean "$@"
}
 
kmlpipe_args=("$@")
kmlpipe_args_stack=("$@")
kmlpipe_init
trap kmlpipe_onexit EXIT
trap kmlpipe_onerror ERR

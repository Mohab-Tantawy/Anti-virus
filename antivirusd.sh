#!/bin/bash
flagged_extension="exe bat vbs scr ps1"
flagged_keywords="virus trojan malware worm ransomware"

LF="dir-info.last"
NF="dir-info.new"

if [ $# -ne 3 ]; then
	echo "Usage: $0 dir malicious_dir interval-secs" >&2
	exit 1
fi

dir="$1"
mal_dir="$2"
interval="$3"

if [ ! -d "$dir" ]; then
	echo "ERROR: '$dir' is not a directory" >&2
	exit 1
fi

mkdir -p "$mal_dir" || {
	echo "ERROR:cannot create 'mal_dir'" >&2
	exit 1
}

is_mal() {
	local path="$1"
	local name ext kw
	name=$(basename "$path")

	if [[ "$name" == *.* ]]; then
		ext="${name##*.}"
		ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
		for e in $flagged_extension; do
			if [ "$ext" = "$e" ]; then
				return 0
			fi
		done
	fi

	for kw in $flagged_keywords; do
		if grep -qi -- "$kw" "$path" 2>/dev/null; then
			return 0
		fi
	done
	return 1
}

scan() {
	local path name
	for path in "$dir"/* "$dir"/.[!.]*; do
		[ -f "$path" ] || continue
		name=$( basename "$path")
		if is_mal "$path"; then
			echo "$name is malicious and it is DELETED"
			cp -- "$path" "$mal_dir/$name"
			rm -f -- "$path"
		fi
	done
}

while true; do
	if [ ! -f "$LF" ]; then
		scan
		ls -l "$dir" > "$LF"
	else
		ls -l "$dir" > "$NF"
		if ! cmp -s "$LF" "$NF"; then
			scan
			ls -l "$dir" > "$LF"
		fi
	fi

	sleep "$interval"
done

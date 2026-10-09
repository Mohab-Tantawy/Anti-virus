#!/bin/bash
if [ $# -ne 2 ]; then
	echo "Usage: $0 dir malicious_dir" >&2
	exit 1
fi

dir="$1"
mal_dir="$2"

if [ ! -d "$dir" ]; then
	echo "ERROR: '$dir' is not a directory" >&2
	exit 1
fi

if [ ! -d "$mal_dir" ]; then
	echo "ERROR: '$mal_dir' is not a directory" >&2
	exit 1
fi

loadfiles() {
	files=()
	local p
	for p in "$mal_dir"/* "$mal_dir"/.[!.]*; do
		[ -f "$p" ] && files+=("$(basename "$p")")
	done
}

loadfiles
if [ ${#files[@]} -eq 0 ]; then
	echo "No malicious files to review"
	exit 0
fi

while true; do
	loadfiles
	if [ ${#files[@]} -eq 0 ]; then
		echo "No more files to review"
		exit 0
	fi

	echo
	echo "Files in quarantine"
	for i in "${!files[@]}"; do
		echo "$((i + 1)) ${files[$i]}"
	done
	read -r -p "Pick a file by number (0 to quit): " pick || exit 0

	if [ "$pick" == "0" ]; then
		exit 0
	fi

	if ! [[ "$pick" =~ ^[0-9]+$ ]] || [ "$pick" -lt 1 ] || [ "$pick" -gt ${#files[@]} ]; then
		echo "Invalid choice"
		continue
	fi

	file="${files[$((pick - 1))]}"

	echo
	echo "Selected: $file"
	echo " 1) Restore file to dir $dir"
	echo " 2) Delete permanently"
	echo " 3) Leave and go back"
	read -r -p "Choose 1, 2, 3: " action || exit 0

	case "$action" in
		1)
			mv -- "$mal_dir/$file" "$dir/$file"
			echo "$file is restored to $dir"
			;;
		2)
			rm -f -- "$mal_dir/$file"
			echo "$file is permanently deleted"
			;;
		3)
			;;
		*)
			echo "Invalid choice"
			;;
	esac
done
EOF


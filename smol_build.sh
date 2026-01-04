#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Check that two arguments were given
if [ $# -ne 2 ]; then
    echo "Error: Two arguments required!" >&2
    echo "Usage: $0 <source_dir> <build_dir>" >&2
    echo "Warning: The build directory will be emptied when the script is run." >&2
    exit 1
fi

source_dir="$1";
build_dir="$2";

# Make sure the build directory isn't the current directory
if [ "$build_dir" = "." ]; then
    echo "Error: Build directory cannot be current directory (.)" >&2
    echo "Warning: The build directory will be emptied when the script is run." >&2
    exit 1
fi

if [ ! -d "$source_dir" ] ; then
    echo "Error: Source input must be a directory" >&2
    exit 1
fi

echo "smol build is building..."
echo

# Create (if needed) and then clear out the build directory
mkdir -p "$2" && find "$2" -mindepth 1 -depth -exec rm -rf {} +

escape_for_bash_replacement() {
    local content
    if [ -f "$1" ]; then
        content=$(<"$1")   # read file content
    else
        content="$1"       # or take string directly
    fi
    # Escape backslashes first
    content="${content//\\/\\\\}"
    # Escape ampersands
    content="${content//&/\\&}"
    printf '%s' "$content"
}

descend() { # param1: recursive directory | param2: template_string_so_far

	# Handle the template first if there is one
	local template="$2"
	if [[ -f "$1/smol_template.html" ]]; then
		echo " [templating] $1/smol_template.html"
		if [[ -z "$template" ]]; then
		    template=$(<"$1/smol_template.html")
	    else
	    	template="${template/<smol_content\/>/$(<"$1/smol_template.html")}"
		fi
	fi

	# Look at all the page html files
	for item in "$1"/*; do
        if [ -d "$item" ]; then
            descend "$item" "$template"
    	elif [ -f "$item" ] && [[ "$item" =~ \.html$ ]]; then
    		if [[ ! "$item" =~ ^.*smol_template\.html$ ]]; then
			    local output_path="$build_dir/${item#*/}"
			    echo " [building]   $item -> $output_path"
			    escaped_content=$(escape_for_bash_replacement "$item")
		    	output_data="${template/<smol_content\/>/$escaped_content}"
			    mkdir -p $(dirname "$output_path")
		    	printf '%s' "$output_data" > "$output_path"
	    	fi
		else # All other static files
			local output_path="$build_dir/${item#*/}"
			echo " [copying]    $item -> $output_path"
			mkdir -p $(dirname "$output_path")
			cp "$item" "$output_path"
        fi
	done
}

descend "$source_dir" ""
echo
echo "smol build is done!"

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "smol build is smol building..."
echo

# TODO - make directory usage robust
source_dir=$1;
build_dir=$2;

# Create (if needed) and then clear out the build directory
mkdir -p $2 && find $2 -mindepth 1 -depth -exec rm -rf {} +

descend() { # param1: recursive directory | param2: template_string_so_far

	local template=$2
	if [[ -f "$1/smol_template.html" ]]; then
		echo " [tmplt] $1/smol_template.html"
		if [[ -z "$template" ]]; then
		    template=$(cat $1/smol_template.html)
	    else
	    	template="${template//<smol_content\/>/$(cat $1/smol_template.html)}"
		fi
	fi

	# Look at all the page html files
	for item in "$1"/*; do
        if [ -d "$item" ]; then
            descend "$item" "$template"
    	elif [ -f "$item" ] && [[ "$item" =~ \.html$ ]]; then
    		if [[ ! "$item" =~ ^.*smol_template\.html$ ]]; then
			    local output_path="$build_dir/${item#*/}"
			    echo " [build] $item -> $output_path"
		    	output_data="${template//<smol_content\/>/$(cat $item)}"
			    mkdir -p $(dirname "$output_path")
		    	printf '%s' "$output_data" > "$output_path"
	    	fi
		else # All other static files
			local output_path="$build_dir/${item#*/}"
			echo " [copy]  $item -> $output_path"
			mkdir -p $(dirname "$output_path")
			cp $item $output_path
        fi
	done
}

descend $source_dir ""

# TODO - quite mode
# TODO - Handle CSS is special case
# TODO - Handle static files
#!/bin/bash

print_separator_row() {
    local column_number=$1
    local column_width=$2
    local separator=$(printf "%-${column_width}s" | tr ' ' '-')
    printf "| %-${column_width}s |" "$separator"
    for ((i = 1; i < column_number; i++)); do
        printf " %-${column_width}s |" "$separator"
    done
    printf "\n"
}


sort_by_percentages_and_prefixes() {
    local rows=("$@")
    # Sort by percentages in 2nd column first,
    # Then sort be prefix names
    printf "%s\n" "${rows[@]}" | sort -k4nr -k2
}

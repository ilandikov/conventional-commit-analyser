#!/bin/bash

print_header_line() {
    local column_width=$1
    local by_option=$2
    local periods_sorted=("${@:3}")

    local header_line
    header_line=$(printf "| %-*s | %-*s |" "$column_width" "Type" "$column_width" "Total")

    if [ "$by_option" != "none" ]; then
        for period in "${periods_sorted[@]}"; do
            header_line+=$(printf " %-*s |" "$column_width" "$period")
        done
    fi

    printf "\n%s\n" "$header_line"
}

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

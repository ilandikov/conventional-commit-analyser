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

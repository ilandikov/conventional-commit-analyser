#!/bin/bash

# Calculate the percentage and handle the special cases
calculate_percentage() {
    local count=$1
    local total=$2
    local percentage=$(awk "BEGIN {printf \"%.0f\", ($count / $total) * 100}")

    if [ "$count" -eq 0 ]; then
        echo "0%"
    elif [ "$percentage" -lt 1 ]; then
        echo "<1%"
    else
        echo "${percentage}%"
    fi
}

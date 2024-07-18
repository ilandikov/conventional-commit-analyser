# echo_color.sh

# Define a function for colored output
echo_color() {
    local color=$1
    local text=$2
    echo -e "\033[${color}m${text}\033[0m"
}

# Define function for pass (green)
echo_pass() {
    echo_color "0;32" "$1"
}

# Define function for warning (yellow)
echo_warning() {
    echo_color "0;33" "$1"
}

# Define function for error (red)
echo_error() {
    echo_color "0;31" "$1"
}

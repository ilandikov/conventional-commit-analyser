#!/bin/bash

source ./tests/helpers/echo_color.sh

# Check for colordiff and set the diff command accordingly
if command -v colordiff &> /dev/null; then
    diff_cmd="colordiff"
else
    diff_cmd="diff"
fi

# Initialize an array to keep track of tests
passed_tests=()
failed_tests=()
approved_tests=()

# Check if the --approve option is provided
approve=false
if [[ "$1" == "--approve" ]]; then
    approve=true
    shift
fi


# Find all .args files in the tests directory
args_files=$(find tests -type f -name "*.args")

# Loop over each found arguments file
for args_file in $args_files; do
    # Extract the test name from the args file name
    test_name=$(basename "$args_file" .args)

    # Define the received output file and approved output file based on the test name
    received_output_file="tests/${test_name}.received"
    approved_output_file="tests/${test_name}.approved"

    # Check if the arguments file exists
    if [ ! -f "$args_file" ]; then
        echo_error "Error: Arguments file '$args_file' does not exist."
        failed_tests+=("$test_name")
        continue
    fi

    # Read the arguments from the file
    args=$(cat "$args_file")

    # Run the script with the arguments and capture its output
    command_output=$(bash ./conventional-commit-analyser.sh $args)

    # Save the output to the received output file in the tests/ directory
    echo "$command_output" > "$received_output_file"

    # Compare the received output to the approved output
    echo
    if diff_output=$($diff_cmd -u "$approved_output_file" "$received_output_file"); then
        echo_pass "Test '$test_name' passed."
        passed_tests+=("$test_name")
    else
        if [ "$approve" = true ]; then
            rm "$approved_output_file"
            cp "$received_output_file" "$approved_output_file"
            echo_warning "Test '$test_name' approved."
            approved_tests+=("$test_name")
        else
            echo_error "Test '$test_name' failed:"
            failed_tests+=("$test_name")
        fi

        echo
        echo "$diff_output"
    fi
done

# Print the results of all tests
echo
echo_pass "Passed: ${#passed_tests[@]}"

echo_error "Failed: ${#failed_tests[@]}"
if [ "${#failed_tests[@]}" -ne 0 ]; then
    for test in "${failed_tests[@]}"; do
        echo_error "- $test"
    done
fi

if [ "$approve" = true ]; then
    echo_warning "Approved: ${#approved_tests[@]}"
    for test in "${approved_tests[@]}"; do
        echo_warning "- $test"
    done
fi

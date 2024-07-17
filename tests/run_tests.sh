#!/bin/bash

# Check if exactly one argument is provided
if [ "$#" -lt 1 ]; then
    echo "Error: Please provide at least one test name."
    echo "Usage: $0 <test_name1> <test_name2> ..."
    exit 1
fi

# Initialize an array to keep track of failed tests
failed_tests=()

# Loop over each provided test name
for test_name in "$@"; do
    # Define the arguments file, received output file, and expected output file in the tests/ directory
    args_file="tests/${test_name}.args"
    received_output_file="tests/${test_name}.received"
    expected_output_file="tests/${test_name}.expected"

    # Check if the arguments file exists
    if [ ! -f "$args_file" ]; then
        echo "Error: Arguments file '$args_file' does not exist."
        failed_tests+=("$test_name")
        continue
    fi

    # Read the arguments from the file
    args=$(cat "$args_file")

    # Run the script with the arguments and capture its output
    command_output=$(bash ./conventional-commit-analyser.sh $args)

    # Save the output to the received output file in the tests/ directory
    echo "$command_output" > "$received_output_file"

    # Compare the received output to the expected output
    if diff -q "$received_output_file" "$expected_output_file" > /dev/null; then
        echo "Test '$test_name' passed."
    else
        echo "Test '$test_name' failed."
        failed_tests+=("$test_name")
    fi
done

# Print the results of all tests
echo
if [ "${#failed_tests[@]}" -ne 0 ]; then
    echo "The following tests failed:"
    for test in "${failed_tests[@]}"; do
        echo "- $test"
    done
else
    echo "All tests passed."
fi

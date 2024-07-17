#!/bin/bash

# Define an array of test names
tests=(
  "no_args"
  "ilandikov_commits"
  "repository_not_existing"
)

# Initialize an array to keep track of failed tests
failed_tests=()

# Loop over each provided test name
for test_name in "${tests[@]}"; do
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
    echo
    if diff_output=$(diff -u "$expected_output_file" "$received_output_file"); then
        echo "Test '$test_name' passed."
    else
        echo "Test '$test_name' failed:"
        echo "$diff_output"
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

#!/bin/bash

# Define an array of test names
tests=(
  "no_args"
)

# Call the original script with the array of tests
./tests/run_tests.sh "${tests[@]}"

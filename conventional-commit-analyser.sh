#!/bin/bash

# Define words to filter out
words_to_filter=("Merge")

# Define author's name
author_name="Ilyas Landikov"

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one repository as an argument."
    echo "Usage: $0 <repository>"
    exit 1
fi

# Check if the specified repository exists
if [ ! -d "$1" ]; then
    echo "Error: The specified repository '$1' does not exist."
    exit 1
fi

# Change to the specified repository
cd "$1" || exit

# Store the output of git log in a variable, filtering by author's name
commit_messages=$(git log --pretty="%s %an" | grep "$author_name")

# Create an array to store unique prefixes
prefixes=()

# Initialize total number of commits by the specified author
author_commit_count=0

# Initialize total number of commits
commit_count=0

# Initialize total number of filtered commits
filtered_commit_count=0

# Initialize array to store prefix counts
declare -a prefix_counts

# Iterate over each line in the log output
while IFS= read -r commit_info; do
    # Extract commit message and author name
    commit_message=$(echo "$commit_info" | cut -d " " -f 1)
    author=$(echo "$commit_info" | cut -d " " -f 2-)

    # Increment the total count of commits
    ((commit_count++))

    # Check if the commit message starts with any word in words_to_filter
    skip_commit=false
    for word in "${words_to_filter[@]}"; do
        if [[ $commit_message == $word* ]]; then
            ((filtered_commit_count++))
            skip_commit=true
            break
        fi
    done

    # If commit message starts with a filtered word, skip processing it
    if $skip_commit; then
        continue
    fi

    # Increment the total count of commits by the specified author
    ((author_commit_count++))

    # Extract the prefix from the commit message
    commit_message_prefix=$(echo "$commit_message" | cut -d ":" -f 1)

    # If the prefix is not already in the prefixes array, add it
    if ! [[ " ${prefixes[@]} " =~ " ${commit_message_prefix} " ]]; then
        prefixes+=("$commit_message_prefix")
        prefix_counts+=("0")
    fi

    # Increment the count for the prefix
    for i in "${!prefixes[@]}"; do
        if [ "${prefixes[$i]}" == "$commit_message_prefix" ]; then
            ((prefix_counts[$i]++))
            break
        fi
    done
done <<< "$commit_messages"

# Calculate the total number of commits excluding filtered ones
total_commits_excluding_filtered=$((author_commit_count - filtered_commit_count))

# Check if commit messages exist for the specified author
if [ -z "$commit_messages" ]; then
    echo "No commits found by $author_name."
    exit 0
fi

# Print the total number of commits by the specified author
echo "Total number of commits by $author_name: $author_commit_count"
echo "Filtered commits: $filtered_commit_count"
echo "Analyzed commits: $total_commits_excluding_filtered"

# Iterate over the prefixes and calculate the percentage of commits
for i in "${!prefixes[@]}"; do
    prefix_percentage=$(awk "BEGIN {printf \"%.0f\", (${prefix_counts[$i]} / $total_commits_excluding_filtered) * 100}")
    if [ "$prefix_percentage" -lt 1 ]; then
        prefix_percentage="<1"
    fi
    echo "$prefix_percentage%: ${prefixes[$i]}"
done | sort -nr

#!/bin/bash

# Default values
repository=""
author_name=""
show_non_conventional_commits=false

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --repository)
        repository="$2"
        shift # past argument
        shift # past value
        ;;
        --author-name)
        # Join all remaining arguments as the author name
        shift # past argument
        author_name="$*"
        # Remove leading and trailing quotes from author_name if present
        author_name=$(echo "$author_name" | sed -e 's/^"//' -e 's/"$//')
        break
        ;;
        --show-non-conventional-commits)
        show_non_conventional_commits=true
        shift # past argument
        ;;
        *)
        echo "Unknown parameter passed: $1"
        exit 1
        ;;
    esac
done

# Check if repository is specified
if [ -z "$repository" ]; then
    echo "Error: Please provide a repository path using --repository."
    echo "Usage: $0 --repository <path> [--author-name <author>] [--show-non-conventional-commits]"
    exit 1
fi

# Check if the specified repository exists
if [ ! -d "$repository" ]; then
    echo "Error: The specified repository '$repository' does not exist."
    exit 1
fi

# Change to the specified repository
cd "$repository" || exit

# Store the output of git log in a variable, filtering by author's name if provided
if [ -n "$author_name" ]; then
    commit_messages=$(git log --pretty="%s :: %an :: %ad :: %h" --date=short | grep "$author_name")
else
    commit_messages=$(git log --pretty="%s :: %an :: %ad :: %h" --date=short)
fi

# Check if commit messages exist
if [ -z "$commit_messages" ]; then
    if [ -n "$author_name" ]; then
        echo "No commits made by '$author_name' found in repository '$repository'."
        exit 0
    fi

    echo "No commits found in repository '$repository'."
    exit 0
fi

# Create an array to store unique prefixes
prefixes=()

# Initialize total number of commits by the specified author
author_commit_count=0

# Initialize total number of commits
commit_count=0

# Initialize total number of non-conventional commits
non_conventional_commit_count=0

# Initialize array to store prefix counts
declare -a prefix_counts

# Initialize array to store non-conventional commits info
non_conventional_commits_info=()

# Iterate over each line in the log output
while IFS= read -r commit_info; do
    # Extract commit message, author name, date, and short hash
    commit_message=$(echo "$commit_info" | awk -F ' :: ' '{print $1}')
    
    
    
    # Increment the total count of commits by the specified author
    ((author_commit_count++))

    # Check if the commit message contains a ':'
    if [[ "$commit_message" != *:* ]]; then
        ((non_conventional_commit_count++))
        if $show_non_conventional_commits; then
            author=$(echo "$commit_info" | awk -F ' :: ' '{print $2}')
            commit_date=$(echo "$commit_info" | awk -F ' :: ' '{print $3}')
            commit_hash=$(echo "$commit_info" | awk -F ' :: ' '{print $4}')

            non_conventional_commits_info+=("$commit_hash on $commit_date by $author '$commit_message'")
        fi
        continue
    fi

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

# Calculate the total number of commits excluding non-conventional ones
total_commits_excluding_non_conventional=$((author_commit_count - non_conventional_commit_count))

# Print the total number of commits
if [ -n "$author_name" ]; then
    echo "Total number of commits by $author_name in repository '$repository': $author_commit_count"
else
    echo "Total number of commits in repository '$repository': $author_commit_count"
fi

echo "Skipped non-conventional commits: $non_conventional_commit_count"
# Print non-conventional commits info if --show-non-conventional-commits is set
if $show_non_conventional_commits; then
    for commit_info in "${non_conventional_commits_info[@]}"; do
        echo "$commit_info"
    done
fi

echo "Conventional commits: $total_commits_excluding_non_conventional"

# Iterate over the prefixes and calculate the percentage of commits
for i in "${!prefixes[@]}"; do
    prefix_percentage=$(awk "BEGIN {printf \"%.0f\", (${prefix_counts[$i]} / $total_commits_excluding_non_conventional) * 100}")
    if [ "$prefix_percentage" -lt 1 ]; then
        prefix_percentage="<1"
    fi
    echo "$prefix_percentage%: ${prefixes[$i]}"
done | sort -nr

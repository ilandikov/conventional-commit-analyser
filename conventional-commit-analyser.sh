#!/opt/homebrew/bin/bash

source ./calculate_percentage.sh
source ./mdtable_utils.sh

# Default values
repository=""
author_name=""
show_skipped_commits=false
by_option="none"

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --repository)
        repository="$2"
        shift # past argument
        shift # past value
        ;;
        --author-name)
        shift # past argument
        while [[ "$#" -gt 0 && $1 != "--"* ]]; do
            author_name="$author_name $1"
            shift
        done
        author_name=$(echo "$author_name" | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//')
        ;;
        --show-skipped-commits)
        show_skipped_commits=true
        shift # past argument
        ;;
        --by)
        by_option="$2"
        shift # past argument
        shift # past value
        ;;
        *)
        echo "Unknown parameter passed: $1"
        echo "Usage: $0 --repository <path> [--author-name <author>] [--show-skipped-commits] [--by <period>]"
        exit 1
        ;;
    esac
done

# Restrict --by option to 'week', 'month', and 'year' and
# determine period format based on by_option
case $by_option in
    year)
    date_format="%Y"
    ;;
    month)
    date_format="%Y-%m"
    ;;
    week)
    date_format="%Y-W%U"
    ;;
    none)
    date_format="none"
    ;;
    *)
    echo "Error: Unsupported value for --by. Only 'year', 'month' and 'week' are supported."
    echo "Usage: $0 --repository <path> [--author-name <author>] [--show-skipped-commits] [--by <period>]"
    exit 1
esac

# Check if repository is specified
if [ -z "$repository" ]; then
    echo "Error: Please provide a repository path using --repository."
    echo "Usage: $0 --repository <path> [--author-name <author>] [--show-skipped-commits] [--by <period>]"
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
    commit_messages=$(git log --pretty="%s :: %an :: %ad :: %h" --date=short --author="$author_name")
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

# Initialize total number of skipped commits
skipped_commit_count=0

# Initialize array to store prefix counts
prefix_counts=()

# Initialize array to store skipped commits info
skipped_commits_info=()

# Initialize arrays to store periodic commit counts
declare -A periodic_prefix_counts
declare -A period_commit_counts
periods=()

# Iterate over each line in the log output
while IFS= read -r commit_info; do
    # Increment the total count of commits by the specified author
    ((author_commit_count++))

    # Extract commit message, author name, date, and short hash
    commit_message=$(echo "$commit_info" | awk -F ' :: ' '{print $1}')
    commit_date=$(echo "$commit_info" | awk -F ' :: ' '{print $3}')

    # Check if the commit message contains a word followed by a ':'
    if ! [[ "$commit_message" =~ ^[^[:space:]]+: ]]; then
        ((skipped_commit_count++))
        if $show_skipped_commits; then
            author=$(echo "$commit_info" | awk -F ' :: ' '{print $2}')
            commit_hash=$(echo "$commit_info" | awk -F ' :: ' '{print $4}')

            skipped_commits_info+=("$commit_hash on $commit_date by $author '$commit_message'")
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

    # Increment the periodic count for the prefix
    if [ "$by_option" == "none" ]; then
        continue
    fi

    # date_format has been set before
    period=$(date -j -f "%Y-%m-%d" "$commit_date" +"$date_format")

    # Increment the count of commits for the period
    ((period_commit_counts["$period"]++))

    if ! [[ " ${periods[@]} " =~ " ${period} " ]]; then
        periods+=("$period")
    fi
    for i in "${!prefixes[@]}"; do
        if [ "${prefixes[$i]}" == "$commit_message_prefix" ]; then
            index="${prefixes[$i]},${period}"
            if [ -z "${periodic_prefix_counts[$index]}" ]; then
                periodic_prefix_counts[$index]=0
            fi
            ((periodic_prefix_counts["$index"]++))
            break
        fi
    done
done <<< "$commit_messages"

# Calculate the total number of commits excluding skipped ones
conventional_commit_count=$((author_commit_count - skipped_commit_count))

# Print the total number of commits
if [ -n "$author_name" ]; then
    echo "Total number of commits by $author_name in repository '$repository': $author_commit_count"
else
    echo "Total number of commits in repository '$repository': $author_commit_count"
fi

echo "Skipped non-conventional commits: $skipped_commit_count"
# Print skipped commits info if --show-skipped-commits is set
if $show_skipped_commits; then
    for commit_info in "${skipped_commits_info[@]}"; do
        echo "$commit_info"
    done
fi

echo "Conventional commits: $conventional_commit_count"

column_width=8

# Sort periods in chronological order
periods_sorted=($(printf "%s\n" "${periods[@]}" | sort))

# Print the table headers
header_line=$(printf "| %-*s | %-*s |" "$column_width" "Type" "$column_width" "Total")

if [ "$by_option" != "none" ]; then
    for period in "${periods_sorted[@]}"; do
        header_line+=$(printf " %-*s |" "$column_width" "$period")
    done
fi

printf "\n%s\n" "$header_line"

# Print the table separator
print_separator_row $(( ${#periods_sorted[@]} + 2 )) $column_width

table_rows=()
for i in "${!prefixes[@]}"; do

    # Iterate over the prefixes and calculate the percentage of commits
    prefix_percentage=$(calculate_percentage "${prefix_counts[$i]}" "$conventional_commit_count")
    line=$(printf "| %-*s | %-*s |" "$column_width" "${prefixes[$i]}" "$column_width" "$prefix_percentage")

    # Add periods if necessary
    if [ "$by_option" != "none" ]; then
        for period in "${periods_sorted[@]}"; do
            index="${prefixes[$i]},${period}"
            period_count=${periodic_prefix_counts["$index"]}

            if [ -z "$period_count" ]; then
                line+=$(printf " %-*s |" "$column_width" "0%")
                continue
            fi

            period_percentage=$(calculate_percentage "$period_count" "${period_commit_counts["$period"]}")
            line+=$(printf " %-*s |" "$column_width" "$period_percentage")
        done
    fi

    table_rows+=("$line")
done

# Sort the formatted lines by the percentage field (second column)
sorted_table_rows=$(sort_by_percentages_and_prefixes "${table_rows[@]}")

# Print the sorted lines
printf "%s\n\n" "$sorted_table_rows"

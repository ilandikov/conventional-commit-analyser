#!/opt/homebrew/bin/bash

source ./calculate_percentage.sh
source ./mdtable_utils.sh

# Default values
declare -a repository_paths
author_name=""
show_skipped_commits=false
by_option="none"
count_commit_days=false
enable_risk_analysis=false

print_error_and_usage_and_abort() {
    echo "$1" 
    echo "Usage: $0 --path <path1> [--path <path2> ...] [--author <author>] [--show-skipped-commits] [--by <period>] [--commit-days] [--risk]"
    exit 1
}

parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --path)
            repository_paths+=("$2")
            shift # past argument
            shift # past value
            ;;
            --author)
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
            --commit-days)
            count_commit_days=true
            shift # past argument
            ;;
            --risk)
            enable_risk_analysis=true
            shift
            ;;
            *)
            print_error_and_usage_and_abort "Unknown parameter passed: $1"
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
        print_error_and_usage_and_abort "Error: Unsupported value for --by. Only 'year', 'month' and 'week' are supported."
    esac

    # Check if at least one repository path is provided
    if [ ${#repository_paths[@]} -eq 0 ]; then
        print_error_and_usage_and_abort "Error: Please provide at least one repository path using --path."
    fi

    for repo in "${repository_paths[@]}"; do
        if [ ! -d "$repo" ]; then
            echo "Error: The specified repository '$repo' does not exist."
            exit 1
        fi
    done
}

parse_args "$@"

# Initialize commit messages storage
commit_messages=""
declare -A unique_commit_days

read_repo_data() {
    for repo in "${repository_paths[@]}"; do
        if [ -n "$author_name" ]; then
            repo_commits=$(git -C "$repo" log --pretty="%s :: %an :: %ad :: %h" --date=short --author="$author_name")
            commit_dates=$(git -C "$repo" log --format=%ad --date=short --author="$author_name")
        else
            repo_commits=$(git -C "$repo" log --pretty="%s :: %an :: %ad :: %h" --date=short)
            commit_dates=$(git -C "$repo" log --format=%ad --date=short)
        fi

        if [ -n "$repo_commits" ]; then
            commit_messages+=$'\n'"$repo_commits"
        fi

        if [ "$count_commit_days" = true ]; then
            while IFS= read -r date; do
                unique_commit_days["$date"]=1
            done <<< "$commit_dates"
        fi
    done
}

read_repo_data

# Check if commit messages exist
if [ -z "$commit_messages" ]; then
    if [ -n "$author_name" ]; then
        echo "No commits made by '$author_name' across the provided repositories."
        exit 0
    fi
    echo "No commits found across the provided repositories."
    exit 0
fi

if [ "$count_commit_days" = true ]; then
    echo "Days with commits: ${#unique_commit_days[@]}."
    echo
fi

# Trim leading newlines
commit_messages=$(echo "$commit_messages" | sed '/^$/d')

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

# Initialize array to store risk
declare -A risk_counts
total_risk_commits=0

# Iterate over each line in the log output
while IFS= read -r commit_info; do
    # Increment the total count of commits by the specified author
    ((author_commit_count++))

    # Extract commit message, author name, date, and short hash
    commit_message=$(echo "$commit_info" | awk -F ' :: ' '{print $1}')
    commit_date=$(echo "$commit_info" | awk -F ' :: ' '{print $3}')
    author=$(echo "$commit_info" | awk -F ' :: ' '{print $2}')
    commit_hash=$(echo "$commit_info" | awk -F ' :: ' '{print $4}')

    # Check if the commit message contains the commit type, optional scope in parentheses and
    # optional exclamation marks (any number) before the colon
    if ! [[ "$commit_message" =~ ^[0-9A-Za-z]+(\([^\)]*\))?(!+)?: ]]; then
        ((skipped_commit_count++))
        if $show_skipped_commits; then
            author=$(echo "$commit_info" | awk -F ' :: ' '{print $2}')
            commit_hash=$(echo "$commit_info" | awk -F ' :: ' '{print $4}')

            skipped_commits_info+=("$commit_hash on $commit_date by $author '$commit_message'")
        fi
        continue
    fi

    # Extract the commit type from the commit message
    commit_message_prefix=$(echo "$commit_message" | grep -oE '^[0-9A-Za-z]+')

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

    if $enable_risk_analysis; then
        rest=$(echo "$commit_message" | cut -d ":" -f2- | sed 's/^ *//')
        risk=$(echo "$rest" | grep -o '^[^[:alnum:][:space:]]\{1,2\}')
        if [ -n "$risk" ]; then
            ((risk_counts["$risk"]++))
            ((total_risk_commits++))
        fi
    fi

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

# Sort periods in chronological order
periods_sorted=($(printf "%s\n" "${periods[@]}" | sort))

# Print the total number of commits
conventional_commit_count=$((author_commit_count - skipped_commit_count))
if [ -n "$author_name" ]; then
    echo "Total number of commits by $author_name in repositories: $author_commit_count"
else
    echo "Total number of commits in repositories: $author_commit_count"
fi
echo "Conventional commits: $conventional_commit_count"

# Print skipped commits info if --show-skipped-commits is set
if $show_skipped_commits; then
    echo
    echo "Skipped non-conventional commits: $skipped_commit_count"
    for commit_info in "${skipped_commits_info[@]}"; do
        echo "$commit_info"
    done
fi

column_width=9

print_header_line $column_width $by_option ${periods_sorted[@]}

print_separator_row $(( ${#periods_sorted[@]} + 2 )) $column_width

commits_row=$(printf "| %-*s | %-*s |" "$column_width" "Commits" "$column_width" "$conventional_commit_count")
if [ "$by_option" != "none" ]; then
    for period in "${periods_sorted[@]}"; do
        period_count=${period_commit_counts["$period"]}

        # If no commits for the period, print "0"
        if [ -z "$period_count" ]; then
            period_count=0
        fi

        commits_row+=$(printf " %-*s |" "$column_width" "$period_count")
    done
fi
echo "$commits_row"

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

if $enable_risk_analysis; then
    echo "Risk analysis:"
    echo "Conventional commits with risk notation: $total_risk_commits"
    echo
    printf "| %-*s | %-*s |\n" "$column_width" "Risk" "$column_width" "%"
    print_separator_row 2 $column_width

    risk_lines=()
    for risk in "${!risk_counts[@]}"; do
        percentage=$(calculate_percentage "${risk_counts[$risk]}" "$total_risk_commits")
        line=$(printf "| %-*s | %-*s |" "$column_width" "$risk" "$column_width" "$percentage")
        # Save percentage as a sortable number and the full line
        numeric_value=$(echo "$percentage" | tr -d '%')
        risk_lines+=("$numeric_value::$line")
    done

    # Sort by numeric value descending and print
    sorted_risk_lines=$(printf "%s\n" "${risk_lines[@]}" | sort -t ':' -k1,1nr | cut -d ':' -f3-)

    printf "%s\n" "$sorted_risk_lines"
    echo
fi

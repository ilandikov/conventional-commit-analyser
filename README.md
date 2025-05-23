# conventional-commit-analyser

A bash script for simple analysis of [Conventional Commits](https://www.conventionalcommits.org/).

The script ignores the *scope* part (the text in parentheses) and the *breaking change* marker (`!`) in conventional commit messages. For example, all of the following will be counted as `test`:

- `test: ...`
- `test(ui): ...`
- `test(api)!: ...`
- `test!: ...`
- `test(ui)!!: ...`

Note: Conventional Commits talks about only one `!` character, but this script accepts any number of those.

## The purpose

[Conventional Commits](https://www.conventionalcommits.org/) is a powerful tool to control commits' contents. Once that is under control it could be a good idea to analyse what one was/is actually working on.

This is why this script was created.

Sample output:

```terminal./conventional-commit-analyser.sh --path ../obsidian-tasks --author "Ilyas Landikov" --by year --commit-days --risk
Days with commits: 166.

Total number of commits by Ilyas Landikov in repositories: 1539
Conventional commits: 1530

| Type      | Total     | 2022      | 2023      | 2024      | 2025      |
| --------- | --------- | --------- | --------- | --------- | --------- |
| Commits   | 1530      | 1         | 577       | 837       | 115       |
| refactor  | 62%       | 0%        | 58%       | 67%       | 51%       |
| test      | 24%       | 0%        | 25%       | 22%       | 33%       |
| feat      | 4%        | 100%      | 6%        | 3%        | 5%        |
| fix       | 3%        | 0%        | 3%        | 3%        | 5%        |
| jsdoc     | 2%        | 0%        | 3%        | 2%        | 1%        |
| chore     | 1%        | 0%        | <1%       | 1%        | 0%        |
| docs      | 1%        | 0%        | 3%        | 0%        | 3%        |
| style     | 1%        | 0%        | 2%        | 0%        | 0%        |
| vault     | 1%        | 0%        | <1%       | 1%        | 1%        |
| comment   | <1%       | 0%        | <1%       | 1%        | 1%        |
| contrib   | <1%       | 0%        | 0%        | <1%       | 0%        |
| doc       | <1%       | 0%        | 1%        | 0%        | 0%        |
| tests     | <1%       | 0%        | <1%       | 0%        | 0%        |

Risk analysis:
Conventional commits with risk notation: 1295

| Risk      | %         |
| --------- | --------- |
| -         | 44%       |
| .         | 42%       |
| !         | 14%       |
| @         | <1%       |
| **        | <1%       |
```

Here we can guess that I'm working a lot of refactorings and rather avoid documentation =)

## Way of use

Try using this to compare your current self to your previous self. For example, save the analysis results today and see the difference in a month or two. What has changed? Are going more towards "test" or "feat"?

Usage:

```terminal
./conventional-commit-analyser.sh --path <path1> [--path <path2> ...] [--author <author>] [--show-skipped-commits] [--by <period>] [--commit-days] [--risk]
```

### `--path`

There can be any number of --path parameters. The commits will be analysed as if they were in one repository.

### `--by week/month/year`

This is the most important option as it may show you not just the current state of commits but the evolution of proprtions over time.

Above you may see the example with years. Weeks and months are also available.

If during a period (week/month/year) there has been no commits, that period will be skipped in the table.

### `--author <author>`

Add this if you wish to filter commits by author's name. For example `--author "Foo Bar"`.

### `--show-skipped-commits`

The script will analyse only conventional commits - commits with message starting with several non-space characters and a column. If you see lots of skipped commits, add this option to see what has been skipped.

### `--commit-days`

Show the total number of unique days when a commit happened. When analysing two repositories, if commits happeneds on the same day, it will be counted as 1 commit day.

### `--risk`

This option analyzes the risks associated with commits if they were notated in the commit messages as `<type>: <risk> <description>`, where `<rish>` is 1 or 2 non-alphanumeric characters: `.`, `-`, `**`, etc.

When this option is enabled, there will be an additional output like this:

```terminal
Risk analysis:
Conventional commits with risk notation: 6

| Risk      | %         |
| --------- | --------- |
| **        | 33%       |
| -         | 17%       |
| !         | 17%       |
| .         | 17%       |
| @         | 17%       |
```

## Important limitations

### Time & effort

This tool analyses only the number of commits. It is not analysing the time spent on writing them nor the effort.

### Comparison with others

If John has more "fix" commits than Bob, it is not necessarily true that Jonh fixed more bugs than Bob. So refrain to use this to see who works more or less. Although, the different areas where Bob and John are working may be easily highlighted.

### Percentages

Due to rounding the numbers, the sum percentages may differ from 100% =) The important thing is the ratio between the commits one does, not the mathematical accuracy here.

## Thanks

Many thanks to [Clare Macrae](https://github.com/claremacrae) who taught me the [Conventional Commits](https://www.conventionalcommits.org/) among other things while working on [obsidian-tasks](https://github.com/obsidian-tasks-group/obsidian-tasks) plugin.

# conventional-commit-analyser

A bash script for simple analysis of [Conventional Commits](https://www.conventionalcommits.org/).

## The purpose

[Conventional Commits](https://www.conventionalcommits.org/) is a powerful tool to control commits' contents. Once that is under control it could be a good idea to analyse what one was/is actually working on.

This is why this script was created.

Sample output:

```terminal
./conventional-commit-analyser.sh --path ../obsidian-tasks --author-name "Ilyas Landikov" --by year
Total number of commits by Ilyas Landikov in repository '../obsidian-tasks': 1063
Conventional commits: 1054

| Type     | Total    | 2022     | 2023     | 2024     |
| -------- | -------- | -------- | -------- | -------- |
| refactor | 61%      | 0%       | 58%      | 65%      |
| test     | 24%      | 0%       | 25%      | 23%      |
| feat     | 5%       | 100%     | 6%       | 4%       |
| jsdoc    | 3%       | 0%       | 3%       | 2%       |
| fix      | 2%       | 0%       | 3%       | 2%       |
| chore    | 1%       | 0%       | <1%      | 2%       |
| docs     | 1%       | 0%       | 3%       | 0%       |
| style    | 1%       | 0%       | 2%       | 0%       |
| vault    | 1%       | 0%       | <1%      | 1%       |
| comment  | <1%      | 0%       | <1%      | 1%       |
| doc      | <1%      | 0%       | 1%       | 0%       |
| fix!!    | <1%      | 0%       | <1%      | 0%       |
| tests    | <1%      | 0%       | <1%      | 0%       |

```

Here we can guess that I'm working a lot of refactorings and rather avoid documentation =)

## Way of use

Try using this to compare your current self to your previous self. For example, save the analysis results today and see the difference in a month or two. What has changed? Are going more towards "test" or "feat"?

Sample usage:

```terminal
./conventional-commit-analyser.sh --path <path> [--author-name <author>] [--show-skipped-commits]
```

### `--by week/month/year`

This is the most important option as it may show you not just the current state of commits but the evolution of proprtions over time.

Above you may see the example with years. Weeks and months are also available.

If during a period (week/month/year) there has been no commits, that period will be skipped in the table.

### `--author-name <author>`

Add this if you wish to filter commits by author's name. For example `--author-name "Foo Bar"`.

### `--show-skipped-commits`

The script will analyse only conventional commits - commits with message starting with several non-space characters and a column. If you see lots of skipped commits, add this option to see what has been skipped.

## Important limitations

### Time & effort

This tool analyses only the number of commits. It is not analysing the time spent on writing them nor the effort.

### Comparison with others

If John has more "fix" commits than Bob, it is not necessarily true that Jonh fixed more bugs than Bob. So refrain to use this to see who works more or less. Although, the different areas where Bob and John are working may be easily highlighted.

### Percentages

Due to rounding the numbers, the sum percentages may differ from 100% =) The important thing is the ratio between the commits one does, not the mathematical accuracy here.

## Thanks

Many thanks to [Clare Macrae](https://github.com/claremacrae) who taught me the [Conventional Commits](https://www.conventionalcommits.org/) among other things while working on [obsidian-tasks](https://github.com/obsidian-tasks-group/obsidian-tasks) plugin.

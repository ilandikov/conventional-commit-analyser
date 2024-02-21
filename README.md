# conventional-commit-analyser

A bash script for simple analysis of [Conventional Commits](https://www.conventionalcommits.org/).

## The purpose

[Conventional Commits](https://www.conventionalcommits.org/) is a powerful tool to control commits' contents. Once that is under control it could be a good idea to analyse what one was/is actually working on.

This is why this script was created.

Sample output:

```
Total number of commits by Ilyas Landikov: 662
Filtered commits: 1 filtered commits
Analyzed commits: 661
59%: 'refactor'
25%: 'test'
5%: 'feat'
4%: 'jsdoc'
2%: 'fix'
2%: 'docs'
1%: 'style'
1%: 'doc'
<1%: 'vault'
<1%: 'tests'
<1%: 'fix!!'
<1%: 'comment'
<1%: 'chore'
<1%: 'Revert'
<1%: 'Rename'
```

Here we can guess that I'm working a lot of refactorings and rather avoid documentation =)

## Way of use

Try using this to compare your current self to your previous self. For example, save the analysis results today and see the difference in a month or two. What has changed? Are going more towards "test" or "feat"?

Sample usage:

```
./convetional-commit-analyser.sh /path/to/your/repo
```

> The script is compatible with bash v3 only.

## Important limitations

### Time & effort

This tool analyses only the number of commits. It is not analysing the time spent on writing them nor the effort.

### Comparison with others

If John has more "fix" commits than Bob, it is not necessarily true that Jonh fixed more bugs than Bob. So refrain to use this to see who works more or less. Although, the different areas where Bob and John are working may be easily highlighted.

## Thanks

Many thanks to [Clare Macrae](https://github.com/claremacrae) who taught me the [Conventional Commits](https://www.conventionalcommits.org/) among other things while working on [obsidian-tasks](https://github.com/obsidian-tasks-group/obsidian-tasks) plugin.

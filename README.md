# conventional-commit-analyser

A bash script for simple analysis of [Conventional Commits](https://www.conventionalcommits.org/).

## The purpose

[Conventional Commits](https://www.conventionalcommits.org/) is a powerful tool to control commits' contents. Once that is under control it could be a good idea to analyse what one was/is actually working on.

This is why this script was created.

Sample output:

```terminal
./conventional-commit-analyser.sh --repository ../obsidian-tasks --author-name "Ilyas Landikov"

Total number of commits by Ilyas Landikov in repository '../obsidian-tasks': 1063
Skipped non-conventional commits: 9
Conventional commits: 1054
61%: refactor
24%: test
5%: feat
3%: jsdoc
2%: fix
1%: vault
1%: style
1%: docs
1%: chore
<1%: tests
<1%: fix!!
<1%: doc
<1%: comment
```

Here we can guess that I'm working a lot of refactorings and rather avoid documentation =)

## Way of use

Try using this to compare your current self to your previous self. For example, save the analysis results today and see the difference in a month or two. What has changed? Are going more towards "test" or "feat"?

Sample usage:

```terminal
./conventional-commit-analyser.sh --repository <path> [--author-name <author>] [--show-skipped-commits]
```

### `--author-name <author>`

Add this if you wish to filter commits by author's name. For example `--author-name "Foo Bar"`.

### `--show-skipped-commits`

The script will analyse only conventional commits - commits with message starting with several non-space characters and a column. If you see lots of skipped commits, add this option to see what has been skipped.

## Important limitations

### Time & effort

This tool analyses only the number of commits. It is not analysing the time spent on writing them nor the effort.

### Comparison with others

If John has more "fix" commits than Bob, it is not necessarily true that Jonh fixed more bugs than Bob. So refrain to use this to see who works more or less. Although, the different areas where Bob and John are working may be easily highlighted.

## Thanks

Many thanks to [Clare Macrae](https://github.com/claremacrae) who taught me the [Conventional Commits](https://www.conventionalcommits.org/) among other things while working on [obsidian-tasks](https://github.com/obsidian-tasks-group/obsidian-tasks) plugin.

# gh-read and Plannotator

`gh_read` is model-facing: it gives the agent GitHub PR/issue text and optional diffs in context.

Plannotator is human-facing: `/plannotator-review <PR URL>` opens the browser review UI and fetches the PR itself.

They complement each other, but `gh_read` does not directly invoke Plannotator.

# openglad-screenshots

Screenshots, GIFs, and other proof media referenced by
[openglad](https://github.com/openglad/openglad) pull requests and issues.
This repo exists so the main repo's history stays free of binary media.

## Layout

- `pr-<number>/` — media for one main-repo PR (preferred for new work)
- `<feature>/` — legacy per-feature directories migrated from the main
  repo's old `docs/media/` (`company-basecamp/`, `lua-classpacks/`,
  `team-selection/`)

## Usage

Push media here first, then embed it in the PR body with a raw URL pinned
to a commit SHA (so later cleanups can never break the embed):

```
https://raw.githubusercontent.com/openglad/openglad-screenshots/<commit-sha>/pr-123/before.png
```

`main` branch URLs also work but break if files move; prefer the SHA form.

The capture tooling lives in the main repo (`scripts/media/`,
`openglad_demo`); it writes to `build/media/` there, and finished artifacts
get committed here.

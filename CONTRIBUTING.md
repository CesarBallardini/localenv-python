# Contributing

Thanks for taking a look. This repository is a tooling scaffold, so the bar it
holds itself to is the point of it — the gates below are not bureaucracy, they
are the thing being demonstrated.

## Getting set up

```bash
git clone https://github.com/CesarBallardini/localenv-python
cd localenv-python
make install
```

`make install` syncs the environment from the committed `uv.lock` and installs
the git hooks: `pre-commit`, `commit-msg` and `pre-push`. Run `make` with no
target to list everything available.

## The workflow

1. **Branch.** Commits to `main` are blocked by a hook on purpose, and a
   ruleset on GitHub blocks direct pushes; work lands through a pull request
   so the CI, coverage and security gates get a chance to run first. Name the
   branch `<type>/<slug>`, where `<type>` is the
   Conventional Commits type of the work — `fix/gitleaks-scan-scope`,
   `feat/quality-gates`. A `pre-push` hook enforces this.
2. **Commit.** Messages follow
   [Conventional Commits](https://www.conventionalcommits.org/) — `feat:`,
   `fix:`, `docs:`, `build:`, `chore:`, `refactor:`, `test:`, `ci:`. The `commit-msg`
   hook checks this locally, and CI checks the pull request title, because a
   squash merge takes the title as the commit subject.
3. **Check locally** before pushing:

   ```bash
   make qa
   ```

4. **Open the pull request.** Give it a Conventional Commits title — that is
   what determines the next version number.

   Set the title *deliberately*; do not accept the one GitHub proposes. When a
   branch has more than one commit, GitHub defaults the title to the humanised
   branch name (`fix/gitleaks-scan-scope` becomes `Fix/gitleaks scan scope`),
   which drops the colon and fails `validate-pr-title`. The `pre-push` hook
   warns about this and suggests a starting point.

## What has to pass

Every one of these fails the build rather than printing a warning:

| Gate | Command |
| --- | --- |
| Lint and format | `make lint` |
| Types (pyright + pyrefly) | `make types` |
| Tests | `make test` |
| Coverage, 90% floor | `make coverage` |
| SAST, CVEs, secrets, licenses | `make security` |
| Docs build, warnings are failures | `make docs` |
| Lint, types, coverage, security and docs together | `make qa` |
| Every hook at once, from a branch | `make precommit` |
| Fuzzing, Linux x86_64 only | `make fuzz` |
| The devcontainer image builds and passes the tests | CI only (`devcontainer.yml`) |

CI runs the *same* pre-commit hooks you do (`pre-commit run --all-files`), so
a green local run and a green CI run cannot drift apart. The only one it skips
is `no-commit-to-branch`, because a build has `main` checked out.

The ruleset on `main` requires these checks before a pull request can merge:
`check`, `docs`, `pytest`, `security`, `licenses`, `gitleaks`,
`osv-scanner / osv-scan`, `validate-pr-title` and `devcontainer`. It requires
no approvals, and nobody can bypass it. `fuzz` runs on every pull request but
is not required.

### About the coverage floor

`.coveragerc` sets `fail_under = 90`. If a change drops coverage below that,
the honest fix is a test, not a lower threshold. If you genuinely believe the
floor is wrong, say so in the pull request and change it as its own commit, so
the decision is visible in the history.

## Releasing

There is no version number in a tracked file. `uv-dynamic-versioning` derives
the package version from the newest git tag, and the `release` workflow
(manual dispatch) uses `cz bump` to work out the next tag from the commit
history. Releasing is therefore just: merge, then run the workflow.

## Reporting a security issue

Please do not open a public issue — see [SECURITY.md](SECURITY.md).

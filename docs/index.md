# localenv-python

Tooling scaffold for a Python backend: linting, type checking, tests organised
by kind, and security, all wired up from the first commit — so "it's clean" is
what happens by default, rather than something someone has to remember to run
by hand.

## The quality gates

Every one of these fails the build rather than printing a warning:

| Gate | Tool | Config |
| --- | --- | --- |
| Lint and format | ruff | `ruff.toml` |
| Types | pyright + pyrefly | `pyrightconfig.json`, `pyrefly.toml` |
| Tests | pytest | `pyproject.toml` |
| Coverage floor (90%) | coverage | `.coveragerc` |
| SAST | bandit | `bandit.yaml` |
| Dependency CVEs | pip-audit + OSV-Scanner | `uv.lock` |
| Secrets | gitleaks | `.gitleaks.toml` |
| Licenses | pip-licenses | `.github/workflows/security.yml` |
| Fuzzing | Atheris | `fuzz/fuzz_tasks.py` |
| Docs | MkDocs, `--strict` | `mkdocs.yml` |
| Devcontainer image | Docker | `Dockerfile` |
| Commit messages | commitizen | `pyproject.toml` |

On GitHub, a ruleset on `main` requires a pull request and these checks before
a change can merge.

## Getting started

```bash
git clone https://github.com/CesarBallardini/localenv-python
cd localenv-python
make install
make test
make qa
```

`make qa` runs lint, types, tests with coverage, security and the docs build. It
needs OSV-Scanner and gitleaks on `PATH`. Everything else goes through the
`Makefile` — run `make` with no target to list what is available.

## Where the version comes from

There is no version number in a tracked file. `uv-dynamic-versioning` derives
it from the newest git tag, and the `release` workflow creates that tag, with
`cz bump` working out the next version, so the wheel and the release can never
disagree.

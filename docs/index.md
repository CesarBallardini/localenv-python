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
| Secrets | gitleaks | `.pre-commit-config.yaml` |
| Licenses | pip-licenses | `.github/workflows/security.yml` |
| Commit messages | commitizen | `pyproject.toml` |

## Getting started

```bash
git clone https://github.com/CesarBallardini/localenv-python
cd localenv-python
make install
```

Everything else goes through the `Makefile` — run `make` with no target to list
what is available.

## Where the version comes from

There is no version number in a tracked file. `uv-dynamic-versioning` derives
it from the newest git tag, and `cz bump` creates that tag, so the wheel and
the release can never disagree.

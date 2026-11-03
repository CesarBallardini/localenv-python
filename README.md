# README - localenv-python

<!-- markdown-link-check-disable -->
[![check](https://github.com/CesarBallardini/localenv-python/actions/workflows/check.yml/badge.svg)](https://github.com/CesarBallardini/localenv-python/actions/workflows/check.yml)
[![pytest](https://github.com/CesarBallardini/localenv-python/actions/workflows/pytest.yml/badge.svg)](https://github.com/CesarBallardini/localenv-python/actions/workflows/pytest.yml)
[![security](https://github.com/CesarBallardini/localenv-python/actions/workflows/security.yml/badge.svg)](https://github.com/CesarBallardini/localenv-python/actions/workflows/security.yml)
[![devcontainer](https://github.com/CesarBallardini/localenv-python/actions/workflows/devcontainer.yml/badge.svg)](https://github.com/CesarBallardini/localenv-python/actions/workflows/devcontainer.yml)
[![fuzz](https://github.com/CesarBallardini/localenv-python/actions/workflows/fuzz.yml/badge.svg)](https://github.com/CesarBallardini/localenv-python/actions/workflows/fuzz.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/CesarBallardini/localenv-python/badge)](https://scorecard.dev/viewer/?uri=github.com/CesarBallardini/localenv-python)
<!-- markdown-link-check-enable -->

Tooling scaffold for a Python backend: linting, type checking, tests organized by kind, and security, all wired up from the first commit — so "it's clean" is what happens by default, not something someone has to remember to run by hand.

This is the companion repo for the post [El tooling de un backend Python en serio, antes de escribir la primera ruta](https://katra.ballardini.com.ar/posts/python-tooling-backend-desde-cero/) — everything here is generic and reusable, not any client's code.

# Quick start

1. Install the [prerequisites](#prerequisites): uv, Git and Make for everything, plus OSV-Scanner and gitleaks for `make qa`.

2. Clone the repository:

   ```bash
   git clone https://github.com/CesarBallardini/localenv-python
   cd localenv-python
   ```

3. Install the environment from the committed lockfile, and the git hooks:

   ```bash
   make install
   ```

4. Run the tests:

   ```bash
   make test
   ```

5. Run the quality gates: lint, types, tests with coverage, security and docs.

   ```bash
   make qa
   ```

   CI also runs the pre-commit hooks. To run them locally, create a branch first and use `make precommit`, because one of the hooks fails on `main` on purpose.

6. List every other target:

   ```bash
   make
   ```

# What's in here

* **[uv](https://docs.astral.sh/uv/)** for dependency and environment management, with separate groups (`dev`, `deploy`, `doc` and `fuzz`).
* **[ruff](https://docs.astral.sh/ruff/)** as linter and formatter (`ruff.toml`).
* **[pyright](https://microsoft.github.io/pyright/)** + **[pyrefly](https://pyrefly.org/)** as a pair of type checkers, run on purpose, not mid-migration (`pyrightconfig.json`, `pyrefly.toml`).
* **[bandit](https://bandit.readthedocs.io/)** (SAST), and **[pip-audit](https://pypi.org/project/pip-audit/)** + **[OSV-Scanner](https://google.github.io/osv-scanner/)** (SCA) against `uv.lock` for security (`bandit.yaml`). OSV-Scanner is a standalone Go binary, not a PyPI package, so it doesn't go through `uv` — locally it just needs to be on `PATH` (`choco install osv-scanner` on Windows), in CI it runs via Google's official reusable workflow (see `security.yml`).
* **[gitleaks](https://github.com/gitleaks/gitleaks)** for secret scanning, at both ends: a pre-commit hook so a key never reaches a commit, and a full working-tree scan in CI. `.gitleaks.toml` keeps the tree scan off `.venv/` and the other generated directories — 148 MB of vendored third-party code that yields hundreds of false positives and cannot leak anything of ours. Both ends are pinned to the same version on purpose — the hook only ever sees *staged* changes (`gitleaks git --pre-commit --staged`), which is a no-op on a CI checkout, so the CI job scans the tree instead.
* **[pytest](https://docs.pytest.org/)** with tests split by kind: `unit/`, `integration/`, `acceptance/` (BDD via [pytest-bdd](https://pytest-bdd.readthedocs.io/)), `e2e/` (via [pytest-playwright](https://playwright.dev/python/docs/test-runners)). Coverage is a **gate, not a report**: `.coveragerc` sets `fail_under = 90`, so `pytest --cov` exits non-zero below it and a coverage drop fails the build the same way a lint or type error does.
* **[pre-commit](https://pre-commit.com/)** hooking lint, format, lockfile, SAST, secret-scanning, link-checking and file-hygiene checks before every commit — and CI runs *the same hooks* via `pre-commit run --all-files`, so what passes locally and what passes in CI can't drift apart.
* **[Atheris](https://github.com/google/atheris)** for fuzzing: `fuzz/fuzz_tasks.py` runs random sequences of operations on the task list and checks them against a plain dict, for 60 seconds on every change and 10 minutes each week. Atheris only publishes Linux x86_64 wheels, so `make fuzz` needs the devcontainer on Windows and cannot run on arm64, and it is not part of `make qa`. `make install` leaves Atheris out, and `make fuzz` installs it. The fuzzer keeps useful inputs in `fuzz/corpus/`, cached between CI runs, and failing inputs in `fuzz/artifacts/`.
* **[pip-licenses](https://pypi.org/project/pip-licenses/)** for license compliance: the whole toolchain gets reported, but only the *distributed* dependency closure is gated — dev tooling never ships, so it cannot create an obligation.
* **[commitizen](https://commitizen-tools.github.io/commitizen/)** for [Conventional Commits](https://www.conventionalcommits.org/), checked on the commit message locally (`commit-msg` hook) and on the PR title in CI — a squash merge takes the title as the commit subject, so that is the one that lands.
* **[MkDocs](https://www.mkdocs.org/) + [Material](https://squidfunk.github.io/mkdocs-material/) + [mkdocstrings](https://mkdocstrings.github.io/) + [mike](https://github.com/jimporter/mike)** for the docs, built with `--strict` in CI (a dangling API reference fails the build) and published per release tag.
* A **devcontainer** (`.devcontainer/`, `Dockerfile`) and shared editor settings (`.vscode/settings.json`), so a fresh clone gets the same toolchain without a setup ritual.
* A `Makefile` as the single interface — nobody needs to memorize the exact command for each tool.
* Independent GitHub Actions workflows in `.github/workflows/`, one per concern, each with its own badge above: `check.yml` (pre-commit + pyright + pyrefly + the docs build), `pytest.yml` (with Postgres and Redis service containers, plus the coverage gate), `security.yml` (bandit + pip-audit + pip-licenses + gitleaks + OSV-Scanner), `devcontainer.yml` (builds the `Dockerfile` and runs the tests inside it), `fuzz.yml` (Atheris over the task list) and `scorecard.yaml` (OpenSSF Scorecard). Three more have no badge: `validate_pr_title.yaml` checks the PR title, `release.yaml` creates the version tag, and `docs.yaml` publishes the docs for that tag.
* A **ruleset on `main`**: no deletion or force push, every change lands through a pull request, and the CI checks must pass before it can merge. Nobody can bypass it. It requires no approvals, because a sole maintainer cannot approve their own pull requests.
* **Supply-chain hygiene in the workflows themselves**: every action pinned to a commit SHA with a `# vX.Y.Z` comment (a tag is mutable, a digest isn't), a default-deny `permissions: {}` at the top of each workflow with each job opting back into just what it needs, `concurrency` so a new push supersedes the run it replaced, and `timeout-minutes` on every job. The images in the `Dockerfile` are pinned by digest for the same reason. The shared setup lives in two composite actions (`.github/actions/install-uv`, `.github/actions/setup-python`) instead of being copy-pasted per workflow.
* **[Dependabot](https://docs.github.com/code-security/dependabot)** (`.github/dependabot.yml`) for `uv`, `github-actions`, `docker` and `pre-commit`, weekly. `uv`, the workflows' actions and `pre-commit` are each grouped into one PR, while the composite action and the Docker images get their own, and the Python image only takes patch releases. Dependabot security updates open fixes for known advisories. There is a 10-day `cooldown` so a compromised or yanked release isn't picked up the day it ships (commented out until 2026-11-13; see `SECURITY.md`).

# Prerequisites

* [uv](https://docs.astral.sh/uv/) 0.13.6 or newer (older releases still trust the compromised eMudhra certificates)
* Python 3.14.10 (uv installs it automatically if missing, per `.python-version`)
* Git
* Make (on Windows, `choco install make`)
* [OSV-Scanner](https://google.github.io/osv-scanner/) on `PATH` (only needed for `make security`/`make qa`; on Windows, `choco install osv-scanner`)
* [gitleaks](https://github.com/gitleaks/gitleaks) on `PATH` (only needed for `make secrets`/`make security`/`make qa`; on Windows, `choco install gitleaks`). The pre-commit hook installs its own copy, so committing works without this.

# Using this repository

After the [quick start](#quick-start), everything goes through the Makefile:

```bash
make                  # no target: lists all available targets
make qa               # lint + types + coverage + security + docs
make lint             # ruff check + ruff format --check
make format           # ruff format + ruff check --fix
make types            # pyright + pyrefly
make test             # pytest (unit + integration + acceptance, e2e excluded by default)
make test-bdd         # only the acceptance tests (pytest -m bdd)
make test-integration # only the integration tests (pytest -m integration)
make test-e2e         # pytest -m e2e (requires Playwright installed: uv run --frozen playwright install)
make coverage         # pytest with coverage, enforcing the 90% floor from .coveragerc
make fuzz             # Atheris over the task list, 60 seconds by default (Linux x86_64 only, so use the devcontainer on Windows)
make security         # every scan: bandit + pip-audit + osv-scanner + gitleaks + licenses
make secrets          # gitleaks over the working tree
make licenses         # license report, gating what actually ships
make docs             # mkdocs build --strict
make docs-serve       # mkdocs serve, with live reload
make release-next     # what version the next release would get (creates no tag)
make clean            # remove build, cache and coverage artifacts
make precommit        # run all pre-commit hooks by hand
```

# Structure

```
src/task_list/
  tasks.py               # example: in-memory task list, no DB
tests/
  unit/                  # no infrastructure, fast (test_tasks.py, test_certificate_floors.py)
  integration/            # need a real DB/service (placeholder, not used yet)
  acceptance/
    features/             # .feature files (Gherkin) -- task_list.feature
    steps/                 # pytest-bdd step definitions
  e2e/                    # against a running instance, via Playwright (placeholder)
fuzz/
  fuzz_tasks.py          # Atheris target: random operations, checked against a plain dict
docs/
  index.md               # docs landing page
  reference.md           # API reference, generated from docstrings by mkdocstrings
```

The real example is `tasks.py`: an in-memory task list (add, complete, remove), chosen on purpose because it needs no database or external adapter — enough to show unit tests and BDD (`tests/unit/test_tasks.py`, `tests/acceptance/features/task_list.feature`) without getting into infrastructure yet. `integration/` and `e2e/` stay as unused placeholders: that jump is exactly the topic of the series' second post (hexagonal architecture), where this same domain becomes a good candidate to split into a port + an adapter.

# Updating dependencies

By default, `uv run` and `uv sync` can re-resolve and rewrite `uv.lock` on their own if they detect `pyproject.toml` changed. That's fine for day-to-day use, but for any command that's meant to just *run* something (CI, onboarding, any given `make test`), it's worth pinning the lockfile to exactly what's committed, so a routine run doesn't end up touching `uv.lock` without anyone asking for it:

```bash
uv sync --frozen              # installs exactly what uv.lock says, resolves nothing
uv run --frozen pytest        # same idea, for any one-off command
```

The local pre-commit hook (`uv lock --check`) already fails if `uv.lock` drifts out of sync with `pyproject.toml` — so a `uv sync`/`uv run` without `--frozen` that accidentally rewrites the lock gets caught before the commit, not in CI.

To update dependencies **on purpose**, the flow is explicit, never implicit:

```bash
uv lock --upgrade-package ruff   # updates just that package to the max pyproject.toml allows
uv lock --upgrade                # updates everything pyproject.toml's constraints allow
```

Both commands rewrite `uv.lock` — review the diff (`git diff uv.lock`) before continuing. After updating, run the full suite before committing:

```bash
uv sync --all-groups   # installs whatever just landed in the updated lock
make qa
```

If an update breaks something, `uv lock --upgrade-package <package>` scoped to that one package makes it much easier to find which version was the culprit.

# Building a wheel

The installable package is `task_list` (`[project] name` and the importable package deliberately match, see `[tool.hatch.build.targets.wheel]` in `pyproject.toml`, with `hatchling` as build backend).

There is **no version number in a tracked file**. `uv-dynamic-versioning` derives it from the newest git tag, and the `release` workflow creates that tag, with `cz bump` working out the next version — so the wheel, the git tag and the published docs cannot disagree about what version this is. Before the first tag exists, builds come out as `0.0.0.post<N>.dev0+<sha>`.

To generate the wheel:

```bash
uv build
```

This leaves `dist/task_list-<version>-py3-none-any.whl` and the matching sdist, where `<version>` comes from the git tag. To test it installed in another environment:

```bash
uv pip install dist/task_list-*-py3-none-any.whl
python -c "from task_list.tasks import TaskList; print(TaskList().pending())"
```

The `py.typed` marker that ships in `src/task_list/` travels inside the wheel, so any project that installs this package and imports it also inherits its type hints instead of its type checker treating it as `Any`.

# Alternatives considered and not adopted

**[uv-secure](https://pypi.org/project/uv-secure/)** — scans `uv.lock` for known vulnerabilities, natively, with no intermediate `requirements.txt` export and some nice ergonomics (`ignore_unfixed`, severity columns, per-vulnerability ignores in `pyproject.toml`). It's a good tool and a natural fit for a uv-based project.

It's not here because its job is already covered twice over: **pip-audit** queries [PyPA's advisory database](https://github.com/pypa/advisory-database) plus OSV against the *installed* environment, and **OSV-Scanner** queries [OSV.dev](https://osv.dev/) against `uv.lock` directly — which is exactly uv-secure's scope, from the same upstream data source. Adding a third scanner over the same advisories would mean three tools to keep pinned and three sets of ignore-rules to keep in sync, in exchange for near-duplicate findings. The one thing it would genuinely add — vulnerability triage config living in `pyproject.toml` — isn't worth that yet at this size.

Worth revisiting if OSV-Scanner's Go binary ever becomes awkward to install in some environment: uv-secure is a PyPI package, so it would go through `uv` like everything else.

**[FOSSA](https://fossa.com/)** — license compliance and attribution reporting. Genuinely more capable than what's here: it resolves the full transitive license graph, handles dual-licensing properly, and produces attribution documents. It's also commercial, needs an API key in CI, and answers a question this repository doesn't have yet. **[pip-licenses](https://pypi.org/project/pip-licenses/)** covers the 80% that matters — it's in `security.yml` and in `make licenses`, reporting the whole toolchain and failing the build only on strong copyleft in the dependencies that actually ship.

**[nwa](https://github.com/B1NARY-GR0UP/nwa)** — inserts and verifies per-file copyright headers, with a CI job to check them. Deferred, not rejected: it earns its place under a file-level copyleft licence like MPL-2.0, where the header carries real legal weight per file. This project is MIT, where a single `LICENSE` at the root does the job, and per-file headers would be noise in every diff. Revisit if the licence changes or if files start being vendored out to other projects.

# What's missing (on purpose)

This repo is the "tooling" half of the diptych. The other half — how to organize code in layers (domain / application / adapters), hexagonal architecture, ports and adapters in Python — is the topic of the second post and doesn't have its own scaffold here yet.

# License

MIT — see [LICENSE](LICENSE).

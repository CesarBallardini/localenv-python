# README - localenv-python

Tooling scaffold for a Python backend: linting, type checking, tests organized by kind, and security, all wired up from the first commit — so "it's clean" is what happens by default, not something someone has to remember to run by hand.

This is the companion repo for the post [El tooling de un backend Python en serio, antes de escribir la primera ruta](https://katra.ballardini.com.ar/posts/python-tooling-backend-desde-cero/) — everything here is generic and reusable, not any client's code.

# What's in here

* **[uv](https://docs.astral.sh/uv/)** for dependency and environment management, with separate groups (`dev` vs `deploy`).
* **[ruff](https://docs.astral.sh/ruff/)** as linter and formatter (`ruff.toml`).
* **[pyright](https://microsoft.github.io/pyright/)** + **[pyrefly](https://pyrefly.org/)** as a pair of type checkers, run on purpose, not mid-migration (`pyrightconfig.json`, `pyrefly.toml`).
* **[bandit](https://bandit.readthedocs.io/)** (SAST) with a baseline, and **[pip-audit](https://pypi.org/project/pip-audit/)** (SCA) for security (`bandit.yaml`).
* **[pytest](https://docs.pytest.org/)** with tests split by kind: `unit/`, `integration/`, `acceptance/` (BDD via [pytest-bdd](https://pytest-bdd.readthedocs.io/)), `e2e/` (via [pytest-playwright](https://playwright.dev/python/docs/test-runners)).
* **[pre-commit](https://pre-commit.com/)** hooking lint, format, and lockfile checks before every commit.
* A `Makefile` as the single interface — nobody needs to memorize the exact command for each tool.
* A GitHub Actions workflow (`.github/workflows/ci.yml`) with jobs split by responsibility: `check` (lint + format + types), `pytest` (with Postgres and Redis service containers), `security` (bandit + pip-audit).

# Prerequisites

* [uv](https://docs.astral.sh/uv/) (verified with the latest stable release)
* Python 3.14 (uv installs it automatically if missing, per `.python-version`)
* Git

# Using this repository

Clone it:

```bash
git clone https://github.com/CesarBallardini/localenv-python
cd localenv-python
```

Install dependencies and the pre-commit hooks:

```bash
make install
```

From there, everything goes through the Makefile:

```bash
make                  # no target: lists all available targets
make lint             # ruff check + ruff format --check
make format           # ruff format + ruff check --fix
make types            # pyright + pyrefly
make test             # pytest (unit + integration + acceptance, e2e excluded by default)
make test-bdd         # only the acceptance tests (pytest -m bdd)
make test-integration # only the integration tests (pytest -m integration)
make test-e2e         # pytest -m e2e (requires Playwright installed: uv run --frozen playwright install)
make security         # bandit + pip-audit --skip-editable
make precommit        # run all pre-commit hooks by hand
```

# Structure

```
src/task_list/
  tasks.py               # example: in-memory task list, no DB
tests/
  unit/                  # no infrastructure, fast (test_tasks.py)
  integration/            # need a real DB/service (placeholder, not used yet)
  acceptance/
    features/             # .feature files (Gherkin) -- task_list.feature
    steps/                 # pytest-bdd step definitions
  e2e/                    # against a running instance, via Playwright (placeholder)
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
make lint types test security
```

If an update breaks something, `uv lock --upgrade-package <package>` scoped to that one package makes it much easier to find which version was the culprit.

# Building a wheel

The installable package is `task_list` (`[project] name` and the importable package deliberately match, see `[tool.hatch.build.targets.wheel]` in `pyproject.toml`, with `hatchling` as build backend). To generate the wheel:

```bash
uv build
```

This leaves `dist/task_list-0.1.0-py3-none-any.whl` and the matching sdist. To test it installed in another environment:

```bash
uv pip install dist/task_list-0.1.0-py3-none-any.whl
python -c "from task_list.tasks import TaskList; print(TaskList().pending())"
```

The `py.typed` marker that ships in `src/task_list/` travels inside the wheel, so any project that installs this package and imports it also inherits its type hints instead of its type checker treating it as `Any`.

# What's missing (on purpose)

This repo is the "tooling" half of the diptych. The other half — how to organize code in layers (domain / application / adapters), hexagonal architecture, ports and adapters in Python — is the topic of the second post and doesn't have its own scaffold here yet.

# License

MIT — see [LICENSE](LICENSE).

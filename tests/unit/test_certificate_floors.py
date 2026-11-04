"""Nothing here drops below the releases the eMudhra certificate advisory of 2026-10-20 names.

Eight intermediate CA keys are compromised, and these releases stop trusting them.
"""

import re
import sys
import tomllib
from pathlib import Path

import pytest

ROOT = Path(__file__).parents[2]
UV_FLOOR = '0.13.6'
DOTTED_VERSION = r'(\d+(?:\.\d+)*)'
INPUT_DEFAULT = rf'default: "{DOTTED_VERSION}"'
PYTHON_IMAGE = rf'^FROM python:{DOTTED_VERSION}-slim\b'
PYTHON_VERSION_FILE = rf'^{DOTTED_VERSION}$'
UV_PINS = {
    '.github/actions/install-uv/action.yaml': INPUT_DEFAULT,
    '.github/actions/setup-python/action.yaml': INPUT_DEFAULT,
    'Dockerfile': rf'ghcr\.io/astral-sh/uv:{DOTTED_VERSION}',
}
SCANNER_PINS = {
    'gitleaks': {
        '.github/workflows/security.yml': rf'GITLEAKS_VERSION: {DOTTED_VERSION}$',
        '.pre-commit-config.yaml': rf'gitleaks/gitleaks\n +rev: v{DOTTED_VERSION}$',
        'Dockerfile': rf'/gitleaks/v8@v{DOTTED_VERSION}$',
    },
    'osv-scanner': {
        '.github/workflows/security.yml': rf'osv-scanner-reusable\.yml@\w+ # v{DOTTED_VERSION}$',
        'Dockerfile': rf'/osv-scanner@v{DOTTED_VERSION}$',
    },
}
type Version = tuple[int, ...]


def version_of(text: str) -> Version:
    return tuple(int(part) for part in text.split('.'))


def locked_version(name: str) -> str:
    lock = tomllib.loads((ROOT / 'uv.lock').read_text(encoding='utf-8'))
    versions: list[str] = [package['version'] for package in lock['package'] if package['name'] == name]
    assert len(versions) == 1, f'{name} locked {len(versions)} times'
    return versions[0]


def only_match(relative_path: str, pattern: str) -> str:
    matches: list[str] = re.findall(pattern, (ROOT / relative_path).read_text(encoding='utf-8'), flags=re.MULTILINE)
    assert len(matches) == 1, f'{relative_path} matches {pattern!r} {len(matches)} times'
    return matches[0]


def uv_pins() -> dict[str, str]:
    return {relative_path: only_match(relative_path, pattern) for relative_path, pattern in UV_PINS.items()}


@pytest.mark.unit
@pytest.mark.parametrize(
    ('package', 'floor'),
    [('certifi', '2026.10.19'), ('pip', '26.2.2'), ('virtualenv', '21.14.12')],
)
def test_the_lockfile_stays_at_or_above_the_floor(package: str, floor: str) -> None:
    assert version_of(locked_version(package)) >= version_of(floor)


@pytest.mark.unit
def test_every_uv_pin_moves_together() -> None:
    assert len(set(uv_pins().values())) == 1, uv_pins()


@pytest.mark.unit
@pytest.mark.parametrize('pins', SCANNER_PINS.values(), ids=SCANNER_PINS)
def test_every_scanner_pin_moves_together(pins: dict[str, str]) -> None:
    versions = {relative_path: only_match(relative_path, pattern) for relative_path, pattern in pins.items()}
    assert len(set(versions.values())) == 1, versions


@pytest.mark.unit
def test_the_devcontainer_runs_the_python_that_python_version_names() -> None:
    assert only_match('Dockerfile', PYTHON_IMAGE) == only_match('.python-version', PYTHON_VERSION_FILE)


@pytest.mark.unit
def test_uv_stays_at_or_above_the_floor() -> None:
    assert all(version_of(pin) >= version_of(UV_FLOOR) for pin in uv_pins().values()), uv_pins()


@pytest.mark.unit
@pytest.mark.parametrize(
    ('relative_path', 'pattern', 'floor'),
    [
        ('Dockerfile', PYTHON_IMAGE, '3.14.10'),
        ('Dockerfile', rf'^FROM node:{DOTTED_VERSION}-slim\b', '24.22.2'),
        ('Dockerfile', rf'^FROM golang:{DOTTED_VERSION}-alpine\b', '1.27.3'),
        # A bare `3.14` fails here too, as it should: uv would take any older 3.14 it finds, as it did on the runner.
        ('.python-version', PYTHON_VERSION_FILE, '3.14.10'),
        ('.pre-commit-config.yaml', rf'id: gitleaks\n.*\n +language_version: {DOTTED_VERSION}$', '1.27.3'),
        ('.pre-commit-config.yaml', rf'id: markdown-link-check\n.*\n +language_version: {DOTTED_VERSION}$', '24.22.2'),
    ],
)
def test_the_other_pins_stay_at_or_above_the_floor(relative_path: str, pattern: str, floor: str) -> None:
    assert version_of(only_match(relative_path, pattern)) >= version_of(floor)


@pytest.mark.unit
def test_the_running_python_rejects_the_compromised_intermediates() -> None:
    assert sys.version_info >= (3, 14, 10), 'run `uv python install 3.14.10`, then recreate .venv with `make install`'

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
UV_PINS = {
    '.github/actions/install-uv/action.yaml': INPUT_DEFAULT,
    '.github/actions/setup-python/action.yaml': INPUT_DEFAULT,
    'Dockerfile': rf'ghcr\.io/astral-sh/uv:{DOTTED_VERSION}',
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
def test_uv_stays_at_or_above_the_floor() -> None:
    assert all(version_of(pin) >= version_of(UV_FLOOR) for pin in uv_pins().values()), uv_pins()


@pytest.mark.unit
def test_the_python_image_stays_at_or_above_the_floor() -> None:
    tag = only_match('Dockerfile', rf'^FROM python:{DOTTED_VERSION}-slim\b')
    assert version_of(tag) >= version_of('3.14.10')


@pytest.mark.unit
def test_the_running_python_rejects_the_compromised_intermediates() -> None:
    assert sys.version_info >= (3, 14, 10), 'run `uv python install 3.14.10`, then recreate .venv with `make install`'

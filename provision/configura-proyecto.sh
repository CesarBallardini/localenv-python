#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

export PROJECT_DIR=/vagrant/proyecto
export MY_PYTHON_VERSION=3.10.2


make_project_dir() {
  mkdir "${PROJECT_DIR}"
  cd "${PROJECT_DIR}"
}


config_gitignore() {

  rm -f .gitignore
  cat | tee -a .gitignore <<'EOF'
**/__pycache__/
.mypy_cache/
.pytest_cache/
venv/
EOF

}

initialize_git_repo() {
  git init
}


create_virtualenv() {

  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"

  pyenv local ${MY_PYTHON_VERSION}

  virtualenv -p $(which python3) venv
  source venv/bin/activate
  venv/bin/python3 -m  pip install pip --upgrade
}


crea_requirements_dev() {

  rm -f requirements-dev.txt
  cat | tee -a requirements-dev.txt <<'EOF'
-r requirements-test.txt

pip
wheel
pylint
black
autopep8
flake8
mypy
isort
pre-commit
pydocstyle
EOF

}


crea_requirements_test() {

  rm -f requirements-test.txt
  cat | tee -a requirements-test.txt <<'EOF'
-r requirements-prod.txt

pytest
coverage
codecov
pytest-cov
EOF

}


crea_requirements_prod() {

  rm -f requirements-prod.txt
  cat | tee -a requirements-prod.txt <<'EOF'
requests
pandas
openpyxl
statsmodels
IPython
pyOpenSSL
EOF

}


config_pylint() {
  pylint --generate-rcfile > .pylintrc
}


config_flake8() {

  rm -f .flake8
  cat | tee -a .flake8 <<'EOF'
[flake8]
exclude =
    .git,
    __pycache__,
    docs/source/conf.py,
    old,
    build,
    dist
max-complexity = 10
max-line-length = 110

per-file-ignore =
	__init__.py: F401 # module imported but unused

##
# https://pep8.readthedocs.io/en/latest/intro.html#error-codes
# https://flake8.pycqa.org/en/latest/user/error-codes.html
# https://pycodestyle.pycqa.org/en/latest/intro.html#error-codes
#
# F501: invalid % format literal
# W503: Line breaks should occur after the binary operator to keep all variable names aligned.
ignore = W503
EOF

}

config_pre_commit() {

  rm -f .pre-commit-config.yaml
  cat | tee -a .pre-commit-config.yaml <<'EOF'
repos:
-   repo: https://github.com/ambv/black
    rev: "22.1.0"
    hooks:
    - id: black
      language_version: python3.10.2
      stages: [commit]
-   repo: https://gitlab.com/pycqa/flake8
    rev: "3.9.2"
    hooks:
    - id: flake8
      stages: [commit]
-   repo: local
    hooks:
    - id: pytest
      name: pytest
      language: system
      entry: pytest -v -s
      always_run: true
      pass_filenames: false
      stages: [commit]
-   repo: local
    hooks:
      - id: requirements
        name: requirements
        entry: bash -c 'venv/bin/pip3 freeze > requirements.txt; git add requirements.txt'
        language: system
        pass_filenames: false
        stages: [commit]

EOF

  pre-commit install
  pre-commit autoupdate
}


make_sample_code() {

  mkdir -p src/domain/tests

  echo '# noqa: D104 # Missing docstring in public package' > src/__init__.py
  echo '# noqa: D104 # Missing docstring in public package' > src/domain/__init__.py
  echo '# noqa: D104 # Missing docstring in public package' > src/domain/tests/__init__.py

  rm -f src/domain/tests/test_ok.py
  cat | tee -a src/domain/tests/test_ok.py <<'EOF'
"""Trivial test file."""


def test_ok() -> None:
    """Trivial test function."""
    assert True
EOF

}


config_pytest() {

  rm -f pytest.ini
  cat | tee -a pytest.ini <<'EOF'
[pytest]
minversion = 2.0
norecursedirs = .git .tox venv* requirements*
python_files = test*.py

EOF

}


config_mypy() {

  rm -f .mypy.ini
  cat | tee -a .mypy.ini <<'EOF'
[mypy]
warn_return_any = false
warn_unused_configs = true
ignore_missing_imports = true
follow_imports = silent
check_untyped_defs = true
disallow_incomplete_defs = true
disallow_untyped_defs = true
no_implicit_optional = true

EOF

}


config_isort() {

  rm -f .isort.cfg
  cat | tee -a .isort.cfg <<'EOF'
# .isort.cfg
[settings]

# Maximum length (columns) for a line of program code.
line_length = 110

# Number of blank lines to separate imports from following statements.
lines_after_imports = 2

# Names of sections that group import statements.
# The order in this sequence specifies the order the sections should appear.
sections =
    FUTURE
    STDLIB
    THIRDPARTY
    FIRSTPARTY
    LOCALFOLDER

# Name of section for any import statement of a package not known to ‘isort’.
default_section = LOCALFOLDER

# Package names that are known for the ‘THIRDPARTY’ section.
known_third_party =
    numpy,
    pandas,
    keras,
    tensorflow,
    sciypy,
    sklearn,
    mathplotlib,
    keract,
    skimage,
    cv2,
    pyqt5,
    gym,
    PyQt5,
    pylint

# Package names that are known for the ‘FIRSTPARTY’ section.
known_first_party =

# The multi-line import statement style (integer code).
# See the ‘isort’ documentation for the meaning of each code.
multi_line_output = 5

force_single_line = False
include_trailing_comma = False

EOF

}


config_pydocstyle() {

  rm -f .pydocstyle
  cat | tee -a .pydocstyle <<'EOF'
[pydocstyle]
inherit = false

ignore =
        D203, # D203 1 blank line required before class docstring
        D213, # D213 Multi-line docstring summary should start at the second line
        D300, # D300 Use triple double quotes
        D401, # D401 First line should be in imperative mood
        D406, # D406 Section name should end with a newline
        D407, # D407 Missing dashed underline after section
        D413, # D413 Missing blank line after last section

# D208 Docstring is over-indented
# D212 Multi-line docstring summary should start at the first line
# D214 Section is over-indented


match = .*\.py

EOF

}


##
# main
#
# [instalar requisitos en visual studio code](configura-python-en-vscode.md)
#
# FIXME: los siguientes para que son?
# pip install tox
# pip install pytest-benchmark
# pip install mkdocs
# pip install mkdocstrings
# pip install mkdocs-material
# pip install Pygments
# pip install pdoc3


make_project_dir
config_gitignore
initialize_git_repo

create_virtualenv
source venv/bin/activate

# environment dependencies
crea_requirements_dev
crea_requirements_test
crea_requirements_prod
venv/bin/pip install -r requirements-dev.txt
#venv/bin/pip install -r requirements-test.txt
#venv/bin/pip install -r requirements-prod.txt

config_pylint
config_flake8
config_pre_commit
config_pytest
config_mypy


# make a test and run the QA utilities

make_sample_code # pytest fails at commit time if no tests available

pytest -svv --cov=src/ --cov-report=term-missing --cov-report=html
#codecov --dump  # requires a commit in the repo
#pydocstyle --convention=google --add-ignore=D208,D212,D214 src/
pydocstyle --convention=google src/


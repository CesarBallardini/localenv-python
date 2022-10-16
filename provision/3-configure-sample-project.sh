#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

# args:
export MY_PYTHON_VERSION=${1:-3.10.2}
export PROJECT_DIR=${2:-/vagrant/my-sample-project}
export CHOWN_PROJECT_DIR=${3:-no}


force_change_ownership_project_dir() {
  sudo mkdir "${PROJECT_DIR}"
  sudo chown $(id --name --user):$(id --name --group) "${PROJECT_DIR}"
  cd "${PROJECT_DIR}"
}


do_not_force_change_ownership_project_dir() {
  mkdir "${PROJECT_DIR}"
  cd "${PROJECT_DIR}"
}


make_project_dir() {

  if [ "${CHOWN_PROJECT_DIR}" = "yes" ]
  then
    force_change_ownership_project_dir
  else
     if  [ "${CHOWN_PROJECT_DIR}" = "no" ]
     then
       do_not_force_change_ownership_project_dir
     else
	echo "CHOWN_PROJECT_DIR value not in yes/no, [${CHOWN_PROJECT_DIR}]"
	exit 1
     fi
  fi
}


config_gitignore() {

  rm -f .gitignore
  cat | tee -a .gitignore <<'EOF'
**/__pycache__/
.mypy_cache/
.pytest_cache/
venv/
.coverage
coverage.xml
htmlcov/

EOF

}

initialize_git_repo() {
  git config --global init.defaultBranch master
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


make_requirements_dev() {

  rm -f requirements-dev.txt
  cat | tee -a requirements-dev.txt <<'EOF'
-r requirements-test.txt

pip
wheel
pylint
pylint-quotes
black
autopep8
flake8
mypy
isort
pre-commit
pydocstyle
EOF

}


make_requirements_test() {

  rm -f requirements-test.txt
  cat | tee -a requirements-test.txt <<'EOF'
-r requirements-prod.txt

pytest
coverage
codecov
pytest-cov
EOF

}


make_requirements_prod() {

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
#-   repo: https://github.com/ambv/black
#    rev: "22.1.0"
#    hooks:
#    - id: black
#      language_version: python3.10.2
#      stages: [commit]
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
        entry: bash -c 'venv/bin/pip3 freeze --all > requirements.txt; git add requirements.txt'
        language: system
        pass_filenames: false
        stages: [commit]

EOF


  pre-commit validate-config
  pre-commit install
  pre-commit autoupdate
  pre-commit validate-manifest
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

make_project_dir
config_gitignore
initialize_git_repo

create_virtualenv
source venv/bin/activate

# environment dependencies
make_requirements_dev
make_requirements_test
make_requirements_prod
venv/bin/pip install -r requirements-dev.txt
#venv/bin/pip install -r requirements-test.txt
#venv/bin/pip install -r requirements-prod.txt

config_pylint
config_flake8
config_pre_commit
config_pytest
config_mypy


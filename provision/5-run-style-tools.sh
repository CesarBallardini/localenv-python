#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

# args:
export MY_PYTHON_VERSION=${1:-3.10.2}
export PROJECT_DIR=${2:-/vagrant/my-sample-project}


make_sample_code() {

  cd "${PROJECT_DIR}"
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

    5  pre-commit validate-config
    6  pre-commit validate-manifest

git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git add .
git status
git commit -m "initial commit"

}


run_qa_tools() {

  echo make a test and run the QA utilities
  make_sample_code # pytest fails at commit time if no tests available

  echo -e '\n\n'
  echo '****************************************************'
  echo '****** run tests ***********************************'
  echo '****************************************************'
  pytest --color=yes -svv --cov=src/ --cov-report=term-missing --cov-report=html
  echo "retcode="$?

  echo -e '\n\n'
  echo '****************************************************'
  echo '****** run code coverage ***************************'
  echo '****************************************************'
  codecov --dump  # requires a commit in the repo
  echo "retcode="$?

  echo -e '\n\n'
  echo '****************************************************'
  echo '****** run doc style linter ************************'
  echo '****************************************************'
  #pydocstyle --convention=google --add-ignore=D208,D212,D214 src/
  pydocstyle --convention=google src/
  echo "retcode="$?

  echo -e '\n\n'
  echo '****************************************************'
  echo '****** run pylint **********************************'
  echo '****************************************************'
  pylint --output-format=colorized src/
  echo "retcode="$?

  echo -e '\n\n'
  echo '****************************************************'
  echo '****** run flake8 **********************************'
  echo '****************************************************'
  flake8 --color=always src/
  echo "retcode="$?

  echo -e '\n\n'
  echo '****************************************************'
  echo '****** run mypy ************************************'
  echo '****************************************************'
  mypy src/
  echo "retcode="$?

  echo -e '\n\n'
  echo '****************************************************'
  echo '****** run all linters as in pre-commit stage ******'
  echo '****************************************************'
  pre-commit run --color=always
  echo "retcode="$?

  echo -e '\n\n'
}



##
# main
#

cd "${PROJECT_DIR}"
source venv/bin/activate

make_sample_code
run_qa_tools


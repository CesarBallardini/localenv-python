#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '


curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

cat | tee -a ~/.bashrc <<'EOF'

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

EOF

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# instala la version de Python necesaria
pyenv install 3.9.9

# pone disponible dentro del repositorio
pyenv local 3.9.9


# instala Poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3.9


source ~/.poetry/env


sudo apt-get install python3-pip ${APT_OPTIONS}

pip install -U pip
pip install requests
pip install pandas
pip install openpyxl
pip install statsmodels
pip install IPython
pip install pyOpenSSL


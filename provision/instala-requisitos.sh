#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '


sudo apt-get update
sudo apt-get install make build-essential libssl-dev zlib1g-dev \
             libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
             libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
	     ${APT_OPTIONS}

sudo apt-get install git ${APT_OPTIONS}




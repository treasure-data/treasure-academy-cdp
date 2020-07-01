#!/bin/bash

set -ex

PKG_URL="https://www.python.org/ftp/python/3.7.7/python-3.7.7-macosx10.9.pkg"
PYTHON_VERSION="3.7"
PY_CMD="python${PYTHON_VERSION}"
VENV_PATH="$HOME/training"

if ! [ -x "$(command -v curl)" ]; then
  brew install curl
fi

curl ${PKG_URL} --output /tmp/python.pkg
sudo installer -pkg /tmp/python.pkg -target /
rm /tmp/python.pkg
/Applications/Python\ ${PYTHON_VERSION}/Install\ Certificates.command
${PY_CMD} -m pip install --upgrade pip
${PY_CMD} -m venv ${VENV_PATH}
${VENV_PATH}/bin/python -m pip install --upgrade pip
${VENV_PATH}/bin/python -m pip install -r requirements.txt -c constraints.txt

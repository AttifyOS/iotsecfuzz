#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${APM_TMP_DIR}" ]]; then
    echo "APM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_INSTALL_DIR}" ]]; then
    echo "APM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_BIN_DIR}" ]]; then
    echo "APM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.10.6+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $APM_TMP_DIR/cpython-3.10.6.tar.gz
  tar xf $APM_TMP_DIR/cpython-3.10.6.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/cpython-3.10.6.tar.gz

  # "|| true" is necessary to workaround the error
  # ERROR: IoTSecFuzz==1.0.0 did not indicate that it installed an .egg-info directory. Only setup.py projects generating .egg-info directories are supported.
  $APM_PKG_INSTALL_DIR/python/bin/pip3.10 install git+https://gitlab.com/invuls/iot-projects/iotsecfuzz@7909bfe9e05d0dd198cb22415c904bf7aa144b59 || true

  ln -s $APM_PKG_INSTALL_DIR/python/bin/isf $APM_PKG_BIN_DIR/
  ln -s $APM_PKG_INSTALL_DIR/python/bin/isfpm $APM_PKG_BIN_DIR/

  echo "This package adds the commands:"
  echo " - isf"
  echo " - isfpm"
}

uninstall() {
  rm -rf $APM_PKG_BIN_DIR/python
  rm $APM_PKG_BIN_DIR/isf
  rm $APM_PKG_BIN_DIR/isfpm
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1
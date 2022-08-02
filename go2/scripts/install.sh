#!/bin/bash

set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/.."

COLOR_RED='\033[0;31m'
COLOR_DARK_GRAY='\033[1;30m'
COLOR_NONE='\033[0m' # No Color

function check_requirements() {
  if [[ ! -f "$ROOT_DIR/.tool-versions" ]]; then
    echo "Please add a '.tool-versions' file to the root of the project before running this script"
    exit 1
  elif [[ ! -f "$ROOT_DIR/.envrc" ]]; then
    echo "Please add a '.envrc' file to the root of the project before running this script"
    exit 1
  elif [[ -z "$(command -v asdf)" ]]; then
    echo "Please install 'asdf' before running this script"
    exit 1
  elif [[ -z "$(command -v direnv)" ]]; then
    echo "Please install 'direnv' before running this script"
    exit 1
  fi
}

function os_name() {
  OS=`uname -s`
}

function _log_info() {
  echo "${COLOR_DARK_GRAY}${@}${COLOR_NONE}"
}

function _log_error() {
  echo "${COLOR_RED}${@}${COLOR_NONE}"
}

function add_asdf_plugins() {
  _log_info "Adding asdf plugins"

  while IFS="\n" read -r plugin
  do
    plugin=$(echo $plugin | cut -d' ' -f1)

    if [ "$plugin" != "" ]; then
      if [[ -z "$(asdf list all $plugin)" ]]; then
        _log_info "Adding plugin $plugin"
        asdf plugin add $plugin
      else
        echo "Plugin '$plugin' is already added to asdf"
      fi
    fi
  done < "${ROOT_DIR}/.tool-versions"
}

function install_asdf_plugins() {
  _log_info "Installing asdf plugins"

  if [ "$OS" == 'Darwin' ]; then
    OVERWRITE_ARCH=amd64
  fi

  while IFS="\n" read -r plugin
  do
    plugin=$(echo $plugin | cut -d' ' -f1)

    if [ "$plugin" != "" ]; then
      if [[ -z "$(command -v $plugin)" ]]; then
        _log_info "Installing asdf plugin $plugin"
        ASDF_HASHICORP_OVERWRITE_ARCH=$OVERWRITE_ARCH asdf install $plugin
      else
        echo "Plugin '$plugin' is already installed"
      fi
    fi
  done < "${ROOT_DIR}/.tool-versions"

  direnv reload
}

function main() {
  check_requirements

  add_asdf_plugins
  install_asdf_plugins
}

main

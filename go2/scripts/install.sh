#!/bin/bash

set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/.."
source "$ROOT_DIR/scripts/shared.sh"

function check_requirements() {
  if [[ ! -f "$ROOT_DIR/.tool-versions" ]]; then
    echo "Please add a '.tool-versions' file to the root of the project before running this script"
    exit 1
  elif [[ -z "$(command -v asdf)" ]]; then
    echo "Please install 'asdf' before running this script"
    exit 1
  fi
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

  ASDF_HASHICORP_OVERWRITE_ARCH=$OVERWRITE_ARCH asdf install
  direnv reload
}

function main() {
  check_requirements

  add_asdf_plugins
  install_asdf_plugins
}

main

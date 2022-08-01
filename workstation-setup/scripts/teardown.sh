#!/bin/bash

set -e -o pipefail

function uninstall_cli_program() {
  PROGRAM=$1
  IS_CASK=$2

  if [[ -n "$(command -v $PROGRAM)" ]]; then
    if [[ -z "$IS_CASK" ]]; then
      echo ""
      echo "Uninstalling '$PROGRAM'..."
      brew uninstall "$PROGRAM" --display-times
      echo ""
    else
      echo ""
      echo "Uninstalling cask '$PROGRAM'..."
      brew uninstall --cask "$PROGRAM" --display-times
      echo ""
    fi
  else
    echo "Program '$PROGRAM' is already uninstalled"
  fi
}

function uninstall_macos_dependencies() {
  uninstall_cli_program "awscli" "true"

  PROGRAMS=(asdf direnv curl jq yarn postgresql pre-commit tfenv terraform-docs)
  for program in "${PROGRAMS[@]}"; do
    uninstall_cli_program "$program"
  done
}

function main() {
  if [[ "$OSTYPE" = "darwin"* ]]; then
    uninstall_macos_dependencies
  else
    echo "Operating system '$OSTYPE' is not currently supported."
    exit 1
  fi
}

main

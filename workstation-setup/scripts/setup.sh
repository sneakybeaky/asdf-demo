#!/bin/bash

set -e -o pipefail

TERRAFORM_VERSION='0.12.31'
NOW=$(date +'%Y-%m-%d-%H-%M-%S')

function check_requirements() {
  if [[ -z "$TERRAFORM_VERSION" ]]; then
    echo "Please set an environment variable for 'TERRAFORM_VERSION' before running this script"
    exit 1
  elif [[ -z "$GIT_USERNAME" ]]; then
    echo "Please set missing environment variable 'GIT_USERNAME' before running this script"
    exit 1
  elif [[ -z "$GIT_EMAIL" ]]; then
    echo "Please set missing environment variable 'GIT_EMAIL' before running this script"
    exit 1
  fi 
}

function _log_info() {
  echo "${COLOR_DARK_GRAY}${@}${COLOR_NONE}"
}

function _log_error() {
  echo "${COLOR_RED}${@}${COLOR_NONE}"
}

function _backup_file() {
  now=$(date +'%Y-%m-%d-%H-%M-%S')

  mkdir -p ${HOME}/.onboarding

  original=$1
  filename=$(basename $original)

  if [ -f "$original" ]; then
    backup="${HOME}/.onboarding/$filename-$now"
    
    cp "$original" "$backup"
    
    _log_info "Backed up original $original to $backup";
  fi
}

function install_homebrew() {
  BREW_PATH=/usr/local/bin
  if [[ "$(uname -m)" = "arm64" ]]; then
    BREW_PATH=/opt/homebrew/bin
  fi
  
  if ( ! $(cat $HOME/.zshrc | grep "export PATH=$BREW_PATH:\$PATH" > /dev/null) ); then
    echo "export PATH=$BREW_PATH:\$PATH" >> $HOME/.zshrc
  fi

  if [[ -z "$(command -v brew)" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    eval $($BREW_PATH/brew shellenv)
  fi
}

function install_brew_package() {
  PROGRAM=$1
  PROGRAM_NAME=$2
  IS_CASK=$3
  HOMEBREW_NO_INSTALL_CLEANUP=false

  if [[ -z "$PROGRAM_NAME" ]]; then
    PROGRAM_NAME=$PROGRAM
  fi

  if [[ -z "$(command -v $PROGRAM_NAME)" ]]; then
    if [[ -z "$IS_CASK" ]]; then
      echo ""
      echo "Installing '$PROGRAM'..."
      brew install "$PROGRAM" --display-times
      echo ""
    else
      echo ""
      echo "Installing cask '$PROGRAM'..."
      brew install --cask "$PROGRAM" --display-times
      echo ""
    fi
  else
    echo "Program '$PROGRAM_NAME' already installed."
  fi
}

function install_macos_dependencies() {
  install_homebrew

  brew update
  brew upgrade

  install_brew_package "awscli" "aws"

  PROGRAMS=(asdf curl jq yarn postgresql pre-commit tfenv terraform-docs)
  for program in "${PROGRAMS[@]}"; do
    install_brew_package "$program"
  done

  install_brew_package "aws-vault" "aws-vault" "true"
}

function install_asdf() {	
  ASDF_PATH="$(brew --prefix asdf)/libexec/asdf.sh"

  if ( ! $(cat $HOME/.zshrc |grep "source ${ASDF_PATH}" > /dev/null) ); then
    _backup_file "$HOME/.zshrc"
    echo -e "\n# InDebted auto-generated\nsource ${ASDF_PATH}" >> $HOME/.zshrc
  fi

  source "${ASDF_PATH}"
}

function install_oh_my_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  if [[ ! -f "$HOME/.zshrc" ]]; then
    touch "$HOME/.zshrc"
  fi
}

function setup_git() {
  git config --global user.email "$GIT_EMAIL"
  git config --global user.name "$GIT_USERNAME"
}

function setup_aws_config() {
  AWS_CONFIG=$HOME/.aws/config

  if [[ -f "$AWS_CONFIG" ]]; then
    cp $AWS_CONFIG $HOME/.onboarding/aws-config-$NOW
    echo "Backed up original $AWS_CONFIG to $HOME/.onboarding/aws-config-$NOW";
  fi

  #cat ./template/aws-config > $AWS_CONFIG
  echo "Generated $HOME/.aws/config";
}

function setup_aws_zsh() {
  if [[ ! -f "$HOME/.aws.zsh" ]]; then
    touch "$HOME/.aws.zsh"
  fi

  if ( ! $(diff $HOME/.aws.zsh ./template/aws.zsh > /dev/null) ); then
    cp $HOME/.aws.zsh $HOME/.onboarding/aws.zsh-$NOW
    #cp ./template/aws.zsh $HOME/.aws.zsh
    
    echo "Updated $HOME/.aws.zsh and backed up original to $HOME/.onboarding/aws.zsh-$NOW";
  fi

  if ( ! $(cat $HOME/.zshrc |grep "source ~/.aws.zsh" > /dev/null) ); then
    cp $HOME/.zshrc $HOME/.onboarding/zshrc-$NOW

    echo -e "\n# InDebted auto-generated\nsource ~/.aws.zsh" >> $HOME/.zshrc
    echo "Updated $HOME/.zshrc and backed up original to ~/.onboarding/zshrc-$NOW";
  fi
}

function setup_aws() {
  if [[ ! -d "$HOME/.aws" ]]; then
    mkdir -p "$HOME/.aws"
  fi

  if [[ ! -d "$HOME/.onboarding" ]]; then
    mkdir -p "$HOME/.onboarding"
  fi

  setup_aws_config
  setup_aws_zsh
}

function install_direnv() {
  if [[ -z "$(command -v direnv)" ]]; then
	  asdf plugin add direnv || true
	  asdf direnv setup --shell zsh --version latest
  fi
}

function main() {
  check_requirements

  if [[ "$OSTYPE" = "darwin"* ]]; then
    install_macos_dependencies
  else
    echo "Operating system '$OSTYPE' is not currently supported."
    exit 1
  fi

  if [[ ! -d "$HOME/.onboarding" ]]; then
    mkdir -p "$HOME/.onboarding"
  fi

  install_asdf

  install_direnv

  install_oh_my_zsh

  setup_aws

  setup_git
}

main

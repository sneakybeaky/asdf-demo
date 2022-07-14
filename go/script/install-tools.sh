#/bin/zsh
set -ex -o pipefail

install_tools() {
	OS=`uname -s`
	if [ "$OS" == 'Darwin' ]; then
		OVERWRITE_ARCH=amd64
	fi
	ASDF_HASHICORP_OVERWRITE_ARCH=$OVERWRITE_ARCH asdf install
	direnv reload
}

install_tools
#/bin/zsh
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/.."

source "$ROOT_DIR/script/shared.sh"

add_asdf_plugins() {
	_log_info "Adding asdf plugins"
	while IFS="\n" read -r plugin
	do
		plugin=$(echo $plugin | cut -d' ' -f1)
		if [ "$plugin" != "" ]; then
			_log_info "Adding plugin $plugin"
			asdf plugin add $plugin
		fi
	done < "${ROOT_DIR}/.tool-versions"
}

install_asdf_plugins() {
	_log_info "Installing asdf plugins"
	if [ "$OS" == 'Darwin' ]; then
		OVERWRITE_ARCH=amd64
	fi
	ASDF_HASHICORP_OVERWRITE_ARCH=$OVERWRITE_ARCH asdf install
	direnv reload
}

install_tools() {
	add_asdf_plugins
	install_asdf_plugins
	_reload_shell
}

install_tools
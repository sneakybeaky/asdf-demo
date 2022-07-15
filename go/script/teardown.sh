#/bin/zsh
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/.."

source "$ROOT_DIR/script/shared.sh"

init_os_vars() {
	case "$OS" in
		"Darwin")
			UNINSTALL_CMD="brew uninstall"
			ASDF_INSTALL_PKG="asdf"
			ASDF_PATH="$(brew --prefix asdf)/libexec/asdf.sh"
			;;
		"Linux")
			ASDF_INSTALL_PKG="asdf-vm"
			ASDF_PATH="/opt/asdf-vm/asdf.sh"
			. "/etc/lsb-release"
			_log_info "Distro is ${DISTRIB_ID} ($DISTRIB_RELEASE)"
			case "$DISTRIB_ID" in
				"Ubuntu") 	UNINSTALL_CMD="sudo apt purge"
						;;
				"Debian") 	UNINSTALL_CMD="sudo apt purge"
						;;
				"ManjaroLinux") UNINSTALL_CMD="pamac remove"
						;;
				"*")		_log_error "Unknown Linux OS"
						exit 1
						;;
			esac
			;;
	esac
}

uninstall_asdf() {
	path=`command -v "asdf"`
	if [ "$path" == "" ]; then
		_log_info "asdf already uninstalled"
	else
		_log_info "Executing: $UNINSTALL_CMD $ASDF_INSTALL_PKG"
		$UNINSTALL_CMD $ASDF_INSTALL_PKG
		rm -rf ${ROOT_DIR}/.setup_ok \
			${HOME}/.asdf \
			${HOME}/.config/asdf* \
			${HOME}/.config/direnv* \
			${HOME}/.cache/asdf*

		cleanup_zshrc
	fi
}

cleanup_zshrc() {
	home_zshrc="${HOME}/.zshrc"
	_backup_file ${home_zshrc}
	if [ -f $backup ]; then
		_log_info "Cleaning up ${home_zshrc}"
		cp "${backup}" "${backup}_2"
		sed -i '' "/.*asdf.*/d" "${backup}_2"
		cp "${backup}_2" ${home_zshrc}
	fi
}

teardown() {
	init_os_vars
	uninstall_asdf
}

teardown
#/bin/zsh

# ==================================================================================
# This script will attempt to setup asdf / direnv on a given system.
# I have tested Linux but not MacOS. 
#
# It should install standard asdf plugins based on what you list in .tool-versions
# ==================================================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/.."

init_os_vars() {
	OS=`uname -s`
	case "$OS" in
		"Darwin")
			INSTALL_CMD="brew install"
			ASDF_INSTALL_PKG="asdf"
			;;
		"Linux")
			ASDF_INSTALL_PKG="asdf-vm"
			. "/etc/lsb-release"
			echo "Distro is ${DISTRIB_ID} ($DISTRIB_RELEASE)"
			case "$DISTRIB_ID" in
				"Ubuntu") 	INSTALL_CMD="sudo apt install"
						;;
				"Debian") 	INSTALL_CMD="sudo apt install"
						;;
				"ManjaroLinux") INSTALL_CMD="pamac install"
						;;
				"*")		echo "Unknown Linux OS"
						exit 1
						;;
			esac
			;;
	esac
}

interactive_exec() {
	path=`command -v "unbuffer"`
	if [ "$path" == "" ]; then
		$INSTALL_CMD expect
	fi
	unbuffer -p $1
}

interactive_Linux() {
	script --return -c "$1" /dev/null # GNU script installed by default
}

install_asdf() {
	path=`command -v "asdf"`
	if [ "$path" == "" ]; then
		echo "Executing: $INSTALL_CMD"
		$INSTALL_CMD $ASDF_INSTALL_PKG
		if [ "${OS}" == "Linux" ]; then
			asdf_path="/opt/asdf-vm/asdf.sh"
		fi
		if [ "$OS" == "Darwin" ]; then
			asdf_path="$(brew --prefix asdf)/libexec/asdf.sh"
		fi
		echo "\n#InDebted auto-generated\nsource ${asdf_path}" >> ${HOME}/.zshrc
		source "${asdf_path}"
	else
		echo "asdf already installed"
	fi
}

install_direnv() {
	asdf plugin-add direnv
	asdf direnv setup --shell zsh --version latest
}

add_asdf_plugins() {
	while IFS="\n" read -r plugin
	do
		plugin=$(echo $plugin | cut -d' ' -f1)
		if [ "$plugin" != "" ]; then
			echo "adding plugin $plugin"
			asdf plugin add $plugin
		fi
	done < .tool-versions
}

# Identify OS requirements
init_os_vars

# Test for existence of asdf tool. If it doesn't exist, try to execute an OS install of it.
install_asdf

# Add direnv, bootstrap for zsh
install_direnv

# Read the plugins from .tool-versions, and tell asdf to add them ... (TODO: git-repos etc?)
add_asdf_plugins

# Install specified versions from .tool-versions, and reload direnv
$ROOT_DIR/script/install-tools.sh

# Invoke `direnv allow .` interactively
echo "We need to run direnv allow . once to make this configuration valid."
interactive_exec "direnv allow ."
echo "Done..."

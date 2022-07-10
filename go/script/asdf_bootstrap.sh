#/bin/zsh

# ==================================================================================
# This script will attempt to setup asdf / direnv on a given system.
# I have tested Linux but not MacOS. 
#
# It should install standard asdf plugins based on what you list in .tool-versions
# ==================================================================================

# Identify OS requirements
OS=`uname -s`
INSTALL_CMD=""
case "$OS" in
	"Darwin") 	BINARY="asdf"
				INSTALL_CMD="brew install asdf"
				;;
	"Linux")  	BINARY="asdf"
				. "/etc/lsb-release"
				echo "Distro is ${DISTRIB_ID} ($DISTRIB_RELEASE)"
				case "$DISTRIB_ID" in
					"Ubuntu") 			INSTALL_CMD="sudo apt install asdf-vm" 
										;;
					"Debian") 			INSTALL_CMD="sudo apt install asdf-vm" 
										;;
					"ManjaroLinux") 	INSTALL_CMD="pamac install asdf-vm"
										;;
					"*")				echo "Unknown Linux OS"
										exit 1
										;;
				esac
				;;
esac

# Test for existence of asdf tool. If it doesn't exist, try to execute an OS install of it.
COMMAND=`command -v "${BINARY}"`
if [ "$COMMAND" == "" ]; then 
	echo "asdf not installed"
	echo "Will execute: ${INSTALL_CMD}"
	${INSTALL_CMD}
	echo ". /opt/asdf-vm/asdf.sh" >> ~/.zshrc
	. "/opt/asdf-vm/asdf.sh"
else
	echo "asdf is installed as ${COMMAND}"
fi

# Add direnv, bootstrap for zsh
asdf plugin-add direnv
asdf direnv setup --shell zsh --version latest

# Read the plugins from .tool-versions, and tell asdf to install them ... (TODO: git-repos etc?)
while IFS=" " read -r dependency version 
do
	asdf plugin add $dependency
done < .tool-versions

# Install specified versions from .tool-versions, and reload direnv
asdf install
direnv reload

# Invoke direnv allow using an old trick I remember (I wonder if this works on MacOS?)
echo "We need to run direnv allow . once to make this configuration valid."
script --return --quiet -c "direnv allow ." /dev/null
echo "Done..."




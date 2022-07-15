#/bin/zsh
set -o pipefail

os_name() {
	OS=`uname -s`
}

COLOR_RED='\033[0;31m'
COLOR_DARK_GRAY='\033[1;30m'
COLOR_NONE='\033[0m' # No Color

_log_info() {
    echo "${COLOR_DARK_GRAY}${@}${COLOR_NONE}"
}

_log_error() {
	echo "${COLOR_RED}${@}${COLOR_NONE}"
}

_backup_file() {
	now=$(date +'%Y-%m-%d-%H-%M-%S')
	mkdir -p ${HOME}/.onboarding
	original=$1
	filename=$(basename $original)

	if [ -f $original ]; then
		backup="${HOME}/.onboarding/$filename-$now"
		cp "$original" "$backup"
		_log_info "Backed up original $original to $backup";
	fi
}

os_name
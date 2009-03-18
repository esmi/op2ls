#!/bin/bash
#
# FILE:  wns_include.sh
#
defined() {
	if (( $# != 1 ))
	then
		error "defined accepts exactly one argument"
	fi

	if [ -n "${!1}" ]
	then
		return 0;
	else
		return 1;
	fi
}

pushd() {
	builtin pushd ${@} > /dev/null
}

popd() {
	builtin popd ${@} > /dev/null
}

readonly -f defined pushd popd
export -f defined pushd popd

set -e;

# Make sure we are on 1.5 before proceeding
declare -rx _name=$(basename $0);
declare -r  _version=0.0.1;

declare -ar argv=(${0} ${@})
declare -ir argc=$(( $# + 1 ))

__show_version() {
	cat <<-_EOF
		${_name} ${_version}
		Copyright (C) 2008, 2009 Evan Chen. 

		This program comes with NO WARRANTY, to the extent permitted by law.

		You may redistribute copies of this program under the terms of
		the GNU General Public License as published by the Free Software
		Foundation, either version 3 of the License, or (at your option) any
		later version.

		For more information about these matters, see the file named COPYING.

		Written by Evan Chen for the WNS project
		_EOF
}

# displays error message and exits
error() {
	case $? in
		0) local errorcode=1 ;;
		*) local errorcode=$? ;;
	esac

	echo -e "\e[1;31m*** ERROR:\e[0;0m ${1:-no error message provided}";
	exit ${errorcode};
}

# displays warning message only
warning() {
	echo -e "\e[1;33m*** Warning:\e[0;0m ${1}";
}

# displays information message
inform() {
	echo -e "\e[1;32m*** Info:\e[0;0m ${1}" >&2 ;
}

debug() {
	echo -e "\e[1;34m*** debug:\e[0;0m ${1}" >&2 ;
}

# displays command to stdout before execution
verbose() {
	echo "${@}"
	"${@}"
	return $?
}

# for internal use only
__stage() {
	echo -e "\e[1;39m>>> ${1} ${PF}\e[0;0m";
}

__step() {
	echo -e ">>> ${1}";
}

# protect functions
readonly -f __show_version error warning inform verbose __stage __step
export -f error warning inform verbose

abort() {
    echo $0: $@
    exec false
}


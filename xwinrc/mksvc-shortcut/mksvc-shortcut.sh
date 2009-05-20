#!/bin/bash

_name=`basename $0`

shortcut_create() {
    LINK_NAME="$1"

    SERVICE_NAME="$2"
    LAUNCHER_ARGS="$3 $SERVICE_NAME"
    LAUNCHER="`cygpath c:/windows/system32/net`"

    ICON_F=/usr/bin/run.exe
    rm -f $LINK_NAME.lnk

    mkshortcut  -n "$LINK_NAME" \
            -a "$LAUNCHER_ARGS" \
            -i "$ICON_F" -j 0 \
	    -d "$LINK_NAME is created by $_name" \
            "$LAUNCHER"
}

__create_svc_shortcut() {

    shortcut_create ReportSrv-svc-start 'ReportServer$SQLEXPRESS' start
    shortcut_create ReportSrv-svc-stop 'ReportServer$SQLEXPRESS' stop

    shortcut_create MSSql-svc-start 'MSSQL$SQLEXPRESS' start
    shortcut_create MSSql-svc-stop 'MSSQL$SQLEXPRESS' stop

    shortcut_create SQLBrowser-svc-start 'SQLBrowser' start
    shortcut_create SQLBrowser-svc-stop 'SQLBrowser' stop
}

__show_info() {
cat <<-EOF
    "ReportServer\$SQLExpress, MSSQL\$SQLExpress, SQLBrowser services shortcut files has been created."
    "you can put files to ~/opt/etc/service.d, but under vista environment,you must "
    "run these shortcut as Administrator, Please modify these shortcuts, by right-click"
    "shortcut properties, shortcut(tab) - Advance(bottom) - 'checked' run as Administrator"
EOF
}
__show_help() {
	cat <<-_EOF
		${_name} is a script that create shortcut for mssql service control.

		Usage: ${_name} [ --info | --help  ]

		_EOF
}


#__main
COMMON_OP="info,help"
ALL_OP="$GEN_OP,$COMMON_OP,$ABORT_OP,$SCHEDULE_OP"
OPT=`getopt -o "" --longoptions=$ALL_OP -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

#echo OPT: $OPT
eval set -- "$OPT"
if [  $# -eq 1 ] ; then __show_help; fi
set -e


while true ; do
    case "$1" in
	--help)		__show_help;   break ;;
	--info)	__show_info; shift ;;
        --)		break ;;
	*)		__show_help;   break ;;
    esac
done 

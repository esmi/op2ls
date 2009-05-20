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

__query_servicename() {
    psservice | grep ^SERVICE_NAME 
}

__create_mssql_ctrl() {

    shortcut_create ReportSrv-svc-start 'ReportServer$SQLEXPRESS' start
    shortcut_create ReportSrv-svc-stop 'ReportServer$SQLEXPRESS' stop

    shortcut_create MSSql-svc-start 'MSSQL$SQLEXPRESS' start
    shortcut_create MSSql-svc-stop 'MSSQL$SQLEXPRESS' stop

    shortcut_create SQLBrowser-svc-start 'SQLBrowser' start
    shortcut_create SQLBrowser-svc-stop 'SQLBrowser' stop
}

__create_servicename_ctrl() {
    servicename="`__query_servicename | grep $1 `"
    if [ "$servicename". == "". ] ; then
	echo "servic ename: $1, not found."
    else
	servicename="`echo $servicename | sed 's/^.* //g'`"
	echo service name: $servicename
	shortcut_create $servicename-start "$servicename" start
	echo start control shortcut: $servicename-start, created.
	shortcut_create $servicename-stop "$servicename" stop
	echo stop control shortcut: $servicename-stop, created.
    fi
}

__create_sqlexpress_ctrl() {
    servicename="`__query_servicename | grep -i "sqlexpress" `"
    if [ "$servicename". == "". ] ; then
	echo "servic ename: $1, not found."
    else
	for servicename in `__query_servicename | grep -i "sqlexpress" | sed 's/^.* //g'` ; do
	    echo service name: $servicename
	    shortcut_create $servicename-start "$servicename" start
	    echo start control shortcut: $servicename-start, created.
	    shortcut_create $servicename-stop "$servicename" stop
	    echo stop control shortcut: $servicename-stop, created.
	    echo ""
	done
    fi
}

__show_info() {
cat <<-EOF
   You can use services shortcut files,ex: put them to a directory(ex: ~/opt/etc/service.d) to use. 
Under vista environment, you must run these shortcut as Administrator, by right-click shortcut properties 
- shortcut(tab) - Advance(bottom) - 'checked' run as Administrator"
EOF
}

__show_help() {
	cat <<-_EOF

		${_name} is a script that create "servicename" shortcut for service.

		Usage: ${_name} [ --info | --help | --query | --create <servicename> ]
			    [ --mssql | --sqlexpress ]

		    --query: query service name
		    --create [servicename]: create service control shortcut.
		    --mssql: create mssql service control shortcuts.
		    --sqlexpress: create sqlexpress service control shortcuts.

		_EOF
}


#__main
COMMON_OP="info,help,query,mssql,create:"
SVC_OP="mssql,sqlexpress"
ALL_OP="$GEN_OP,$COMMON_OP,$SVC_OP,$SCHEDULE_OP"
OPT=`getopt -o "" --longoptions=$ALL_OP -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

#echo OPT: $OPT
eval set -- "$OPT"
if [  $# -eq 1 ] ; then __show_help; fi
set +e


while true ; do
    case "$1" in
	--help)	    __show_help;  __show_info;  break ;;
	--info)	    __show_info; shift ;;
	--mssql)    __create_mssql_ctrl; shift ;;
	--sqlexpress) __create_sqlexpress_ctrl ; shift ;;
	--create)   __create_servicename_ctrl $2 ;  shift; shift ;;
	--query)    __query_servicename ; shift ;;
        --)		break ;;
	*)		__show_help;   break ;;
    esac
done 



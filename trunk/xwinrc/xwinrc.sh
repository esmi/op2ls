#!/bin/bash

submenu() {
    TITLE_F="$1/menu.title"
    COMMENT_F="$1/menu.comment"
    echo menu $1 '{'
    cat `find $1/ -type f | grep -Ev "(menu.*|^\.|\/\.)"` | sed 's/^/\t/g'

    if [ -e "$COMMENT_F" ] ; then
	cat "$COMMENT_F" | sed -e 's/^/\t/g'
    fi
    echo '}'
}


## Function: MAIN
#root menu

if [ -e "$1/COMMENT" ] ; then cat "$1/COMMENT" ; fi

pushd `pwd` > /dev/null
cd $1
submenus="$(find -type d  -or -type l | grep -Ev "\.svn|^.$" | sed 's/^\.\///g')"

for menu in `echo $submenus` ; do
    submenu $menu
done

popd > /dev/null

menus="`find ./$1 -maxdepth 1 -type d  | grep -Ev "($1$|\.svn)"`"

echo menu $1 '{'
if [ -e "$1/RELOAD" ] ; then cat "$1/RELOAD" | sed 's/^/\t/g' ; fi
menu_boxes=`find $1/MENU? 2> /dev/null`
if [ "$menu_boxes". == "". ] ; then 

    for menu in `echo $menus` ; do

	TITLE_F="$menu/menu.title"

	if [ -e $TITLE_F ] ; then
	    TITLE="`cat "$TITLE_F"`"
	    echo -e \\t\"$TITLE\" menu $(echo $menu | sed 's/.*\///g' )
	else
	    echo -e \\t\"$(echo $menu| sed 's/.*\///g')\"  menu $(echo $menu | sed 's/.*\///g' )
	fi

    done

else
    for menu_box in $menu_boxes ; do
	if [ -e $menu_box ] ; then
	    for menu in `cat $menu_box` ; do
		TITLE_F="$1/$menu/menu.title"

		if [ -e $TITLE_F ] ; then
		    TITLE="`cat "$TITLE_F"`"
		    echo -e \\t\"$TITLE\" menu $(echo $menu | sed 's/.*\///g' )
		else
		    echo -e \\t\"$(echo $menu| sed 's/.*\///g')\"  menu $(echo $menu | sed 's/.*\///g' )
		fi

	    done
	    echo -e \\tSeparator
	fi
    done
fi


echo '}'

echo RootMenu $1

if [ -e $1/SYSMENU ] ; then
    cat $1/SYSMENU
fi


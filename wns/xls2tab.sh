#!/bin/bash

path='\\kh-nas\社群資料區\新產品開發專案管理\新產品開發專案管理\BI_經企\以程式處理BI資訊'
table='BI新聞分類機制.xls'
XLSTBL="$path/$table"

TODAY="`date +%Y%m%d`"

DEFAULT_TAB=../TABLES/DEFAULT.xls
RULES_TAB=../TABLES/RULES.TAB
FOLDER_TAB=../TABLES/FOLDER.TAB

TODAY_TAB=../TABLES/$TODAY.xls
TYPES_TAB=./types.tab2
FLDR_TAB=./folder.tab


echo "Try cp \"RULES TABLE\":" 
echo "       $XLSTBL"
echo "    to $TODAY_TAB"

if [ -e $XLSTBL ] ; then
    cp "$XLSTBL" $TODAY_TAB
    cp $TODAY_TAB $DEFAULT_TAB

    echo "RULES TABLE has been copy to $DEFAULT_TAB."
    echo "Use $DEFAULT_TAB to create $RULES_TAB"

    perl ./xls2rules.pl $DEFAULT_TAB 2>/dev/null | \
	    egrep -v '(^seq|^\(0|^\"seq|title全為英文|^.*OR.*NOT|^Name.*tagging$)' | \
	    sed -e 's/, /,/g' -e 's/|$//g' -e 's/,,/,/g' > $RULES_TAB
    perl ./xls2folder.pl $DEFAULT_TAB 2> /dev/null | \
	    egrep -v "(^Name:.*|^sequence|^\(0.*)" | grep -v '^|||||' > $FOLDER_TAB
    echo "Create symbolic link file $RULES_TAB to $TYPES_TAB"
    rm  -f $TYPES_TAB
    ln -s $RULES_TAB $TYPES_TAB

    rm -f $FLDR_TAB
    ln -s $FOLDER_TAB $FLDR_TAB
    ls -l --color $RULES_TAB $TYPES_TAB $FOLDER_TAB $FLDR_TAB
    
else
    echo "NOT FOUND KH-NAS RULES TABLE, USE OLD rules !!!!"
fi


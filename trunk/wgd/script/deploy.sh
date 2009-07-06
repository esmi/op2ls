
#GD_PRD_PATH=../src

local __TEMPLATE_DEST_PATH=$GD_PRD_PATH/"$TEMPLATE"

if [ ! -d $__TEMPLATE_DEST_PATH ] ; then
    echo Create template scripts path: $(mkdir $__TEMPLATE_DEST_PATH).
else
    echo cp $_output/*.asp $__TEMPLATE_DEST_PATH
fi


cat wns.cfg | gawk -F "=" '{print $1"="}' |  sed -e 's/^=$//g' 

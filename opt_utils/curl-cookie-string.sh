if [ $# == 0 ] ; then
cat <<-EOF
Description: Curl header file "Set-Cookie:" string viewer.
usage: `basename $0` [ curl_header_file ]

EOF
else  
    if [ -e $1 ] ; then
	cat $1 |  grep -i Set-Cookie | \
	    sed -e 's/^Set-Cookie: //g' -e 's/;.*$/;/g' -e '/=;.*$/d' | \
	    tr '\n' ' ' | \
	    sed 's/; $//g'
    fi
fi

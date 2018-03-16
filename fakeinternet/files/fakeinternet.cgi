#!/bin/sh
if [ "$REQUEST_URI" == "/generate_204" ]; then
	echo "Status: 204 No Content"
	echo ""
	exit
fi
if [ "$REQUEST_URI" == "/blank.html" ]; then
	echo "Status: 200 OK"
	echo "Content-Type: text/html"
	echo ""
	exit
fi
if [ "$REQUEST_URI" == "/library/test/success.html" -o "$REQUEST_URI" == "/hotspot-detect.html" ]; then
	echo "Status: 200 OK"
	echo "Content-Type: text/html"
	echo ""
	echo '<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>'
	echo ""
	exit
fi
echo "Status: 200 OK"
echo "Content-Type: text/html"
echo ""
#echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'
#echo "<HTML><HEAD><TITLE>$REQUEST_URI</TITLE></HEAD><BODY>Requested page: $REQUEST_URI</BODY></HTML>"
echo '<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>'
echo ""

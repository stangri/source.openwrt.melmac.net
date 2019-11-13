#!/bin/sh

if [ "$REQUEST_URI" = "/gen_204" ] || [ "$REQUEST_URI" = "/generate_204" ]; then
	echo "Status: 204 No Content"
	echo "Content-Length: 0"
	echo "Date: $(date --rfc-2822)"
	echo ""
	echo ""
	echo ""
	logger -t 'fakeinternet' "${HTTP_HOST}${REQUEST_URI}: Served 204 No Content"
elif [ "$REQUEST_URI" = "/blank.html" ]; then
	echo "Status: 200 OK"
	echo "Content-Type: text/html"
	echo ""
	logger -t 'fakeinternet' "${HTTP_HOST}${REQUEST_URI}: Served 200 OK"
elif [ "$REQUEST_URI" = "/library/test/success.html" ] || [ "$REQUEST_URI" = "/hotspot-detect.html" ]; then
	echo "Status: 200 OK"
	echo "Content-Type: text/html"
	echo ""
	echo "<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>"
	echo ""
	logger -t 'fakeinternet' "${HTTP_HOST}${REQUEST_URI}: Served 200 OK/Success"
elif [ "$REQUEST_URI" = "/kindle-wifi/wifistub.html" ]; then
	echo 'Status: 200 OK'
	echo 'Content-Type: text/html'
	echo ''
	echo '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
	echo '<html>'
	echo '<head>'
	echo '<title>Kindle Reachability Probe Page</title>'
	echo '<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
	echo '<!--81ce4465-7167-4dcb-835b-dcc9e44c112a created with python 2.5 uuid.uuid4()-->'
	echo '</head>'
	echo '<body bgcolor="#ffffff" text="#000000">'
	echo '81ce4465-7167-4dcb-835b-dcc9e44c112a'
	echo '</body>'
	echo '</html>'
	logger -t 'fakeinternet' "${HTTP_HOST}${REQUEST_URI}: Served 200 OK/HTML"
elif [ "$REQUEST_URI" = "/kindle-wifi/wifiredirect.html" ]; then
	echo 'Status: 200 OK'
	echo 'Content-Type: text/html'
	echo ''
	echo '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
	echo '<html>'
	echo '<head>'
	echo '<meta http-equiv="refresh" content="0; url=http://www.amazon.com" />'
	echo '</head>'
	echo '<body>'
	echo '</body>'
	echo '</html>'
	logger -t 'fakeinternet' "${HTTP_HOST}${REQUEST_URI}: Served 200 OK/HTML"
elif [ "$REQUEST_URI" == "/check_network_status.txt" ]; then
	echo "Status: 200 OK"
	echo "Content-Type: text/plain"
	echo ""
	echo "NetworkManager is online"
	echo ""
	logger -t 'fakeinternet' "${HTTP_HOST}${REQUEST_URI}: Served 200 OK"
elif [ "$REQUEST_URI" == "/success.txt" ]; then
	echo "Status: 200 OK"
	echo "Content-Type: text/plain"
	echo ""
	echo "success"
	echo ""
	logger -t 'fakeinternet' "${HTTP_HOST}${REQUEST_URI}: Served 200 OK"
else
	echo "Status: 200 OK"
	echo "Content-Type: text/html"
	echo ""
	echo "<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>"
	echo ""
	logger -t 'fakeinternet' "${HTTP_HOST}${REQUEST_URI}: Generic 200 OK/Success"
fi

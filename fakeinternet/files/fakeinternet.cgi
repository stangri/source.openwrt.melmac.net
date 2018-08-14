#!/bin/sh
if [ "$REQUEST_URI" = "/generate_204" ]; then
cat << 'EOF'
Status: 204 No Content

EOF
exit
logger -t 'fakeinternet' "$REQUEST_URI: Served 204 No Content"
fi

if [ "$REQUEST_URI" = "/blank.html" ]; then
cat << 'EOF'
Status: 200 OK
Content-Type: text/html

EOF
logger -t 'fakeinternet' "$REQUEST_URI: Served 200 OK"
exit
fi

if [ "$REQUEST_URI" = "/library/test/success.html" ] || [ "$REQUEST_URI" = "/hotspot-detect.html" ]; then
cat << 'EOF'
Status: 200 OK
Content-Type: text/html

<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>

EOF
logger -t 'fakeinternet' "$REQUEST_URI: Served 200 OK/Success"
exit
fi

if [ "$REQUEST_URI" = "/kindle-wifi/wifistub.html" ]; then
cat << 'EOF'
Status: 200 OK
Content-Type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>Kindle Reachability Probe Page</title>
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<!--81ce4465-7167-4dcb-835b-dcc9e44c112a created with python 2.5 uuid.uuid4()-->
</head>
<body bgcolor="#ffffff" text="#000000">
81ce4465-7167-4dcb-835b-dcc9e44c112a
</body>
</html>
EOF
logger -t 'fakeinternet' "$REQUEST_URI: Served 200 OK/HTML"
exit
fi

if [ "$REQUEST_URI" = "/kindle-wifi/wifiredirect.html" ]; then
cat << 'EOF'
Status: 200 OK
Content-Type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="refresh" content="0; url=http://www.amazon.com" />
</head>
</body>
</html>
EOF
logger -t 'fakeinternet' "$REQUEST_URI: Served 200 OK/HTML"
exit
fi

if [ "$REQUEST_URI" == "/check_network_status.txt" ]; then
cat << 'EOF'
Status: 200 OK
Content-Type: text/plain

NetworkManager is online

EOF
logger -t 'fakeinternet' "$REQUEST_URI: Served 200 OK"
exit
fi

if [ "$REQUEST_URI" == "/success.txt" ]; then
cat << 'EOF'
Status: 200 OK
Content-Type: text/plain

success

EOF
logger -t 'fakeinternet' "$REQUEST_URI: Served 200 OK"
exit
fi

cat << 'EOF'
Status: 200 OK
Content-Type: text/html

<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>

EOF
logger -t 'fakeinternet' "$REQUEST_URI: Generic 200 OK/Success"
exit

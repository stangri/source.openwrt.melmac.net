#!/bin/sh
# Copyright 2023-04-01 Stan Grishin (stangri@melmac.ca)
# shellcheck disable=SC3043,3037

readonly PKG_VERSION='dev-test'
readonly README_URL='https://docs.openwrt.melmac.net/brickproof/'

case "$1" in
	enable|on)
		echo -en "Brickproof $PKG_VERSION turning Failsafe Mode at next boot on... "
		if [ -s /usr/share/brickproof/failsafe_brickproof ] && cp -f /usr/share/brickproof/failsafe_brickproof /lib/preinit/39_failsafe_brickproof; then
			echo "ok"
		else
			echo "FAIL!"
		fi
	;;
	disable|off)
		echo -en "Brickproof $PKG_VERSION turning Failsafe Mode at next boot off... "
		if rm -f /lib/preinit/39_failsafe_brickproof; then
			echo "ok"
		else
			echo "FAIL!"
		fi
	;;
	*)
		if [ -z "$1" ]; then
			echo "Missing parameter!"
		else
			echo "Unknown parameter: '$1'!"
		fi
		echo "Use 'brickproof enable' to enable Failesafe Mode at next boot."
		echo "Use 'brickproof disable' to disable Failesafe Mode at next boot."
		echo "Check README at $README_URL for more information."
	;;
esac

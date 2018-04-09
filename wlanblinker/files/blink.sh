#!/bin/sh

if [ "$1" == "-d" ]; then daemon=1; shift; else daemon=0; fi
LED="/sys/class/leds/${1}/brightness" display="$2" radio="$3" onTime="${4:-1}" offTime="${5:-1}" sleepTime="${6:-3}"
[[ -e "$LED" && -n "$display" && -n "$radio" ]] || exit 1

while :; do
	i=1 blinks=0
	case $display in
		channel)
			channel="$(uci -q get wireless.$radio.channel)"
			if [ "$channel" == "auto" ]; then
				onTime='0.1'; offTime='0.1'; sleepTime='0.1'; blinks='2';
			else
				blinks="$channel"
			fi
			;;
		link_quality)
			lq="$(iwinfo $radio info | grep 'Link Quality' | awk '{print $6}')"
			lqbase="${lq##*/}"; lq="${lq%/*}"; blinks=$((lq * 10 / lqbase));
			;;
	esac

	while [ $i -ne $blinks ]; do
		echo "1" > "$LED"; /usr/bin/sleep "$onTime";
		echo "0" > "$LED"; /usr/bin/sleep "$offTime";
		i=$((i+1))
	done
	echo "0" > "$LED"
	[ $daemon -ne 0 ] || exit 0
	/usr/bin/sleep "$sleepTime"
done

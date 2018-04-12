#!/bin/sh
PKG_VERSION=
readonly packageName='slider-support'
readonly serviceName="$packageName $PKG_VERSION"

add_trm_to_iface() { config_get name "$1" 'name'; [ "$name" == "$2" ] && uci -q add_list firewall.${1}.network='trm_wwan'; }
del_trm_from_iface() { config_get name "$1" 'name'; [ "$name" == "$2" ] && uci -q del_list firewall.${1}.network='trm_wwan'; }
randomip(){ local a=300 b=300 n; while [[ "$a" -gt 255 || "$b" -gt 255 ]]; do n=$(grep -m10 -ao '[0-9]' /dev/urandom | tr -d '\n'); a="$(echo ${n:0:3} | sed 's/^0*//;s/^0*$/0/')"; b="$(echo ${n:4:3} | sed 's/^0*//;s/^0*$/0/')"; done; echo "192.168.$a.$b"; }
source /usr/share/libubox/jshn.sh; json_load "$(/bin/ubus call system board)"; json_get_vars model; model="$(echo $model | tr '[A-Z]' '[a-z]')";
case $model in
    gl-mt300n*)
        checkslider() { [ -n "$(grep -o 'BTN_0.*hi' /sys/kernel/debug/gpio)" ] && return 0 || return 1; }
        checkports() { [ "$(swconfig dev switch0 port 0 get link)" == "port:0 link:down" ] && return 0 || return 1; }
        ;;
    gl-ar300m*)
        checkslider() { [ -n "$(grep -o 'button left.*hi' /sys/kernel/debug/gpio)" ] && return 0 || return 1; }
        checkports() { s=0; for i in $(uci -q get network.wan.ifname); do [[ -n "$i" && "$(ethtool $i 2>/dev/null | grep 'Link detected' | awk '{print $3}')" != "no" ]] && s=1; done; return $s; }
        ;;
    *)
				logger -t "$packageName" "Unknown router model: $model"
				exit 1
        ;;
esac
if checkslider; then mode='router'; elif checkports; then mode='wr'; else mode='ap'; fi
oldIP="$(uci get network.lan.ipaddrold)"
logger -t "$packageName" "$mode mode ($serviceName)"
uci -q set wlanblinker.config.mode="$mode"
case $mode in
	router)
		source /lib/functions.sh; config_load firewall;
		config_foreach add_trm_to_iface 'zone' 'wan';
		config_foreach del_trm_from_iface 'zone' 'lan';
		uci set firewall.@zone[0].network='lan'
		uci set dhcp.@dnsmasq[-1].rebind_protection=1
		uci -q del network.stabridge
		uci -q del dhcp.lan.ignore
		uci -q del network.lan.gateway
		uci -q del network.lan.dns
		[ -n "$oldIP" ] && uci set network.lan.ipaddr="$oldIP"
		uci commit
		/etc/init.d/relayd stop >/dev/null 2>&1
		/etc/init.d/relayd disable >/dev/null 2>&1
		/etc/init.d/firewall enable >/dev/null 2>&1
		/etc/init.d/firewall start >/dev/null 2>&1
		/sbin/reload_config
		if [ -f /etc/init.d/openvpn ]; then
			/etc/init.d/openvpn enable
			/etc/init.d/openvpn start
		fi
		if [ -f /etc/init.d/vpn-policy-routing ]; then
			/etc/init.d/vpn-policy-routing enable
			/etc/init.d/vpn-policy-routing start
		fi
		;;
	ap)
		uci set dhcp.lan.ignore=1
		uci set dhcp.@dnsmasq[-1].rebind_protection=0
		[ -z "$oldIP" ] && uci set network.lan.ipaddrold="$(uci -q get network.lan.ipaddr)"
		uci set network.lan.ipaddr="$(randomip)"
		uci -q del network.lan.gateway
		uci -q del network.lan.dns
		uci -q del network.stabridge
		uci commit
		if [ -f /etc/init.d/vpn-policy-routing ]; then
			/etc/init.d/vpn-policy-routing stop
			/etc/init.d/vpn-policy-routing disable
		fi
		if [ -f /etc/init.d/openvpn ]; then
			/etc/init.d/openvpn stop
			/etc/init.d/openvpn disable
		fi
		/etc/init.d/relayd stop >/dev/null 2>&1
		/etc/init.d/relayd disable >/dev/null 2>&1
		/etc/init.d/firewall stop >/dev/null 2>&1
		/etc/init.d/firewall disable >/dev/null 2>&1
		/sbin/reload_config
		;;
	wr)
		source /lib/functions.sh; config_load firewall;
		config_foreach add_trm_to_iface 'zone' 'lan';
		config_foreach del_trm_from_iface 'zone' 'wan';
		uci set firewall.@zone[0].network='lan trm_wwan'
		uci set network.stabridge=interface
		uci set network.stabridge.proto=relay
		uci set network.stabridge.network='lan trm_wwan'
		uci set dhcp.lan.ignore=1
		uci set dhcp.@dnsmasq[-1].rebind_protection=0
		[ -z "$oldIP" ] && uci set network.lan.ipaddrold="$(uci -q get network.lan.ipaddr)"
		uci set network.lan.ipaddr="$(randomip)"
		uci commit
		if [ -f /etc/init.d/vpn-policy-routing ]; then
			/etc/init.d/vpn-policy-routing stop
			/etc/init.d/vpn-policy-routing disable
		fi
		if [ -f /etc/init.d/openvpn ]; then
			/etc/init.d/openvpn stop
			/etc/init.d/openvpn disable
		fi
		/etc/init.d/firewall stop >/dev/null 2>&1
		/etc/init.d/firewall disable >/dev/null 2>&1
		/etc/init.d/relayd enable >/dev/null 2>&1
		/etc/init.d/relayd start >/dev/null 2>&1
		/sbin/reload_config
		;;
esac
[ -s /etc/init.d/travelmate ] && /etc/init.d/travelmate restart
[ -s /etc/init.d/wlanblinker ] && /etc/init.d/wlanblinker restart

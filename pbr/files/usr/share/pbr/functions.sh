#!/bin/sh
# Copyright 2023 MOSSDeF, Stan Grishin (stangri@melmac.ca)
# shellcheck disable=SC2018,SC2019,SC2034,SC3043,SC3057,SC3060

readonly packageName='pbr'
readonly PKG_VERSION='dev-test'
readonly serviceName="$packageName $PKG_VERSION"
readonly serviceTrapSignals='exit SIGHUP SIGQUIT SIGKILL'
readonly packageConfigFile="/etc/config/${packageName}"
readonly packageLockFile="/var/run/${packageName}.lock"
readonly dnsmasqFileDefault="/var/dnsmasq.d/${packageName}"
readonly _OK_='\033[0;32m\xe2\x9c\x93\033[0m'
readonly _FAIL_='\033[0;31m\xe2\x9c\x97\033[0m'
readonly __OK__='\033[0;32m[\xe2\x9c\x93]\033[0m'
readonly __FAIL__='\033[0;31m[\xe2\x9c\x97]\033[0m'
readonly _ERROR_='\033[0;31mERROR\033[0m'
readonly _WARNING_='\033[0;33mWARNING\033[0m'
readonly ip_full='/usr/libexec/ip-full'
# shellcheck disable=SC2155
readonly ip_bin="$(command -v ip)"
readonly ipTablePrefix='pbr'
# shellcheck disable=SC2155
readonly iptables="$(command -v iptables)"
# shellcheck disable=SC2155
readonly ip6tables="$(command -v ip6tables)"
# shellcheck disable=SC2155
readonly ipset="$(command -v ipset)"
readonly ipsPrefix='pbr'
readonly iptPrefix='PBR'
# shellcheck disable=SC2155
readonly agh="$(command -v AdGuardHome)"
readonly aghConfigFile='/etc/adguardhome.yaml'
readonly aghIpsetFile="/var/run/${packageName}.adguardhome.ipsets"
# shellcheck disable=SC2155
readonly nft="$(command -v nft)"
readonly nftTempFile="/var/run/${packageName}.nft"
readonly nftPermFile="/usr/share/nftables.d/ruleset-post/30-${packageName}.nft"
readonly nftPrefix='pbr'
readonly nftTable='fw4'
readonly chainsList='forward input output postrouting prerouting'
readonly ssConfigFile='/etc/shadowsocks'
readonly torConfigFile='/etc/tor/torrc'
readonly xrayIfacePrefix='xray_'

# package config options
procd_boot_timeout=
enabled=
fw_mask=
icmp_interface=
ignored_interface=
ipv6_enabled=
nft_file_support=
nft_user_set_policy=
nft_user_set_counter=
procd_boot_delay=
procd_reload_delay=
procd_lan_interface=
procd_wan_interface=
procd_wan6_interface=
resolver_set=
resolver_instance=
rule_create_option=
secure_reload=
strict_enforcement=
supported_interface=
verbosity=
wan_ip_rules_priority=
wan_mark=

# run-time
gatewaySummary=
errorSummary=
warningSummary=
wanIface4=
wanIface6=
dnsmasqFile=
dnsmasqFileList=
ifaceMark=
ifaceTableID=
ifacePriority=
ifacesAll=
ifacesSupported=
firewallWanZone=
wanGW4=
wanGW6=
serviceStartTrigger=
processPolicyError=
processPolicyWarning=
resolver_set_supported=
policy_routing_nft_prev_param4=
policy_routing_nft_prev_param6=

# shellcheck disable=SC1091
. /lib/functions.sh
# shellcheck disable=SC1091
. /lib/functions/network.sh
# shellcheck disable=SC1091
. /usr/share/libubox/jshn.sh

output_ok() { output 1 "$_OK_"; output 2 "$__OK__\\n"; }
output_okn() { output 1 "$_OK_\\n"; output 2 "$__OK__\\n"; }
output_fail() { output 1 "$_FAIL_"; output 2 "$__FAIL__\\n"; }
output_failn() { output 1 "$_FAIL_\\n"; output 2 "$__FAIL__\\n"; }
# shellcheck disable=SC2317
str_replace() { printf "%b" "$1" | sed -e "s/$(printf "%b" "$2")/$(printf "%b" "$3")/g"; }
str_replace() { echo "${1//$2/$3}"; }
str_contains() { [ -n "$1" ] && [ -n "$2" ] && [ "${1//$2}" != "$1" ]; }
str_contains_word() { echo "$1" | grep -q -w "$2"; }
str_to_lower() { echo "$1" | tr 'A-Z' 'a-z'; }
str_to_upper() { echo "$1" | tr 'a-z' 'A-Z'; }
str_extras_to_underscore() { echo "$1" | tr '[\. ~`!@#$%^&*()\+/,<>?//;:]' '_'; }
str_extras_to_space() { echo "$1" | tr ';{}' ' '; }
debug() { local i j; for i in "$@"; do eval "j=\$$i"; echo "${i}: ${j} "; done; }
quiet_mode() {
	case "$1" in
		on) verbosity=0;;
		off) verbosity="$(uci get $packageName.config.verbosty)";;
	esac
}
output() {
# Target verbosity level with the first parameter being an integer
	is_integer() {
		case "$1" in
			(*[!0123456789]*) return 1;;
			('')              return 1;;
			(*)               return 0;;
		esac
	}
	local msg memmsg logmsg text
	local sharedMemoryOutput="/dev/shm/$packageName-output"
	if [ -z "$verbosity" ] && [ -n "$packageName" ]; then
		verbosity="$(uci -q get "$packageName.config.verbosity")"
	fi
	verbosity="${verbosity:-2}"
	if [ $# -ne 1 ] && is_integer "$1"; then
		if [ $((verbosity & $1)) -gt 0 ] || [ "$verbosity" = "$1" ]; then shift; text="$*"; else return 0; fi
	fi
	text="${text:-$*}";
	[ -t 1 ] && printf "%b" "$text"
	msg="${text//$serviceName /service }";
	if [ "$(printf "%b" "$msg" | wc -l)" -gt 0 ]; then
		[ -s "$sharedMemoryOutput" ] && memmsg="$(cat "$sharedMemoryOutput")"
		logmsg="$(printf "%b" "${memmsg}${msg}" | sed 's/\x1b\[[0-9;]*m//g')"
		logger -t "${packageName:-service} [$$]" "$(printf "%b" "$logmsg")"
		rm -f "$sharedMemoryOutput"
	else
		printf "%b" "$msg" >> "$sharedMemoryOutput"
	fi
}
_find_firewall_wan_zone() { [ "$(uci -q get "firewall.${1}.name")" = "wan" ] && firewallWanZone="$1"; }
_build_ifaces_all() { ifacesAll="${ifacesAll}${1} "; }
_build_ifaces_supported() { is_supported_interface "$1" && ! str_contains "$ifacesSupported" "$1" && ifacesSupported="${ifacesSupported}${1} "; }
pbr_find_iface() {
	local iface i param="$2"
	if [ -n "$procd_wan_interface" ] && [ "$param" = 'wan' ]; then
		iface="$procd_wan_interface"
	elif [ -n "$procd_wan6_interface" ] && [ "$param" = 'wan6' ]; then
		iface="$procd_wan6_interface"
	else
		"network_find_${param}" iface
		is_tunnel "$iface" && unset iface
		if [ -z "$iface" ]; then
			for i in $ifacesAll; do
				if "is_${param}" "$i"; then break; else unset i; fi
			done
		fi
	fi
	eval "$1"='${iface:-$i}'
}
pbr_get_gateway() {
	local iface="$2" dev="$3" gw
	network_get_gateway gw "$iface" true
	if [ -z "$gw" ] || [ "$gw" = '0.0.0.0' ]; then
#		gw="$(ubus call "network.interface.${iface}" status | jsonfilter -e "@.route[0].nexthop")"
		gw="$($ip_bin -4 a list dev "$dev" 2>/dev/null | grep inet | awk '{print $2}' | awk -F "/" '{print $1}')"
	fi
	eval "$1"='$gw'
}
pbr_get_gateway6() {
	local iface="$2" dev="$3" gw
	network_get_gateway6 gw "$iface" true
	if [ -z "$gw" ] || [ "$gw" = '::/0' ] || [ "$gw" = '::0/0' ] || [ "$gw" = '::' ]; then
		gw="$($ip_bin -6 a list dev "$dev" 2>/dev/null | grep inet6 | grep 'scope global' | awk '{print $2}')"
	fi
	eval "$1"='$gw'
}

# shellcheck disable=SC2016
is_bad_user_file_nft_call() { grep -q '"\$nft" list' "$1" || grep '"\$nft" -f' "$1";}
is_config_enabled() {
	_check_config() { local en; config_get_bool en "$1" 'enabled' 1; [ "$en" -gt 0 ] && _cfg_enabled=0; }
	local cfg="$1" _cfg_enabled=1
	[ -n "$1" ] || return 1
	config_load "$packageName"
	config_foreach _check_config "$cfg"
	return "$_cfg_enabled"
}
uci_get_device() { uci -q get "network.${1}.device" || uci -q get "network.${1}.dev"; }
uci_get_proto() { uci -q get "network.${1}.proto"; }
is_default_dev() { [ "$1" = "$($ip_bin -4 r | grep -m1 'dev' | grep -Eso 'dev [^ ]*' | awk '{print $2}')" ]; }
is_domain() { ! is_ipv6 "$1" && str_contains "$1" '[a-zA-Z]'; }
is_dslite() { local p; network_get_protocol p "$1"; [ "${p:0:6}" = "dslite" ]; }
is_family_mismatch() { ( is_ipv4_netmask "${1//!}" && is_ipv6 "${2//!}" ) || ( is_ipv6 "${1//!}" && is_ipv4_netmask "${2//!}" ); }
is_greater() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
is_greater_or_equal() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" = "$2"; }
is_ignored_interface() { str_contains_word "$ignored_interface" "$1"; }
is_ignore_target() { [ "$(str_to_lower "$1")" = 'ignore' ]; }
is_installed() { grep -q "Provides: ${1}" /usr/lib/opkg/status; }
is_ipset_type_supported() { ipset help hash:"$1" >/dev/null 2>&1; }
is_nft_mode() { [ -x "$nft" ] && ! str_contains "$resolver_set" 'ipset' && "$nft" list chains inet | grep -q "${nftPrefix}_prerouting"; }
is_ipv4() { expr "$1" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; }
is_ipv6() { ! is_mac_address "$1" && str_contains "$1" ':'; }
is_ipv6_global() { [ "${1:0:4}" = '2001' ]; }
is_ipv6_link_local() { [ "${1:0:4}" = 'fe80' ]; }
is_ipv6_unique_local() { [ "${1:0:2}" = 'fc' ] || [ "${1:0:2}" = 'fd' ]; }
is_list() { str_contains "$1" ',' || str_contains "$1" ' '; }
is_ipv4_netmask() { local ip="${1%/*}"; [ "$ip" != "$1" ] && is_ipv4 "$ip"; }
is_lan() { local d; network_get_device d "$1"; str_contains "$d" 'br-lan'; }
is_l2tp() { local p; network_get_protocol p "$1"; [ "${p:0:4}" = "l2tp" ]; }
is_mac_address() { expr "$1" : '[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]$' >/dev/null; }
is_netifd_table() { local iface="$1"; [ "$(uci -q get "network.${iface}.ip4table")" = "${packageName}_${iface%6}" ]; }
is_oc() { local p; network_get_protocol p "$1"; [ "${p:0:11}" = "openconnect" ]; }
is_ovpn() { local d; network_get_device d "$1"; [ "${d:0:3}" = "tun" ] || [ "${d:0:3}" = "tap" ] || [ -f "/sys/devices/virtual/net/${d}/tun_flags" ]; }
is_ovpn_valid() { local dev_net dev_ovpn; network_get_device dev_net "$1"; dev_ovpn="$(uci -q get "openvpn.${1}.dev")"; [ -n "$dev_net" ] && [ -n "$dev_ovpn" ] && [ "$dev_net" = "$dev_ovpn" ]; }
is_phys_dev() { [ "${1:0:1}" = "@" ] && ip l show | grep -E -q "^\\d+\\W+${1:1}"; }
is_present() { command -v "$1" >/dev/null 2>&1; }
is_service_running() { if is_nft_mode; then is_service_running_nft; else is_service_running_iptables; fi; }
is_service_running_iptables() { [ -x "$iptables" ] && "$iptables" -t mangle -L | grep -q "${iptPrefix}_PREROUTING" >/dev/null 2>&1; }
is_service_running_nft() { [ -x "$nft" ] && [ -n "$(get_mark_nft_chains)" ]; }
is_supported_iface_dev() { local n dev; for n in $ifacesSupported; do network_get_device dev "$n"; [ "$1" = "$dev" ] && return 0; done; return 1; }
is_supported_protocol() { grep -o '^[^#]*' /etc/protocols | grep -w -v '0' | grep . | awk '{print $1}' | grep -q "$1"; }
is_pptp() { local p; network_get_protocol p "$1"; [ "${p:0:4}" = "pptp" ]; }
is_softether() { local d; network_get_device d "$1"; [ "${d:0:4}" = "vpn_" ]; }
is_supported_interface() { is_lan "$1" && return 1; str_contains_word "$supported_interface" "$1" || { ! is_ignored_interface "$1" && { is_wan "$1" || is_wan6 "$1" || is_tunnel "$1"; }; } || is_ignore_target "$1" || is_xray "$1"; }
is_tailscale() { local d; network_get_device d "$1"; [ "${d:0:9}" = "tailscale" ]; }
is_tor() { [ "$(str_to_lower "$1")" = "tor" ]; }
is_tor_running() {
	local ret=0
	is_ignored_interface 'tor' && return 1
	[ -s "$torConfigFile" ] || return 1
	json_load "$(ubus call service list "{ 'name': 'tor' }")" >/dev/null || return 1
	json_select 'tor' >/dev/null || return 1
	json_select 'instances' >/dev/null || return 1
	json_select 'instance1' >/dev/null || return 1
	json_get_var ret 'running' >/dev/null || return 1
	json_cleanup
	if [ "$ret" = "0" ]; then return 1; else return 0; fi
}
is_tunnel() { is_dslite "$1" || is_l2tp "$1" || is_oc "$1" || is_ovpn "$1" || is_pptp "$1" || is_softether "$1" || is_tailscale "$1" || is_tor "$1" || is_wg "$1"; }
is_url() { is_url_file "$1" || is_url_dl "$1"; }
is_url_dl() { is_url_ftp "$1" || is_url_http "$1" || is_url_https "$1"; }
is_url_file() { [ "$1" != "${1#file://}" ];}
is_url_ftp() { [ "$1" != "${1#ftp://}" ];}
is_url_http() { [ "$1" != "${1#http://}" ];}
is_url_https() { [ "$1" != "${1#https://}" ];}
is_wan() { [ "$1" = "$wanIface4" ] || { [ "${1##wan}" != "$1" ] && [ "${1##wan6}" = "$1" ]; } || [ "${1%%wan}" != "$1" ]; }
is_wan6() { [ -n "$wanIface6" ] && [ "$1" = "$wanIface6" ] || [ "${1/#wan6}" != "$1" ] || [ "${1/%wan6}" != "$1" ]; }
is_wg() { local p lp; network_get_protocol p "$1"; get_listen_port lp "$1"; [ -z "$lp" ] && [ "${p:0:9}" = "wireguard" ]; }
is_xray() { [ -n "$(get_xray_traffic_port "$1")" ]; }
dnsmasq_kill() { killall -q -s HUP dnsmasq; }
dnsmasq_restart() { output 3 'Restarting dnsmasq '; if /etc/init.d/dnsmasq restart >/dev/null 2>&1; then output_okn; else output_failn; fi; }
get_listen_port() {
	local __tmp
	__tmp="$1=$(uci -q get "network.${2}.listen_port")"
	[ -z "$__tmp" ] && unset "$1" && return 1
	eval "$__tmp"
}
# shellcheck disable=SC2155
get_ss_traffic_ports() { local i="$(jsonfilter -i "$ssConfigFile" -q -e "@.inbounds[*].port")"; echo "${i:-443}"; }
# shellcheck disable=SC2155
get_tor_dns_port() { local i="$(grep -m1 DNSPort "$torConfigFile" | awk -F: '{print $2}')"; echo "${i:-9053}"; }
# shellcheck disable=SC2155
get_tor_traffic_port() { local i="$(grep -m1 TransPort "$torConfigFile" | awk -F: '{print $2}')"; echo "${i:-9040}"; }
get_xray_traffic_port() { local i="${1//$xrayIfacePrefix}"; [ "$i" = "$1" ] && unset i; echo "$i"; }
get_rt_tables_id() { local iface="$1"; grep "${ipTablePrefix}_${iface}\$" '/etc/iproute2/rt_tables' | awk '{print $1;}'; }
get_rt_tables_next_id() { echo "$(($(sort -r -n '/etc/iproute2/rt_tables' | grep -o -E -m 1 "^[0-9]+")+1))"; }
get_rt_tables_non_pbr_next_id() { echo "$(($(grep -v "${ipTablePrefix}_" '/etc/iproute2/rt_tables' | sort -r -n  | grep -o -E -m 1 "^[0-9]+")+1))"; }
# shellcheck disable=SC2016
resolveip_to_ipt() { resolveip "$@" | sed -n 'H;${x;s/\n/,/g;s/^,//;p;};d'; }
resolveip_to_ipt4() { resolveip_to_ipt -4 "$@"; }
resolveip_to_ipt6() { [ -n "$ipv6_enabled" ] && resolveip_to_ipt -6 "$@"; }
# shellcheck disable=SC2016
resolveip_to_nftset() { resolveip "$@" | sed -n 'H;${x;s/\n/,/g;s/^,//;p;};d' | tr '\n' ' '; }
resolveip_to_nftset4() { resolveip_to_nftset -4 "$@"; }
resolveip_to_nftset6() { [ -n "$ipv6_enabled" ] && resolveip_to_nftset -6 "$@"; }
# shellcheck disable=SC2016
ipv4_leases_to_nftset() { [ -s '/tmp/dhcp.leases' ] || return 1; grep "$1" '/tmp/dhcp.leases' | awk '{print $3}' | sed -n 'H;${x;s/\n/,/g;s/^,//;p;};d' | tr '\n' ' '; }
# shellcheck disable=SC2016
ipv6_leases_to_nftset() { [ -s '/tmp/hosts/odhcpd' ] || return 1; grep -v '^#' '/tmp/hosts/odhcpd' | grep "$1" | awk '{print $1}' | sed -n 'H;${x;s/\n/,/g;s/^,//;p;};d' | tr '\n' ' '; }
# shellcheck disable=SC3037
ports_to_nftset() { echo -ne "$1"; }
get_mark_ipt_chains() { [ -n "$(command -v iptables-save)" ] && iptables-save | grep ":${iptPrefix}_MARK_" | awk '{ print $1 }' | sed 's/://'; }
get_mark_nft_chains() { [ -x "$nft" ] && "$nft" list table inet "$nftTable" 2>/dev/null | grep chain | grep "${nftPrefix}_mark_" | awk '{ print $2 }'; }
get_ipsets() { [ -x "$(command -v ipset)" ] && ipset list | grep "${ipsPrefix}_" | awk '{ print $2 }'; }
get_nft_sets() { [ -x "$nft" ] && "$nft" list table inet "$nftTable" 2>/dev/null | grep 'set' | grep "${nftPrefix}_" | awk '{ print $2 }'; }
__ubus_get() { ubus call service list "{ 'name': '$packageName' }" | jsonfilter -e "$1"; }
ubus_get_status() { __ubus_get "@.${packageName}.instances.main.data.status.${1}"; }
ubus_get_interface() { __ubus_get "@.${packageName}.instances.main.data.gateways[@.name='${1}']${2:+.$2}"; }
ubus_get_gateways() { __ubus_get "@.${packageName}.instances.main.data.gateways"; }

# luci app specific
is_enabled() { uci -q get "${1}.config.enabled"; }
is_running_iptables() { iptables -t mangle -L | grep -q PBR_PREROUTING >/dev/null 2>&1; }
is_running_nft_file() { [ -s "$nftPermFile" ]; }
is_running_nft() { "$nft" list table inet fw4 | grep chain | grep -q pbr_mark_ >/dev/null 2>&1; }
is_running() { is_running_iptables || is_running_nft; }
check_ipset() { { [ -n "$ipset" ] && "$ipset" help hash:net; } >/dev/null 2>&1; }
check_nft() { [ -n "$nft" ]; }
check_agh() { [ -n "$agh" ] && [ -s "$aghConfigFile" ]; }
check_dnsmasq() { command -v dnsmasq >/dev/null 2>&1; }
check_unbound() { command -v unbound >/dev/null 2>&1; }
check_agh_ipset() {
	check_ipset || return 1
	check_agh || return 1
	is_greater_or_equal "$($agh --version | sed 's|AdGuard Home, version v\(.*\)|\1|' | sed 's|-.*||')" '0.107.13'
}
check_dnsmasq_ipset() {
	local o;
	check_ipset || return 1
	check_dnsmasq || return 1
	o="$(dnsmasq -v 2>/dev/null)"
	! echo "$o" | grep -q 'no-ipset' && echo "$o" | grep -q 'ipset'
}
check_dnsmasq_nftset() {
	local o;
	check_nft || return 1
	check_dnsmasq || return 1
	o="$(dnsmasq -v 2>/dev/null)"
	! echo "$o" | grep -q 'no-nftset' && echo "$o" | grep -q 'nftset'
}
print_json_bool() { json_init; json_add_boolean "$1" "$2"; json_dump; json_cleanup; }
print_json_string() { json_init; json_add_string "$1" "$2"; json_dump; json_cleanup; }
opkg_get_version() { grep -m1 -A1 "Package: $1$" '/usr/lib/opkg/status' | grep -m1 'Version: ' | sed 's|Version: \(.*\)|\1|'; }

#!/bin/sh
# shellcheck disable=SC1091,SC2039,SC2034

[ -n "$INCLUDE_ONLY" ] || {
. /etc/functions.sh
. ../netifd-proto.sh
init_proto "$@"
}

proto_nebula_init_config() {
	proto_config_add_string "config"
	available=1
	no_proto_task=1
}

proto_nebula_setup() {
	local config="$1" address addresses
	/etc/init.d/nebula start "$config"
	proto_init_update "$config" 1
	addresses="$(ip -4 a list dev "$config" | grep inet | awk '{print $2}')"
	for address in ${addresses}; do
		case "${address}" in
			*:*/*)
				proto_add_ipv6_address "${address%%/*}" "${address##*/}"
				;;
			*.*/*)
				proto_add_ipv4_address "${address%%/*}" "${address##*/}"
				;;
			*:*)
				proto_add_ipv6_address "${address%%/*}" "128"
				;;
			*.*)
				proto_add_ipv4_address "${address%%/*}" "32"
				;;
		esac
	done
	proto_send_update "$config" 1
}

proto_nebula_teardown() {
	local config="$1"
	/etc/init.d/nebula stop "$config"
}

[ -n "$INCLUDE_ONLY" ] || add_protocol nebula

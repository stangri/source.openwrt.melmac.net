# VPN Policy-Based Routing

## Description

This service allows you to define rules (policies) for routing traffic via WAN or your L2TP, Openconnect, OpenVPN, PPTP or Wireguard tunnels. Policies can be set based on any combination of local/remote ports, local/remote IPv4 or IPv6 addresses/subnets or domains. This service supersedes the [VPN Bypass](https://github.com/openwrt/packages/blob/master/net/vpnbypass/files/README.md) service, by supporting IPv6 and by allowing you to set explicit rules not just for WAN interface (bypassing OpenVPN tunnel), but for L2TP, Openconnect, OpenVPN, PPTP and Wireguard tunnels as well.

## Features

### Gateways/Tunnels

- Any policy can target either WAN or a VPN tunnel interface.
- L2TP tunnels supported (with protocol names l2tp\*).
- Openconnect tunnels supported (with protocol names openconnect\*).
- OpenVPN tunnels supported (with device names tun\* or tap\*).
- PPTP tunnels supported (with protocol names pptp\*).
- Wireguard tunnels supported (with protocol names wireguard\*).

### IPv4/IPv6/Port-Based Policies

- Policies based on local names, IPs or subnets. You can specify a single IP (as in ```192.168.1.70```) or a local subnet (as in ```192.168.1.81/29```) or a local device name (as in ```nexusplayer```). IPv6 addresses are also supported.
- Policies based on local ports numbers. Can be set as an individual port number (```32400```), a range (```5060-5061```), a space-separated list (```80 8080```) or a combination of the above (```80 8080 5060-5061```). Limited to 15 space-separated entries per policy.
- Policies based on remote IPs/subnets or domain names. Same format/syntax as local IPs/subnets.
- Policies based on remote ports numbers. Same format/syntax and restrictions as local ports.
- You can mix the IP addresses/subnets and device (or domain) names in one field separating them by space (like this: ```66.220.2.74 he.net tunnelbroker.net```).

### DSCP Tag-Based Policies

You can also set policies for traffic with specific DSCP tag. On Windows 10, for example, you can mark traffic from specific apps with DSCP tags (instructions for tagging specific app traffic in Windows 10 can be found [here](http://serverfault.com/questions/769843/cannot-set-dscp-on-windows-10-pro-via-group-policy)).

### Strict enforcement

- Supports strict policy enforcement, even if the policy interface is down -- resulting in network being unreachable for specific policy (enabled by default).

### Use DNSMASQ ipset

- Service can be set to utilize ```dnsmasq```'s ```ipset``` support. This requires the ```dnsmasq-full``` to be installed (see [How to install dnsmasq-full](#how-to-install-dnsmasq-full)) and it significantly improves the start up time because ```dnsmasq``` resolves the domain names and adds them to appropriate ```ipset``` in background. Another benefit of using ```dnsmasq```'s ```ipset``` is that it also automatically adds third-level domains to the ```ipset```: if ```domain.com``` is added to the policy, this policy will affect all ```*.domain.com``` subdomains. This also works for top-level domains as well, a policy targeting the ```at``` for example, will affect all the ```*.at``` domains.

### Customization

- Can be fully configured with ```uci``` commands or by editing ```/etc/config/vpn-policy-routing``` file.
- Has a companion package (```luci-app-vpn-policy-routing```) so policies can be configured with Web UI.

### Other Features

- Doesn't stay in memory, creates the routing tables and ```iptables``` rules/```ipset``` entries which are automatically updated when supported/monitored interface changes.
- Proudly made in Canada, using locally-sourced electrons.

## Screenshot (luci-app-vpn-policy-routing)

Basic Settings
![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/vpn-policy-routing/screenshot03-basic.png "screenshot")
Advanced Settings
![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/vpn-policy-routing/screenshot03-advanced.png "screenshot")

## How it works

On start, this service creates routing tables for each supported interface (WAN/WAN6 and VPN tunnels) which are used to route specially marked packets. Service adds new ```VPR_PREROUTING``` chain in the ```mangle``` table's ```PREROUTING``` chain (can be optionally set to create chains in the ```FORWARD```, ```INPUT``` and ```OUTPUT``` chains of ```mangle``` table, see [Additional settings](#additional-settings) for details). Evaluation and marking of packets happens in the ```VPR_PREROUTING``` (and if enabled, also in ```VPR_FORWARD```, ```VPR_INPUT``` and ```VPR_OUTPUT```) chains. If enabled, the service also creates the ```ipset``` per each supported interface and the corresponding ```iptables``` rule for marking packets matching the ```ipset```. The service then processes the user-created policies.

### Processing Policies

Each policy can result in either a new ```iptables``` rule or, if ```ipset``` or use of ```dnsmasq``` are enabled, an ```ipset``` or a ```dnsmasq```'s ```ipset``` entry.

- Policies with local IP addresses or local device names are always created as ```iptables``` rules.
- Policies with local or remote ports are always created as ```iptables``` rules.
- Policies with local or remote netmasks are always created as ```iptables``` rules.
- Policies with **only** remote IP address or a domain name are created as ```dnsmasq```'s ```ipset``` or an ```ipset``` (if enabled).

### Policies Priorities

- If support for ```dnsmasq```'s ```ipset``` and ```ipset``` is disabled, then only ```iptables``` rules are created. The policy priority is the same as its order as listed in Web UI and ```/etc/config/vpn-policy-routing```. The higher the policy is in the Web UI and configuration file, the higher its priority is.
- If support for ```dnsmasq```'s ```ipset``` and ```ipset``` is enabled, then the ```ipset``` entries have the highest priority (irrelevant of their position in the policies list) and the other policies are processed in the same order as they are listed in Web UI and ```/etc/config/vpn-policy-routing```.
- If there are conflicting ```ipset``` entries for different interfaces, the priority is given to the interface which is listed first in the ```/etc/config/network``` file.
- If set, the ```DSCP``` policies trump all other policies, including ```ipset``` ones.

## How to install

Please make sure that the [requirements](#requirements) are satisfied and install ```vpn-policy-routing``` and ```luci-app-vpn-policy-routing``` from Web UI or connect to your router via ssh and run the following commands:

```sh
opkg update
opkg install vpn-policy-routing luci-app-vpn-policy-routing
```

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router) first.OpenWrt

## Requirements

This service requires the following packages to be installed on your router: ```ipset```, ```resolveip```, ```ip-full``` (or a ```busybox``` built with ```ip``` support), ```kmod-ipt-ipset``` and ```iptables```.

To satisfy the requirements, connect to your router via ssh and run the following commands:

```sh
opkg update; opkg install ipset resolveip ip-full kmod-ipt-ipset iptables
```

### How to install dnsmasq-full

If you want to use ```dnsmasq```'s ```ipset``` support, you will need to install ```dnsmasq-full``` instead of the ```dnsmasq```. To do that, connect to your router via ssh and run the following command:

```sh
opkg update; opkg remove dnsmasq; opkg install dnsmasq-full
```

### Unmet dependencies

If you are running a development (trunk/snapshot) build of OpenWrt on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current OpenWrt release image or current development/snapshot image.

## Default Settings

Default configuration has service disabled (use Web UI to enable/start service or run ```uci set vpn-policy-routing.config.enabled=1; uci commit vpn-policy-routing;```).

## Additional settings

In the Web UI the ```vpn-policy-routing``` settings are split into ```basic``` and ```advanced``` settings. The full list of configuration parameters of ```vpn-policy-routing.config``` section is:

|Web UI Section|Parameter|Type|Default|Description|
| --- | --- | --- | --- | --- |
|Basic|enabled|boolean|0|Enable/disable the ```vpn-policy-routing``` service.|
|Basic|verbosity|integer|2|Can be set to 0, 1 or 2 to control the console and system log output verbosity of the ```vpn-policy-routing``` service.|
|Basic|strict_enforcement|boolean|1|Enforce policies when their interface is down. See [Strict enforcement](#strict-enforcement) for more details.|
|Basic|remote_ipset|string|none|Enable/disable use of one of the ipset options for compatible remote policies (policies with only a remote hostname and no other fields set). This speeds up service start-up and operation. Currently supported options are ```none```,  ```ipset``` and ```dnsmasq.ipset``` (see [Use DNSMASQ ipset](#use-dnsmasq-ipset) for more details). Make sure the [requirements](#requirements) are met.|
|Basic|local_ipset|boolean|0|Enable/disable use of ```ipset``` entries for compatible local policies (policies with only a local IP address or MAC address and no other fields set). Using ```ipset``` for local IPs/MACs is faster than using ```iptables``` rules, however it makes it impossible to enforce policies priority/order. Make sure the [requirements](#requirements) are met.|
|Basic|ipv6_enabled|boolean|0|Enable/disable IPv6 support.|
|Advanced|supported_interface|list/string||Allows to specify the space-separated list of interface names (in lower case) to be explicitly supported by the ```vpn-policy-routing``` service. Can be useful if your OpenVPN tunnels have dev option other than tun\* or tap\*.|
|Advanced|ignored_interface|list/string||Allows to specify the space-separated list of interface names (in lower case) to be ignored by the ```vpn-policy-routing``` service. Can be useful if running both VPN server and VPN client on the router.|
|Advanced|boot_timeout|number|30|Allows to specify the time (in seconds) for ```vpn-policy-routing``` service to wait for WAN gateway discovery on boot. Can be useful on devices with ADSL modem built in.|
|Advanced|iptables_rule_option|append/insert|append|Allows to specify the iptables parameter for rules: ```-A``` for ```append``` and ```-I``` for ```insert```. Append is generally speaking more compatible with other packages/firewall rules. Recommended to change to ```insert``` only to improve compatibility with the ```mwan3``` package.|
|Advanced|iprule_enabled|boolean|0|Add an ```ip rule```, not an ```iptables``` entry for policies with just the local address. Use with caution to manipulate policies priorities.|
|Advanced|icmp_interface|string||Set the default ICMP protocol interface (interface name in lower case). Use with caution.|
|Advanced|append_local_rules|string||Append local IP Tables rules. Can be used to exclude local IP addresses from destinations for policies with local address set.|
|Advanced|append_remote_rules|string||Append local IP Tables rules. Can be used to exclude remote IP addresses from sources for policies with remote address set.|
|Advanced|wan_tid|integer|201|Starting (WAN) Table ID number for tables created by the ```vpn-policy-routing``` service.|
|Advanced|wan_mark|hexadecimal|0x010000|Starting (WAN) fw mark for marks used by the ```vpn-policy-routing``` service. High starting mark is used to avoid conflict with SQM/QoS, this can be changed by user. Change with caution together with ```fw_mask```.|
|Advanced|fw_mask|hexadecimal|0xff0000|FW Mask used by the ```vpn-policy-routing``` service. High mask is used to avoid conflict with SQM/QoS, this can be changed by user. Change with caution together with ```wan_mark```.|
|Web UI|webui_enable_column|boolean|0|Shows ```Enable``` checkbox column for policies, allowing to quickly enable/disable specific policy without deleting it.|
|Web UI|webui_protocol_column|boolean|0|Shows ```Protocol``` column for policies, allowing to specify the protocol for ```iptables``` rules for policies.|
|Web UI|webui_supported_protocol|list|0|List of protocols to display in the ```Protocol``` column for policies.|
|Web UI|webui_chain_column|boolean|0|Shows ```Chain``` column for policies, allowing to specify ```PREROUTING``` (default), ```FORWARD```, ```INPUT```, or ```OUTPUT``` chain for ```iptables``` rules for policies.|
|Web UI|webui_sorting|boolean|1|Shows the Up/Down buttons for policies, allowing you to move a policy up or down in the list/priority.|
||wan_dscp|integer||Allows use of [DSCP-tag based policies](#dscp-tag-based-policies) for WAN interface.|
||{interface_name}_dscp|integer||Allows use of [DSCP-tag based policies](#dscp-tag-based-policies) for a VPN interface.|

### Policy Options

Each policy may have a combination of the options below, please note that the ```name``` and ```interface```  options are required.

|Option|Default|Description|
| --- | --- | --- |
|name||Policy name, it **must** be set.|
|enabled|1|Enable/disable policy. To display the ```Enable``` checkbox column for policies in the WebUI, make sure to select ```Enabled``` for ```Show Enable Column``` in the ```Web UI``` tab.|
|interface||Policy interface, it **must** be set.|
|local_address||List of space-separated local/source IP addresses, CIDRs, hostnames or mac addresses (colon-separated). You can also specify a local interface (like a specially created wlan) prepended by an ```@``` symbol.|
|local_port||List of space-separated local/source ports or port-ranges.|
|remote_address||List of space-separated remote/target IP addresses, CIDRs or hostnames/domain names.|
|remote_port||List of space-separated remote/target ports or port-ranges.|
|proto|all|Policy protocol, can be any valid protocol from ```/etc/protocols``` for CLI/uci or can be selected from the values set in ```webui_supported_protocol```. To display the ```Protocol``` column for policies in the WebUI, make sure to select ```Enabled``` for ```Show Protocol Column``` in the ```Web UI``` tab.|
|chain|PREROUTING|Policy chain, can be either ```PREROUTING```, ```FORWARDING```, ```INPUT``` or ```OUTPUT```. This setting is case-sensitive. To display the ```Chain``` column for policies in the WebUI, make sure to select ```Enabled``` for ```Show Chain Column``` in the ```Web UI``` tab.|

### Example Policies

#### Single IP, IP Range, Local Machine, Local MAC Address

The following policies route traffic from a single IP address, a range of IP addresses or a local machine (requires definition as DHCP host record in DHCP config) via WAN.

```text
config policy
  option name 'Local IP'
  option interface 'wan'
  option local_address '192.168.1.70'

config policy
  option name 'Local Subnet'
  option interface 'wan'
  option local_address '192.168.1.81/29'

config policy
  option name 'Local Machine'
  option interface 'wan'
  option local_address 'dell-ubuntu'

config policy
  option name 'Local MAC Address'
  option interface 'wan'
  option local_address '00:0F:EA:91:04:08'
```

#### Logmein Hamachi

The following policy routes LogMeIn Hamachi zero-setup VPN traffic via WAN.

```text
config policy
  option name 'LogmeIn Hamachi'
  option interface 'wan'
  option remote_address '25.0.0.0/8 hamachi.cc hamachi.com logmein.com'
```

#### SIP Port

The following policy routes standard SIP port traffic via WAN for both TCP and UDP protocols.

```text
config policy
  option name 'SIP Ports'
  option interface 'wan'
  option remote_port '5060'
  option proto 'tcp udp'
```

#### Plex Media Server

The following policies route Plex Media Server traffic via WAN. Please note, you'd still need to open the port in the firewall either manually or with the UPnP.

```text
config policy
  option name 'Plex Local Server'
  option interface 'wan'
  option local_port '32400'

config policy
  option name 'Plex Remote Servers'
  option interface 'wan'
  option remote_address 'plex.tv my.plexapp.com'
```

#### Emby Media Server

The following policy route Emby traffic via WAN. Please note, you'd still need to open the port in the firewall either manually or with the UPnP.

```text
config policy
  option name 'Emby Local Server'
  option interface 'wan'
  option local_port '8096 8920'

config policy
  option name 'Emby Remote Servers'
  option interface 'wan'
  option remote_address 'emby.media app.emby.media tv.emby.media'
```

#### Local OpenVPN Server + OpenVPN Client (Scenario 1)

If the OpenVPN client on your router is used as default routing (for the whole internet), make sure your settings are as following (three dots on the line imply other options can be listed in the section as well).

Relevant part of ```/etc/config/vpn-policy-routing```:

```text
config vpn-policy-routing 'config'
  list ignored_interface 'vpnserver'
  ...

config policy
  option name 'OpenVPN Server'
  option interface 'wan'
  option proto 'tcp'
  option local_port '1194'
  option chain 'OUTPUT'
```

The network/firewall/openvpn settings are below.

Relevant part of ```/etc/config/network``` (**DO NOT** modify default OpenWrt network settings for neither ```wan``` nor ```lan```):

```text
config interface 'vpnclient'
  option proto 'none'
  option ifname 'ovpnc0'

config interface 'vpnserver'
  option proto 'none'
  option ifname 'ovpns0'
  option auto '1'
```

Relevant part of ```/etc/config/firewall``` (**DO NOT** modify default OpenWrt firewall settings for neither ```wan``` nor ```lan```):

```text
config zone
  option name 'vpnclient'
  option network 'vpnclient'
  option input 'REJECT'
  option forward 'ACCEPT'
  option output 'REJECT'
  option masq '1'
  option mtu_fix '1'

config forwarding
  option src 'lan'
  option dest 'vpnclient'

config zone
  option name 'vpnserver'
  option network 'vpnserver'
  option input 'ACCEPT'
  option forward 'REJECT'
  option output 'ACCEPT'
  option masq '1'

config forwarding
  option src 'vpnserver'
  option dest 'wan'

config forwarding
  option src 'vpnserver'
  option dest 'lan'

config forwarding
  option src 'vpnserver'
  option dest 'vpnclient'

config rule
  option name 'Allow-OpenVPN-Inbound'
  option target 'ACCEPT'
  option src '*'
  option proto 'tcp'
  option dest_port '1194'
```

Relevant part of ```/etc/config/openvpn```:

```text
config openvpn 'vpnclient'
  option client '1'
  option dev_type 'tun'
  option dev 'ovpnc0'
  option proto 'udp'
  option remote 'some.domain.com 1197' # DO NOT USE PORT 1194 for VPN Client

config openvpn 'vpnserver'
  option port '1194'
  option proto 'tcp'
  option server '192.168.200.0 255.255.255.0'
```

#### Local OpenVPN Server + OpenVPN Client (Scenario 2)

If the OpenVPN client is **not** used as default routing and you create policies to selectively use the OpenVPN client, make sure your settings are as following (three dots on the line imply other options can be listed in the section as well).

Relevant part of ```/etc/config/vpn-policy-routing```:

```text
config vpn-policy-routing 'config'
  list ignored_interface 'vpnserver'
  option append_local_rules '! -d 192.168.200.0/24'
  ...
```

The network/firewall/openvpn settings are below.

Relevant part of ```/etc/config/network``` (**DO NOT** modify default OpenWrt network settings for neither ```wan``` nor ```lan```):

```text
config interface 'vpnclient'
  option proto 'none'
  option ifname 'ovpnc0'

config interface 'vpnserver'
  option proto 'none'
  option ifname 'ovpns0'
  option auto '1'
```

Relevant part of ```/etc/config/firewall``` (**DO NOT** modify default OpenWrt firewall settings for neither ```wan``` nor ```lan```):

```text
config zone
  option name 'vpnclient'
  option network 'vpnclient'
  option input 'REJECT'
  option forward 'ACCEPT'
  option output 'REJECT'
  option masq '1'
  option mtu_fix '1'

config forwarding
  option src 'lan'
  option dest 'vpnclient'

config zone
  option name 'vpnserver'
  option network 'vpnserver'
  option input 'ACCEPT'
  option forward 'REJECT'
  option output 'ACCEPT'
  option masq '1'

config forwarding
  option src 'vpnserver'
  option dest 'wan'

config forwarding
  option src 'vpnserver'
  option dest 'lan'

config forwarding
  option src 'vpnserver'
  option dest 'vpnclient'

config rule
  option name 'Allow-OpenVPN-Inbound'
  option target 'ACCEPT'
  option src '*'
  option proto 'tcp'
  option dest_port '1194'
```

Relevant part of ```/etc/config/openvpn```:

```text
config openvpn 'vpnclient'
  option client '1'
  option dev_type 'tun'
  option dev 'ovpnc0'
  option proto 'udp'
  option remote 'some.domain.com 1197' # DO NOT USE PORT 1194 for VPN Client
  list pull_filter 'ignore "redirect-gateway"' # for OpenVPN 2.4 and later
  option route_nopull '1' # for OpenVPN earlier than 2.4

config openvpn 'vpnserver'
  option port '1194'
  option proto 'tcp'
  option server '192.168.200.0 255.255.255.0'
```

#### Local Wireguard Server + Wireguard Client (Scenario 1)

Yes, I'm aware that technically there are no clients nor servers in Wireguard, it's all peers, but for the sake of README readability I will use the terminology similar to the OpenVPN Server + Client setups.

If the Wireguard tunnel on your router is used as default routing (for the whole internet), make sure your settings are as following (three dots on the line imply other options can be listed in the section as well).

Relevant part of ```/etc/config/vpn-policy-routing```:

```text
config vpn-policy-routing 'config'
  list ignored_interface 'wgserver'

config policy
  option name 'Wireguard Server'
  option interface 'wan'
  option proto 'tcp'
  option local_port '61820'
  option chain 'OUTPUT'
```

The recommended network/firewall settings are below.

Relevant part of ```/etc/config/network``` (**DO NOT** modify default OpenWrt network settings for neither ```wan``` nor ```lan```):

```text
config interface 'wgclient'
  option proto 'wireguard'
  ...

config wireguard_wgclient
  list allowed_ips '0.0.0.0/0'
  list allowed_ips '::0/0'
  option endpoint_port '51820'
  option route_allowed_ips '1'
  ...

config interface 'wgserver'
  option proto 'wireguard'
  option listen_port '61820'
  list addresses '192.168.200.1'
  ...

config wireguard_wgserver
  list allowed_ips '192.168.200.0/24'
  option route_allowed_ips '1'
  ...
```

Relevant part of ```/etc/config/firewall``` (**DO NOT** modify default OpenWrt firewall settings for neither ```wan``` nor ```lan```):

```text
config zone
  option name 'wgclient'
  option network 'wgclient'
  option input 'REJECT'
  option forward 'ACCEPT'
  option output 'REJECT'
  option masq '1'
  option mtu_fix '1'

config forwarding
  option src 'lan'
  option dest 'wgclient'

config zone
  option name 'wgserver'
  option network 'wgserver'
  option input 'ACCEPT'
  option forward 'REJECT'
  option output 'ACCEPT'
  option masq '1'

config forwarding
  option src 'wgserver'
  option dest 'wan'

config forwarding
  option src 'wgserver'
  option dest 'lan'

config forwarding
  option src 'wgserver'
  option dest 'wgclient'

config rule
  option name 'Allow-WG-Inbound'
  option target 'ACCEPT'
  option src '*'
  option proto 'tcp'
  option dest_port '61820'
```

#### Local Wireguard Server + Wireguard Client (Scenario 2)

Yes, I'm aware that technically there are no clients nor servers in Wireguard, it's all peers, but for the sake of README readability I will use the terminology similar to the OpenVPN Server + Client setups.

If the Wireguard client is **not** used as default routing and you create policies to selectively use the Wireguard client, make sure your settings are as following (three dots on the line imply other options can be listed in the section as well).

Relevant part of ```/etc/config/vpn-policy-routing```:

```text
config vpn-policy-routing 'config'
  list ignored_interface 'wgserver'
  option append_local_rules '! -d 192.168.200.0/24'
```

The recommended network/firewall settings are below.

Relevant part of ```/etc/config/network``` (**DO NOT** modify default OpenWrt network settings for neither ```wan``` nor ```lan```):

```text
config interface 'wgclient'
  option proto 'wireguard'
  ...

config wireguard_wgclient
  list allowed_ips '0.0.0.0/0'
  list allowed_ips '::0/0'
  option endpoint_port '51820'
  option route_allowed_ips '1'
  ...

config interface 'wgserver'
  option proto 'wireguard'
  option listen_port '61820'
  list addresses '192.168.200.1'
  ...

config wireguard_wgserver
  list allowed_ips '192.168.200.0/24'
  option route_allowed_ips '1'
  ...
```

Relevant part of ```/etc/config/firewall``` (**DO NOT** modify default OpenWrt firewall settings for neither ```wan``` nor ```lan```):

```text
config zone
  option name 'wgclient'
  option network 'wgclient'
  option input 'REJECT'
  option forward 'ACCEPT'
  option output 'REJECT'
  option masq '1'
  option mtu_fix '1'

config forwarding
  option src 'lan'
  option dest 'wgclient'

config zone
  option name 'wgserver'
  option network 'wgserver'
  option input 'ACCEPT'
  option forward 'REJECT'
  option output 'ACCEPT'
  option masq '1'

config forwarding
  option src 'wgserver'
  option dest 'wan'

config forwarding
  option src 'wgserver'
  option dest 'lan'

config forwarding
  option src 'wgserver'
  option dest 'wgclient'

config rule
  option name 'Allow-WG-Inbound'
  option target 'ACCEPT'
  option src '*'
  option proto 'tcp'
  option dest_port '61820'
```

#### Netflix Domains

The following policy should route US Netflix traffic via WAN. For capturing international Netflix domain names, you can refer to [these getdomainnames.sh-specific instructions](https://github.com/Xentrk/netflix-vpn-bypass#ipset_netflix_domainssh) and don't forget to adjust them for OpenWrt. This may not work if Netflix changes things. For more reliable US Netflix routing you may want to consider using [custom user files](#custom-user-files).

```text
config policy
  option name 'Netflix Domains'
  option interface 'wan'
  option remote_address 'amazonaws.com netflix.com nflxext.com nflximg.net nflxso.net nflxvideo.net dvd.netflix.com'
```

### Custom User Files

If the custom user file includes are set, the service will load and execute them after setting up ip tables and ipsets, processing policies and before restarting ```dnsmasq```. This allows, for example, to add large numbers of domains/IP addresses to ipsets without manually adding all of them to the config file.

Two example custom user-files are provided: ```/etc/vpn-policy-routing.aws.user``` and ```/etc/vpn-policy-routing.netflix.user```. They are provided to pull the AWS and Netflix IP addresses into the ```wan``` ipset respectively.

#### Custom User Files Include Options

|Option|Default|Description|
| --- | --- | --- |
|path||Path to a custom user file (in a form of shell script), it **must** be set.|
|enabled|1|Enable/disable setting.|

#### Example Includes

```text
config include
  option path '/etc/vpn-policy-routing.netflix.user'

config include
  option path '/etc/vpn-policy-routing.aws.user'
```

### Multiple OpenVPN Clients

If you use multiple OpenVPN clients on your router, the order in which their devices are named (tun0, tun1, etc) is not guaranteed by OpenWrt/LEDE Project. The following settings are recommended in this case.

For ```/etc/config/network```:

```text
config interface 'vpnclient0'
  option proto 'none'
  option ifname 'ovpnc0'

config interface 'vpnclient1'
  option proto 'none'
  option ifname 'ovpnc1'
```

For ```/etc/config/openvpn```:

```text
config openvpn 'vpnclient0'
  option client '1'
  option dev_type 'tun'
  option dev 'ovpnc0'
  ...

config openvpn 'vpnclient1'
  option client '1'
  option dev_type 'tun'
  option dev 'ovpnc1'
  ...
```

For ```/etc/config/vpn-policy-routing```:

```text
config vpn-policy-routing 'config'
  list supported_interface 'vpnclient0 vpnclient1'
  ...
```

## Discussion

Please head to [OpenWrt Forum](https://forum.openwrt.org/t/vpn-policy-based-routing-web-ui-discussion/10389) for discussions of this service.

## Getting help

If things are not working as intended, please include the following in your post:

- content of ```/etc/config/vpn-policy-routing```
- the output of ```/etc/init.d/vpn-policy-routing support```
- the output of ```/etc/init.d/vpn-policy-routing reload``` with verbosity setting set to 2

If you don't want to post the ```/etc/init.d/vpn-policy-routing support``` output in a public forum, there's a way to have the support details automatically uploaded to my account at paste.ee by running: ```/etc/init.d/vpn-policy-routing support -p```. You need to have the following packages installed to enable paste.ee upload functionality: ```curl libopenssl ca-bundle```. WARNING: while paste.ee uploads are unlisted, they are still publicly available.

## Notes/Known Issues

- If your default routing is set to the VPN tunnel, then then true WAN intrface cannot be discovered using OpenWrt built-in functions, so service will assume your network interface(s) ending with or starting with '''wan''' is/are the WAN interface(s).
- While you can select some down/inactive VPN tunnel in Web UI, the appropriate tunnel must be up/active for the policies to properly work without errors on service start.
- If your ```OpenVPN``` interface has the device name different from tun\* or tap\*, please make sure that the tunnel is up before trying to assign it policies in Web UI.
- Service does not alter the default routing. Depending on your VPN tunnel settings (and settings of the VPN server you are connecting to), the default routing might be set to go via WAN or via VPN tunnel. This service affects only routing of the traffic matching the policies. If you want to override default routing, consider adding the following to your OpenVPN tunnel config:

  ```text
  option route_nopull '1'
  ```

  or, for newer OpenVPN client/server combinations:

  ```text
  list pull_filter 'ignore "redirect-gateway"'
  ```

  or set the following option for your Wireguard tunnel config:

  ```text
  option route_allowed_ips '0'
  ```

- Routing Wireguard traffic requires setting `rp_filter = 2`. Please refer to [issue #41](https://github.com/stangri/openwrt_packages/issues/41) for more details.

## Thanks

I'd like to thank everyone who helped create, test and troubleshoot this service. Without contributions from [@hnyman](https://github.com/hnyman), [@dibdot](https://github.com/dibdot), [@danrl](https://github.com/danrl), [@tohojo](https://github.com/tohojo), [@cybrnook](https://github.com/cybrnook), [@nidstigator](https://github.com/nidstigator), [@AndreBL](https://github.com/AndreBL) and [@dz0ny](https://github.com/dz0ny) and rigorous testing/bugreporting by [@dziny](https://github.com/dziny), [@bluenote73](https://github.com/bluenote73), [@buckaroo](https://github.com/pgera), [@Alexander-r](https://github.com/Alexander-r) and [n8v8R](https://github.com/n8v8R) it wouldn't have been possible. Wireguard support is courtesy of [Mullvad](https://www.mullvad.net) and [WireVPN](https://www.wirevpn.net).

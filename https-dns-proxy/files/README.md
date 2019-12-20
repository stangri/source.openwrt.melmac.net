# DNS Over HTTPS Proxy (https-dns-proxy)

A simple DoH proxy based on [@aarond10](https://github.com/aarond10)'s [https-dns-proxy](https://github.com/aarond10/https_dns_proxy).

## Features

- [RFC8484](https://tools.ietf.org/html/rfc8484)-compatible DoH Proxy.
- Compact size.
- Web UI (```luci-app-https-dns-proxy```) available.
- (By default) automatically updates DNSMASQ settings to use DoH proxy when it's started and reverts to old DNSMASQ resolvers when DoH proxy is stopped.

## Screenshots (luci-app-https-dns-proxy)

Service Status

![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/https-dns-proxy/screenshot08-status.png "Service Status")

Configuration - Basic Configuration

![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/https-dns-proxy/screenshot08-config-basic.png "Configuration - Basic Configuration")

Configuration - Advanced Configuration

![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/https-dns-proxy/screenshot08-config-advanced.png "Configuration - Advanced Configuration")

Whitelist and Blocklist Management

![screenshot](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/https-dns-proxy/screenshot08-lists.png "Whitelist and Blocklist Management")

## Requirements

This proxy requires the following packages to be installed on your router: ```dnsmasq``` or ```dnsmasq-full``` or ```unbound``` and either ```ca-certificates```, ```wget``` and ```libopenssl``` (for OpenWrt 15.05.1) or ```uclient-fetch``` and ```libustream-mbedtls``` (for LEDE Project and OpenWrt 18.06.xx or newer). Additionally installation of ```coreutils-sort``` is highly recommended as it speeds up blocklist processing.

To satisfy the requirements for connect to your router via ssh and run the following commands:

## Unmet Dependencies

If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.

## How To Install

Install ```https-dns-proxy``` and ```luci-app-https-dns-proxy``` packages from Web UI or run the following in the command line:

```sh
opkg update; opkg install https-dns-proxy luci-app-https-dns-proxy;
```

## Default Settings

Default configuration has service disabled (use Web UI to enable/start service or run ```uci set https-dns-proxy.config.enabled=1; uci commit https-dns-proxy;```) and selected ad/malware lists suitable for routers with 64Mb RAM.

If your router has less then 64Mb RAM, edit the configuration file, located at ```/etc/config/https-dns-proxy```. The configuration file has lists in ascending order starting with smallest ones and each list has a preceding comment indicating its size, comment out or delete the lists you don't want or your router can't handle.

## How To Customize

## How To Use

Once the service is enabled in the [config file](#default-settings), run ```/etc/init.d/https-dns-proxy start``` to start the service. Either ```/etc/init.d/https-dns-proxy restart``` or ```/etc/init.d/https-dns-proxy reload``` will only restart the service and/or re-download the lists if there were relevant changes in the config file since the last successful start. Had the previous start resulted in any error, either ```/etc/init.d/https-dns-proxy start```, ```/etc/init.d/https-dns-proxy restart``` or ```/etc/init.d/https-dns-proxy reload``` will attempt to re-download the lists.

If you want to force https-dns-proxy to re-download the lists, run ```/etc/init.d/https-dns-proxy dl```.

If you want to check if the specific domain (or part of the domain name) is being blocked, run ```/etc/init.d/https-dns-proxy check test-domain.com```.

## Configuration Settings

In the Web UI the ```https-dns-proxy``` settings are split into ```basic``` and ```advanced``` settings. The full list of configuration parameters of ```https-dns-proxy.config``` section is:

|Web UI Section|Parameter|Type|Default|Description|
| --- | --- | --- | --- | --- |
|Basic|enabled|boolean|0|Enable/disable the ```https-dns-proxy``` service.|
|Basic|verbosity|integer|2|Can be set to 0, 1 or 2 to control the console and system log output verbosity of the ```https-dns-proxy``` service.|
|Basic|force_dns|boolean|1|Force router's DNS to local devices which may have different/hardcoded DNS server settings. If enabled, creates a firewall rule to intercept DNS requests from local devices to external DNS servers and redirect them to router.|
|Basic|led|string|none|Use one of the router LEDs to indicate the AdBlocking status.|
|Advanced|dns|string|dnsmasq.servers|DNS resolution option. See [table below](#dns-resolution-option) for addtional information.|
|Advanced|ipv6_enabled|boolean|0|Add IPv6 entries to block-list if ```dnsmasq.addnhosts``` is used. This option is only visible in Web UI if the ```dnsmasq.addnhosts``` is selected as the DNS resolution option.|
|Advanced|boot_delay|integer|120|Delay service activation for that many seconds on boot up. You can shorten it to 10-30 seconds on modern fast routers. Routers with built-in modems may require longer boot delay.|
|Advanced|download_timeout|integer|10|Time-out downloads if no reply received within that many last seconds.|
|Advanced|curl_retry|integer|3|If ```curl``` is installed and detected, attempt that many retries for failed downloads.|
|Advanced|parallel_downloads|boolean|1|If enabled, all downloads are completed concurrently, if disabled -- sequentioally. Concurrent downloads dramatically speed up service loading.|
|Advanced|debug|boolean|0|If enabled, output service full debug to ```/tmp/https-dns-proxy.log```. Please note that the debug file may clog up the router's RAM on some devices. Use with caution.|
|Advanced|allow_non_ascii|boolean|0|Enable support for non-ASCII characters in the final AdBlocking file. Only enable if your target service supports non-ASCII characters. If you enable this on the system where DNS resolver doesn't support non-ASCII characters, it will crash. Use with caution.|
|Advanced|compressed_cache|boolean|0|Create compressed cache of the AdBlocking file in router's persistent memory. Only recommended to be used on routers with large ROM and/or routers with metered/flaky internet connection.|
||whitelist_domain|list/string||List of white-listed domains.|
||whitelist_domains_url|list/string||List of URL(s) to text files containing white-listed domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix. Useful if you want to keep/publish a single white-list for multiple routers.|
||blacklist_domains_url|list/string||List of URL(s) to text files containing black-listed domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix.|
||blacklist_hosts_url|list/string||List of URL(s) to [hosts files](https://en.wikipedia.org/wiki/Hosts_(file)) containing black-listed domains. **Must** include either ```http://``` or ```https://``` (or, if ```curl``` is installed the ```file://```) prefix.|

## Thanks

I'd like to thank everyone who helped create, test and troubleshoot this service. Special thanks to [@hnyman](https://github.com/hnyman) and [@feckert](https://github.com/feckert) for general package/luci guidance.

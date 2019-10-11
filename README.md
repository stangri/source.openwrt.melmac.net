# stangri's OpenWrt/OpenWrt packages repo

This repo contains packages I've created for OpenWrt/LEDE Project routers. While some of these are packages are already available from official OpenWrt release/snapshots repositories/feeds, this repo usually contains newer versions.

## How to use

### On your router

To add this repo to your router run the following commands:

#### OpenWrt 15.05.1 Instructions

```sh
opkg update; opkg install ca-certificates wget libopenssl;
echo -e -n 'untrusted comment: OpenWrt usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

#### LEDE Project 17.01.x and OpenWrt 18.06.x (or newer) Instructions

```sh
opkg update; opkg install uclient-fetch libustream-mbedtls ca-bundle ca-certificates;
echo -e -n 'untrusted comment: OpenWrt usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

### Image Builder

Add the following line

```sh
src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master
```

to the ```repositories.conf``` file inside your Image Builder directory. You can use the following shell script code to achieve that:

```sh
! grep -q 'stangri_repo' repositories.conf && sed -i '2 i\src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' repositories.conf
```

### SDK

The packages source code is available in [my  packages source](https://github.com/stangri/openwrt_packages). Check out the code for the individual packages you want into your SDK's ```package``` folder or for luci apps into the ```package/luci/applications``` folder.

## Description of packages

### antminer-monitor

This service can be used to monitor local BITMAIN Antminers. This is just the wrapper for [Antminer Monitor python app](https://github.com/anselal/antminer-monitor). **WARNING**: Requires a router with a lot of flash, 128Mb recommended. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/antminer-monitor/files/) for further information.

### fakeinternet & luci-app-fakeinternet

This service can be used to fake internet connectivity for local devices.
Can be used on routers with no internet access to suppress warnings on local devices on no internet connectivity. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/fakeinternet/files/) and [OpenWrt Forum Thread](https://forum.openwrt.org/t/fakeinternet-service-package-wip/924) for further information.

### luci-app-advanced-reboot

This package enables Web UI for reboot to another partition functionality on supported (dual-partition) routers and to power off (power down) your router. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/luci-app-advanced-reboot/README.md) and [OpenWrt Forum Thread](https://forum.openwrt.org/t/web-ui-to-reboot-to-another-partition-for-dual-partition-routers/3423) for further information.

### luci-app-easyflash

This package installs Web UI for quickly updating your router firmware if you use automated snapshots build process which produces fully customized images and uploads them to your router. Requires sysupgrade-compatible upgrade file ```/tmp/firmware.img``` and a one-line description (target/version/filename info) in ```/tmp/firmware.tag```. WARNING: does not keep your router settings.

### luci-mod-alt-reboot

This package enables Web UI for reboot to another partition functionality on supported (dual-partition) routers and to power off (power down) your router by overwriting default System --> Reboot page. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/luci-mod-alt-reboot/README.md) for further information. This package has been superseded by ```luci-app-advanced-reboot``` and is no longer developed/supported.

### luci-theme-material-old

This package brings back the old button styles to the ```luci-theme-material``` on OpenWrt 18.06.0-rc2 and later. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/luci-theme-material-old/README.md) for further information.

### simple-adblock & luci-app-simple-adblock

This service provides lightweight and very fast dnsmasq-based ad blocking. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/simple-adblock/files/README.md) and [OpenWrt Forum Thread](https://forum.openwrt.org/t/simple-adblock-fast-lightweight-and-fully-uci-luci-configurable-ad-blocking/1327) for further information.

### slider-support

This package enables switching between ```Router```, ```Access Point``` and ```Wireless Repeater``` modes of operation for supported routers equipped with slider switch. It also sets the correct ```current mode``` setting for the [```WLAN Blinker``` service](https://github.com/stangri/openwrt_packages/blob/master/wlanblinker/files/README.md). Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/slider-support/files/README.md) for further information.

### vpn-policy-routing & luci-app-vpn-policy-routing

This service can be used to enable policy-based routing for L2TP, Openconnect, OpenVPN and Wireguard tunnels and WAN/WAN6 interfaces. Supports policies based on domain names, IP addresses and/or ports. Compatible with legacy (IPv4) and modern (IPv6) protocols. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/vpn-policy-routing/files/README.md) and [OpenWrt Forum Thread](https://forum.openwrt.org/t/vpn-policy-based-routing-web-ui-discussion/10389) for further information.

### vpnbypass & luci-app-vpnbypass

This service can be used to enable simple OpenVPN split tunneling. Supports accessing domains, IP ranges outside of your OpenVPN tunnel. Also supports dedicating local ports/IP ranges for direct internet access (outside of your OpenVPN tunnel). Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/vpnbypass/files/README.md) and [OpenWrt Forum Thread](https://forum.openwrt.org/t/vpn-bypass-split-tunneling-service-luci-ui/1106/12) for further information.

### wlanblinker & luci-app-wlanblinker

This service can be used to indicate WLAN status by blinking the unused LED. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/wlanblinker/files/README.md) for further information.

### wireshark-helper & luci-app-wireshark-helper

This service can be used to configure router to sniff packets to/from monitored device on the device running Wireshark app. Please see the [README](https://github.com/stangri/openwrt_packages/blob/master/wireshark-helper/files/README.md) for further information.

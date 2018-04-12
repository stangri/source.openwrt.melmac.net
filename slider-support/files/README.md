# Slider Support for select routers
This package enables switching between ```Router```, ```Access Point``` and ```Wireless Repeater``` modes of operation for supported routers with slider. It also sets the correct ```current mode``` setting for the [```WLAN Blinker``` service](https://github.com/stangri/openwrt_packages/blob/master/wlanblinker/files/README.md).

## Features
 - If the slider is in the left position (closes to ```reset``` button), ```Router``` mode is enabled.
 - If the slider is in the right position and the WAN port is in use, ```Access Point``` mode is enabled.
 - If the slider is in the right position and the WAN port is not in use, ```Wireless Repeater``` mode is enabled.
 - Mode switches on toggling the slider.
 - Mode switches on boot, but with about 10 seconds delay.

## How to install
Please make sure that the [requirements](#requirements) are satisfied and install ```slider-support``` from Web UI or connect to your router via ssh and run the following commands:
```sh
opkg update
opkg install slider-support
```
If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](#add-custom-repo-to-your-router) first.

#### Add custom repo to your router
If your router is not set up with the access to repository containing these packages you will need to add custom repository to your router by connecting to your router via ssh and running the following commands:

###### OpenWrt 15.05.1
```sh
opkg update; opkg install ca-certificates wget libopenssl
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

###### LEDE Project 17.01.x and OpenWrt 18.xx or later
```sh
opkg update
opkg list-installed | grep -q uclient-fetch || opkg install uclient-fetch
opkg list-installed | grep -q libustream || opkg install libustream-mbedtls
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

<!-- markdownlint-disable MD013 -->
# WLAN Blinker

This service can be used to indicate WLAN status by blinking the unused LED.

## Features

- Supports blinking to indicate the current AP's channel
- Supports blinking to indicate current STA's link quality (each blink is ~10% of link quality)

## How to install

Please make sure that the [requirements](#requirements) are satisfied and install ```wlanblinker``` and ```luci-app-wlanblinker``` from Web UI or connect to your router via ssh and run the following commands:

```sh
opkg update
opkg install wlanblinker luci-app-wlanblinker
```

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to add a custom repo to your router following instructions on [GitHub](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router)/[jsDelivr](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages/README.md#on-your-router) first.

These packages have been designed to be backwards compatible with OpenWrt 19.07, OpenWrt 18.06, LEDE Project 17.01 and OpenWrt 15.05. However, on systems older than OpenWrt 18.06.6 and/or a system which has deviated too far (or haven't been updated to keep in-sync) with official OpenWrt release you may get a message about missing ```luci-compat``` dependency, which (and only which) you can safely ignore and force-install the luci app using ```opkg install --force-depends``` command instead of ```opkg install```.

## Default Settings

Default configuration has service disabled (use Web UI to enable/start service or run ```uci set wlanblinker.config.enabled=1; uci commit wlanblinker;```).

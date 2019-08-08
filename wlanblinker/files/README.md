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

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router) first.

## Default Settings

Default configuration has service disabled (use Web UI to enable/start service or run ```uci set wlanblinker.config.enabled=1; uci commit wlanblinker;```).

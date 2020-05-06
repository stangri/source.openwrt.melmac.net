# Luci Theme Material (Old Style)

## Description

This package brings colorful buttons back to OpenWrt 18.06.0-rc2 and later.

## Screenshot

Before (on OpenWrt 18.06.0-rc2):
![Before](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages@master/screenshots/luci-theme-material-old/screenshot01-before.png "before")

After install (on OpenWrt 18.06.0-rc2):
![After](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages@master/screenshots/luci-theme-material-old/screenshot01-after.png "after")

## How to install

Install ```luci-theme-material-old``` from Web UI or connect to your router via ssh and run the following commands:

```sh
opkg update
opkg install luci-theme-material-old
```

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to add a custom repo to your router following instructions on [GitHub](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router)/[jsDelivr](https://cdn.jsdelivr.net/gh/stangri/openwrt_packages@master/README.md#on-your-router) first.

These packages have been designed to be backwards compatible with OpenWrt 19.07, OpenWrt 18.06, LEDE Project 17.01 and OpenWrt 15.05. However, on systems older than OpenWrt 18.06.6 and/or a system which has deviated too far (or haven't been updated to keep in-sync) with official OpenWrt release you may get a message about missing ```luci-compat``` dependency, which (and only which) you can safely ignore and force-install the luci app using ```opkg install --force-depends``` command instead of ```opkg install```.

## How to use

Open the WebUI System->System page (usually at <http://192.168.1.1/cgi-bin/luci/admin/system/system),> select ```Language and Style``` tab and select ```Material_Old``` from ```Design``` drop-down.

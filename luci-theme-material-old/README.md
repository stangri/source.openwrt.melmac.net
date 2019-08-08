# Luci Theme Material (Old Style)

## Description

This package brings colorful buttons back to OpenWrt 18.06.0-rc2 and later.

## Screenshot

Before (on OpenWrt 18.06.0-rc2):
![Before](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/luci-theme-material-old/screenshot01-before.png "before")

After install (on OpenWrt 18.06.0-rc2):
![After](https://raw.githubusercontent.com/stangri/openwrt_packages/master/screenshots/luci-theme-material-old/screenshot01-after.png "after")

## How to install

Install ```luci-theme-material-old``` from Web UI or connect to your router via ssh and run the following commands:

```sh
opkg update
opkg install luci-theme-material-old
```

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router) first.

## How to use

Open the WebUI System->System page (usually at <http://192.168.1.1/cgi-bin/luci/admin/system/system),> select ```Language and Style``` tab and select ```Material_Old``` from ```Design``` drop-down.

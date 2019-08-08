# antminer-monitor

Antminer Monitor service to monitor the status of the local BITMAIN Antminers. This is just the wrapper for [Antminer Monitor python app](https://github.com/anselal/antminer-monitor).

## Requirements

This service depends on the following packages: ```python-light``` and ```python-pip```. These packages (and additional python modules) will be automatically installed upon installation of this service.
**WARNING**: The installation will definitely fail on routers with less than 32Mb flash. Routers having 128Mb flash are recommended.

### Unmet dependencies

If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.

## How to install

Please make sure that the [requirements](#requirements) are satisfied and install ```antminer-monitor``` from Web UI or connect to your router via ssh and run the following commands:

```sh
opkg update
opkg install antminer-monitor
```

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](https://github.com/stangri/openwrt_packages/blob/master/README.md#how-to-use) first.

## How to use

Use WebUI to start the ```antminer-monitor``` service or run ```/etc/init.d/antminer-monitor start``` in the ssh session to the router.

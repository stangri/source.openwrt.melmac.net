# fakeinternet

Fake Internet service for OpenWrt/LEDE Project routers.

## Requirements

This service requires the following packages to be installed on your router: ```uhttpd``` and ```dnsmasq``` or ```dnsmasq-full```.

To satisfy the requirements, connect to your router via ssh and run the following commands:

```sh
opkg update; opkg install uhttpd dnsmasq;
```

### Unmet dependencies

If you are running a development (trunk/snapshot) build of OpenWrt/LEDE Project on your router and your build is outdated (meaning that packages of the same revision/commit hash are no longer available and when you try to satisfy the [requirements](#requirements) you get errors), please flash either current LEDE release image or current development/snapshot image.

## How to install

Please make sure that the [requirements](#requirements) are satisfied and install ```fakeinternet``` from Web UI or connect to your router via ssh and run the following commands:

```sh
opkg update
opkg install fakeinternet luci-app-fakeinternet
```

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router) first.

## Default Settings

Default configuration has service disabled (run ```uci set fakeinternet.config.enabled=1; uci commit fakeinternet;```) and includes domains which are used by Android OS, iOS and Fire OS mobile devices to check for the internet connectivity.

## How to customize

You can add more domains to be hijacked, check ```/etc/config/fakeinternet``` for examples. To hijack everything, use the single ```#``` symbol instead of the domain name in config. Deep customization might require modifications/extra code in ```/www_fakeinternet/error.cgi``` as well.

## How does it work

This service hijacks requests to domains listed in the ```/etc/config/fakeinternet``` config file and serves replies which mobile devices expect if the internet connection is available.

## Documentation / Discussion

Please head to [OpenWrt Forum](https://forum.openwrt.org/t/fakeinternet-service-package/924/) for discussion of this package.

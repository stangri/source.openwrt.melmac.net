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

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](#add-custom-repo-to-your-router) first.

### Add custom repo to your router

If your router is not set up with the access to repository containing these packages you will need to add custom repository to your router by connecting to your router via ssh and running the following commands:

#### OpenWrt CC 15.05.1 Instructions

```sh
opkg update; opkg install wget libopenssl
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
opkg install fakeinternet luci-app-fakeinternet
```

#### LEDE Project 17.01.x and OpenWrt 18.06.x Instructions

```sh
opkg update
opkg list-installed | grep -q uclient-fetch || opkg install uclient-fetch
opkg list-installed | grep -q libustream || opkg install libustream-mbedtls
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
opkg install fakeinternet luci-app-fakeinternet
```

## Default Settings

Default configuration has service disabled (run ```uci set fakeinternet.config.enabled=1```) and includes domains which are used by Android OS, iOS and Fire OS mobile devices to check for the internet connectivity.

## How to customize

You can add more domains to be hijacked, check ```/etc/config/fakeinternet``` for examples. To hijack everything, use the single ```#``` symbol instead of the domain name in config. Deep customization might require modifications/extra code in ```/www_fakeinternet/error.cgi``` as well.

## How does it work

This service hijacks requests to domains listed in the ```/etc/config/fakeinternet``` config file and serves replies which mobile devices expect if the internet connection is available.

## Documentation / Discussion

Please head to [LEDE Project Forum](https://forum.lede-project.org/t/fakeinternet-service-package/924/) for discussion of this package.

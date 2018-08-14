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

If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](#add-custom-repo-to-your-router) first.

### Add custom repo to your router

If your router is not set up with the access to repository containing these packages you will need to add custom repository to your router by connecting to your router via ssh and running the following commands:

#### OpenWrt CC 15.05.1 Instructions

```sh
opkg update; opkg install wget libopenssl
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
opkg install antminer-monitor
```

#### LEDE Project 17.01.x and OpenWrt 18.06.x Instructions

```sh
opkg update
opkg list-installed | grep -q uclient-fetch || opkg install uclient-fetch
opkg list-installed | grep -q libustream || opkg install libustream-mbedtls
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
opkg install antminer-monitor
```

## How to use

Use WebUI to start the ```antminer-monitor``` service or run ```/etc/init.d/antminer-monitor start``` in the ssh session to the router.

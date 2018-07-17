# Luci Theme Material (Old Style)

## Description
This package brings colorful buttons back to OpenWrt 18.06.0-rc2 and later.

## Screenshot (luci-app-simple-adblock)
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
If these packages are not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](#add-custom-repo-to-your-router) first.

#### Add custom repo to your router
If your router is not set up with the access to repository containing these packages you will need to add custom repository to your router by connecting to your router via ssh and running the following commands:

###### OpenWrt 18.xx or later
```sh
opkg update
opkg list-installed | grep -q uclient-fetch || opkg install uclient-fetch
opkg list-installed | grep -q libustream || opkg install libustream-mbedtls
echo -e -n 'untrusted comment: LEDE usign key of Stan Grishin\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

## How to use
Open the WebUI System->System page (usually at http://192.168.1.1/cgi-bin/luci/admin/system/system), select ```Language and Style``` tab and select ```Material_Old``` from ```Design``` drop-down.

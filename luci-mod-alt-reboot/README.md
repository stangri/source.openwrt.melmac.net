# Alternative Partition Reboot Web UI (luci-mod-alt-reboot)

## Description
This package allows you to reboot to alternative partition on supported (dual-partition) routers. This package overwrites default Reboot (System --> Reboot) page.

## Supported Devices
Currently supported devices include:
- Linksys WRT1200AC
- Linksys WRT1900AC
- Linksys WRT1900ACv2
- Linksys WRT1900ACS
- Linksys WRT3200ACM
- Linksys E4200v2
- Linksys EA4500
- Linksys EA8500

If you're interested in having your device supported, please check [LEDE Projet Forum Support Thread](https://forum.lede-project.org/t/web-ui-to-reboot-to-another-partition-dual-partition-routers/3423).

## How to install
[Add a custom repo to your router](#add-custom-repo-to-your-router) first and then install ```luci-mod-alt-reboot``` from ssh by run the following command:
```sh
opkg update
opkg --force-overwrite install luci-mod-alt-reboot
```

#### Add custom repo to your router
If your router is not set up with the access to repository containing these packages you will need to add custom repository to your router by connecting to your router via ssh and running the following commands:

###### OpenWrt CC 15.05.1
```sh
opkg update; opkg install wget libopenssl
echo -e -n 'untrusted comment: public key 7ffc7517c4cc0c56\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```

###### LEDE Project and OpenWrt DD trunk
```sh
opkg update; opkg install uclient-fetch libustream-mbedtls
echo -e -n 'untrusted comment: public key 7ffc7517c4cc0c56\nRWR//HUXxMwMVnx7fESOKO7x8XoW4/dRidJPjt91hAAU2L59mYvHy0Fa\n' > /tmp/stangri-repo.pub && opkg-key add /tmp/stangri-repo.pub
! grep -q 'stangri_repo' /etc/opkg/customfeeds.conf && echo 'src/gz stangri_repo https://raw.githubusercontent.com/stangri/openwrt-repo/master' >> /etc/opkg/customfeeds.conf
opkg update
```
## How to uninstall
Run the following commands in ssh session to your router:
```sh
cp /rom/usr/lib/lua/luci/controller/admin/system.lua /usr/lib/lua/luci/controller/admin/system.lua
cp /rom/usr/lib/lua/luci/view/admin_system/reboot.htm /usr/lib/lua/luci/view/admin_system/reboot.htm
```

## Notes/Known Issues
- When you reboot to a different partition, your current settings (Wireless, etc.) will not apply to a different partition. Different partitions might have completely different settings and firmware.
- If you reboot to a partition which doesn't allow you to switch boot partitions (like stock Linksys firmware), you might not be able to boot back to OpenWrt/LEDE Project unless you reflash it, loosing all the settings.
- Some devices allow you to trigger reboot to alternative partition by interrupting boot 3 times in a row (by resetting/switching off the device or pulling power). As these methods might be different for different devices, do your own homework.

## Thanks
I'd like to thank everyone who helped create, test and troubleshoot this package. Without contributions from [@hnyman](https://github.com/hnyman), [@jpstyves](https://github.com/jpstyves) it wouldn't have been possible.

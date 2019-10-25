# Alternative Partition Reboot Web UI (luci-mod-alt-reboot)

## Description

This package allows you to reboot to an alternative partition on supported (dual-partition) routers. This package overwrites the default Reboot (System --> Reboot) page.

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

Install ```luci-mod-alt-reboot``` package from the Web UI or run the following in a command line:

```sh
opkg update
opkg --force-overwrite install luci-mod-alt-reboot
```

If the ```luci-mod-alt-reboot``` package is not found in the official feed/repo for your version of OpenWrt/LEDE Project, you will need to [add a custom repo to your router](https://github.com/stangri/openwrt_packages/blob/master/README.md#on-your-router) first.

## How to uninstall

Run the following commands in an ssh session on your router:

```sh
cp /rom/usr/lib/lua/luci/controller/admin/system.lua /usr/lib/lua/luci/controller/admin/system.lua
cp /rom/usr/lib/lua/luci/view/admin_system/reboot.htm /usr/lib/lua/luci/view/admin_system/reboot.htm
```

## Notes/Known Issues

- When you reboot to an alternate different partition, your current settings (Wireless, etc.) will not apply to the current different partition. Different partitions may have completely different settings and firmware.
- If you reboot to a partition which does not allow you to switch boot partitions (like stock Linksys firmware), you may not be able to boot back to OpenWrt/LEDE Project unless you reflash it, losing all the settings.
- Some devices allow you to trigger a reboot to an alternative partition by interrupting boot 3 times in a row (by resetting/switching off the device or pulling power). As these methods vary for different devices, do your own homework on figuring out the method appropriate for your device.

## Thanks

I'd like to thank everyone who helped create, test and troubleshoot this package. Without contributions from [@hnyman](https://github.com/hnyman), [@jpstyves](https://github.com/jpstyves) it wouldn't have been possible.

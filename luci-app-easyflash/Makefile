# Copyright 2017-2018 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

LUCI_TITLE:=Easy Flash Web UI
LUCI_DEPENDS:=+luci-mod-admin-full
LUCI_PKGARCH:=all
PKG_RELEASE:=5

define Package/luci/luci-app-easyflash/description
Provides Web UI for quickly updating your router firmware if you use automated snapshots\
build process which produces fully customized images and uploads them to your router.
Requires sysupgrade-compatible upgrade file /tmp/firmware.img and a one-line description\
(target/version/filename info) in /tmp/firmware.tag.
WARNING: does not keep your router settings.
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature

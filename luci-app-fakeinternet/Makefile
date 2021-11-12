# Copyright 2017-2018 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>
PKG_VERSION:=0.1.4-5

LUCI_TITLE:=Fakeinternet Web UI
LUCI_DESCRIPTION:=Provides Web UI for Fakeinternet.
LUCI_DEPENDS:=+luci-compat +luci-mod-admin-full +fakeinternet
LUCI_PKGARCH:=all

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature

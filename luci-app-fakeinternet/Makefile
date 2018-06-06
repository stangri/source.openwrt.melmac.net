# Copyright (c) 2017 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

LUCI_TITLE:=Fakeinternet Web UI
LUCI_DESCRIPTION:=Provides Web UI for Fakeinternet.
LUCI_DEPENDS:=+luci +fakeinternet
LUCI_PKGARCH:=all
PKG_RELEASE:=1

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature

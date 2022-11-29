# Copyright 2021 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

LUCI_TITLE:=Template JS Web UI
LUCI_URL:=https://docs.openwrt.melmac.net/luci-app-template-js/
LUCI_DESCRIPTION:=Provides template for JS-based Web UI applications.
LUCI_DEPENDS:=+luci-base +jshn
LUCI_PKGARCH:=all

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature

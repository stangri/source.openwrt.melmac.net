# Copyright 2017-2018 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_VERSION:=0.0.1-5

LUCI_TITLE:=Wireshark-helper Web UI
LUCI_DESCRIPTION:=Provides Web UI for Wireshark-helper.
LUCI_DEPENDS:=+luci-compat +luci-base +wireshark-helper
LUCI_PKGARCH:=all

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature

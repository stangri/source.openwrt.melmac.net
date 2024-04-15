# Copyright 2017-2018 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_VERSION:=0.0.1
PKG_RELEASE:=10

LUCI_TITLE:= WLAN Blinker Web UI
LUCI_DESCRIPTION:=Provides Web UI for WLAN Blinker service.
LUCI_DEPENDS:=+luci-compat +luci-base +wlanblinker

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature

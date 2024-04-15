# Copyright 2017-2024 MOSSDeF, Stan Grishin (stangri@melmac.ca).
# This is free software, licensed under AGPL-3.0-or-later.

include $(TOPDIR)/rules.mk

PKG_LICENSE:=AGPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_VERSION:=0.0.1
PKG_RELEASE:=5

LUCI_TITLE:=Wireshark-helper Web UI
LUCI_DESCRIPTION:=Provides Web UI for Wireshark-helper.
LUCI_DEPENDS:=+luci-compat +luci-base +wireshark-helper

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature

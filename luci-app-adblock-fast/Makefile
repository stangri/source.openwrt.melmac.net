# Copyright 2023 MOSSDeF, Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-adblock-fast
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_VERSION:=1.1.1
PKG_RELEASE:=r7

LUCI_TITLE:=AdBlock-Fast Web UI
LUCI_DESCRIPTION:=Provides Web UI for adblock-fast service.
LUCI_DEPENDS:=+luci-base +adblock-fast +jsonfilter

define Package/$(PKG_NAME)/config
# shown in make menuconfig <Help>
help
	$(LUCI_TITLE)
	.
	Version: $(PKG_VERSION)-$(PKG_RELEASE)
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature

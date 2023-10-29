# Copyright 2023 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the MIT License.

include $(TOPDIR)/rules.mk

PKG_NAME:=amnezia-wg
PKG_VERSION:=0.1.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/amnezia-vpn/amnezia-wg/tar.gz/v${PKG_VERSION}?
PKG_HASH:=81fb720a97f817d7296e67e218c83487d05615d956ae18b41576c4b2d4f35491

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/amnezia-vpn/amnezia-wg
GO_PKG_LDFLAGS_X:=\
	main.Build=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/amnezia-wg
  SECTION:=net
  CATEGORY:=Network
  TITLE:=amnezia-wg
  URL:=https://docs.openwrt.melmac.net/amnezia-wg/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Build/Compile
  $(call GoPackage/Build/Compile)
endef

define Package/amnezia-wg/description
  AmneziaWG is a contemporary version of the WireGuard protocol. It's a fork of
  WireGuard-Go and offers protection against detection by Deep Packet Inspection
  (DPI) systems. At the same time, it retains the simplified architecture and
  high performance of the original.
endef

define Package/amnezia-wg/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/amnezia-wg $(1)/usr/sbin/
endef

$(eval $(call GoBinPackage,amnezia-wg))
$(eval $(call BuildPackage,amnezia-wg))

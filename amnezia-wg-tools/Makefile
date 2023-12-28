# Copyright 2023 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the MIT License.

include $(TOPDIR)/rules.mk

PKG_NAME:=amnezia-wg-tools
PKG_VERSION:=0.1.7
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/amnezia-vpn/amnezia-wg-tools/
PKG_SOURCE_VERSION:=c9ff85e9edbb424de2535e286108dd73e45c5a5e
PKG_MIRROR_HASH:=d6bf353fcaa5d1c157ef7fb9173f50b01425f81037f5a8457eb6efdb68f09451

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/amnezia-vpn/amnezia-wg-tools
GO_PKG_LDFLAGS_X:=\
	main.Build=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/amnezia-wg-tools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=amnezia-wg-tools
  URL:=https://docs.openwrt.melmac.net/amnezia-wg/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Build/Compile
  $(call GoPackage/Build/Compile)
endef

define Package/amnezia-wg-tools/description
  AmneziaWG is a contemporary version of the WireGuard protocol. It's a fork of
  WireGuard-Go and offers protection against detection by Deep Packet Inspection
  (DPI) systems. At the same time, it retains the simplified architecture and
  high performance of the original.
endef

define Package/amnezia-wg-tools/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/amnezia-wg-tools $(1)/usr/sbin/
endef

$(eval $(call GoBinPackage,amnezia-wg-tools))
$(eval $(call BuildPackage,amnezia-wg-tools))

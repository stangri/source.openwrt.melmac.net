# Copyright 2021 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the MIT License.

include $(TOPDIR)/rules.mk

PKG_NAME:=nebula
PKG_VERSION:=1.4.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/slackhq/nebula/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e8d79231f6100a2cd240d6a092d0dcc2bfccadffa83cb40e99b7328f6c75c2ec

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
GO_PKG:=github.com/slackhq/nebula
GO_PKG_LDFLAGS_X:=main.Build=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/nebula
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula
  URL:=https://github.com/slackhq/nebula
  DEPENDS:=$(GO_ARCH_DEPENDS) +kmod-tun
endef

define Package/nebula-cert
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula-cert
  URL:=https://github.com/slackhq/nebula
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/nebula-proto
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula
  URL:=https://github.com/slackhq/nebula
  DEPENDS:=nebula
  PKGARCH:=all
endef

define Package/nebula-service
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula
  URL:=https://github.com/slackhq/nebula
  DEPENDS:=nebula
  PKGARCH:=all
endef

define Package/nebula/description
  Nebula is a scalable overlay networking tool with a focus on performance, simplicity
  and security. It lets you seamlessly connect computers anywhere in the world.
  This package contains only nebula binary. Unless you want to start nebula manually,
  you may want to also install *either* 'nebula-service' *or* 'nebula-proto' package.
endef

define Package/nebula-cert/description
  Nebula is a scalable overlay networking tool with a focus on performance, simplicity
  and security. It lets you seamlessly connect computers anywhere in the world.
  This package contains only nebula-cert binary.
endef

define Package/nebula-proto/description
  Nebula is a scalable overlay networking tool with a focus on performance, simplicity
  and security. It lets you seamlessly connect computers anywhere in the world.
  This package contains only OpenWrt protocol/interface support for nebula.
endef

define Package/nebula-service/description
  Nebula is a scalable overlay networking tool with a focus on performance, simplicity
  and security. It lets you seamlessly connect computers anywhere in the world.
  This package contains only OpenWrt-specific init.d script for nebula.
endef

define Package/nebula/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/lib/upgrade/keep.d
	$(INSTALL_DIR) $(1)/usr/share/doc/nebula
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula $(1)/usr/sbin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/doc/nebula/LICENSE
	$(INSTALL_DATA) ./files/nebula.upgrade $(1)/lib/upgrade/keep.d/nebula
endef

define Package/nebula-cert/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/lib/upgrade/keep.d
	$(INSTALL_DIR) $(1)/usr/share/doc/nebula-cert
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula-cert $(1)/usr/sbin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/doc/nebula-cert/LICENSE
	$(INSTALL_DATA) ./files/nebula.upgrade $(1)/lib/upgrade/keep.d/nebula-cert
endef

define Package/nebula-proto/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/nebula.proto $(1)/lib/netifd/proto/nebula.sh
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/lib/netifd/proto/nebula.sh
endef

define Package/nebula-service/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nebula.init $(1)/etc/init.d/nebula
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/nebula
endef

$(eval $(call GoBinPackage,nebula))
$(eval $(call BuildPackage,nebula))

$(eval $(call GoBinPackage,nebula-cert))
$(eval $(call BuildPackage,nebula-cert))

$(eval $(call BuildPackage,nebula-proto))

$(eval $(call BuildPackage,nebula-service))

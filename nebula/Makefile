# Copyright 2021 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the MIT License.

include $(TOPDIR)/rules.mk

PKG_NAME:=nebula
PKG_VERSION:=1.3.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/slackhq/nebula/archive/
PKG_HASH:=b94fba0251a4a436e25b127d0b9bc0181b991631f1dc8e344b1c8e895b55375d
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/nebula-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
GO_PKG:=github.com/slackhq/nebula

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/nebula
	SECTION:=net
	CATEGORY:=Network
	TITLE:=nebula
	URL:=https://github.com/slackhq/nebula
	DEPENDS:=$(GO_ARCH_DEPENDS) +kmod-tun
endef

define Package/nebula-full
$(call Package/nebula)
	VARIANT:=full
	TITLE+=-full
endef

define Package/nebula/description
	Nebula is a scalable overlay networking tool with a focus on performance,
	simplicity and security. It lets you seamlessly connect computers anywhere in the world.
endef

define Package/nebula-full/description
	$(call Package/nebula/description)
	This package also contains nebula-cert binary.
endef

define Package/nebula/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/doc/nebula
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula $(1)/usr/sbin/nebula
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/doc/nebula/LICENSE
endef

define Package/nebula-full/install
	$(call Package/nebula/install,$(1))
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula-cert $(1)/usr/sbin/nebula-cert
endef

$(eval $(call GoBinPackage,nebula))
$(eval $(call BuildPackage,nebula))

$(eval $(call GoBinPackage,nebula-full))
$(eval $(call BuildPackage,nebula-full))

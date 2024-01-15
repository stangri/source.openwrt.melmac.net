# Copyright 2021-2023 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the MIT License.

include $(TOPDIR)/rules.mk

PKG_NAME:=netclient
PKG_VERSION:=0.21.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gravitl/netclient/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=6e8017e1e89530d836a35658d778196d801cd634569c3827858631d9f756ac31

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/gravitl/netclient
GO_PKG_BUILD_PKG:= \
	github.com/gravitl/netclient
GO_PKG_LDFLAGS_X:=\
	main.Build=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/netclient
  SECTION:=net
  CATEGORY:=Network
  TITLE:=netclient
  URL:=https://docs.openwrt.melmac.net/netclient/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Build/Compile
  $(call GoPackage/Build/Compile)
endef

define Package/netclient/description
This is the client for Netmaker networks. To learn more about Netmaker, see URL below.
https://github.com/gravitl/netmaker
endef

define Package/netclient/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netclient.init $(1)/etc/init.d/netclient
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/netclient
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/netclient $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/netclient.upgrade $(1)/lib/upgrade/keep.d/netclient
	$(INSTALL_DIR) $(1)/usr/share/doc/netclient
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE.txt $(1)/usr/share/doc/netclient/LICENSE.txt
endef

$(eval $(call GoBinPackage,netclient))
$(eval $(call BuildPackage,netclient))

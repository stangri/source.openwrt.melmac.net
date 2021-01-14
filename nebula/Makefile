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
# include ../../lang/golang/golang-package.mk
include ../../feeds/packages/lang/golang/golang-package.mk

define Package/nebula
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula
  URL:=https://github.com/slackhq/nebula
  DEPENDS:=$(GO_ARCH_DEPENDS) +kmod-tun
endef

define Package/nebula/description
  Nebula is a scalable overlay networking tool with a focus on performance,
  simplicity and security. It lets you seamlessly connect computers anywhere in the world.
endef

$(eval $(call GoBinPackage,nebula))
$(eval $(call BuildPackage,nebula))

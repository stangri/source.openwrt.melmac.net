# Copyright 2023-04-01 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=brickproof
PKG_VERSION:=0.1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/brickproof
	SECTION:=Utilities
	TITLE:=Brick-proof shell script
	URL:=https://docs.openwrt.melmac.net/brickproof/
	PKGARCH:=all
endef

define Package/brickproof/description
Package provides a shell script which allows to force Failesafe Mode at the next boot.
Use 'brickproof enable' to enable Failesafe Mode at next boot.
Use 'brickproof disable' to disable Failesafe Mode at next boot.
Please see https://docs.openwrt.melmac.net/brickproof/ for more information.
endef

define Package/brickproof/conffiles
/etc/config/brickproof
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/brickproof/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/brickproof
	$(INSTALL_BIN) ./files/brickproof.sh $(1)/usr/bin/brickproof
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/usr/bin/brickproof
	$(INSTALL_DATA) ./files/failsafe_brickproof.sh $(1)/usr/share/brickproof/failsafe_brickproof
endef

$(eval $(call BuildPackage,brickproof))

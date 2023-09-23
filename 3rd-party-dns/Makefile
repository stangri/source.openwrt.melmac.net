# Copyright 2017-2022 Stan Grishin (stangri@melmac.ca)
# TLD optimization written by Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=3rd-party-dns
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/3rd-party-dns
	SECTION:=net
	CATEGORY:=Network
	TITLE:=3rd Party DNS Service
	URL:=https://docs.openwrt.melmac.net/3rd-party-dns/
	DEPENDS:=+jshn +wget
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
	PKGARCH:=all
endef

define Package/3rd-party-dns/description
Simple PROCD script to start/stop multiple services affecting DNS with one command.
Please see https://docs.openwrt.melmac.net/3rd-party-dns/ for more information.
endef

define Package/3rd-party-dns/conffiles
/etc/config/3rd-party-dns
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/3rd-party-dns/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/3rd-party-dns.init $(1)/etc/init.d/3rd-party-dns
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/3rd-party-dns
	$(INSTALL_CONF) ./files/3rd-party-dns.conf $(1)/etc/config/3rd-party-dns
endef

define Package/3rd-party-dns/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Removing rc.d symlink for 3rd-party-dns"
		/etc/init.d/3rd-party-dns disable || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,3rd-party-dns))

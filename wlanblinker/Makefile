# Copyright 2017-2018 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=wlanblinker
PKG_VERSION:=0.0.1
PKG_RELEASE:=10
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

include $(INCLUDE_DIR)/package.mk

define Package/wlanblinker
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+coreutils-sleep +iwinfo
	DEPENDS+=+!BUSYBOX_DEFAULT_AWK:gawk
	DEPENDS+=+!BUSYBOX_DEFAULT_GREP:grep
	TITLE:=WLAN Blinker Service
	URL:=https://docs.openwrt.melmac.net/wlanblinker/
	PKGARCH:=all
endef

define Package/wlanblinker/description
This service can be used to signal WLAN status by the unused LED.
Please see the README for further information.
endef

define Package/wlanblinker/conffiles
/etc/config/wlanblinker
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wlanblinker/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/wlanblinker.init $(1)/etc/init.d/wlanblinker
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/wlanblinker
	$(INSTALL_CONF) ./files/wlanblinker.config $(1)/etc/config/wlanblinker
	$(INSTALL_BIN) ./files/blink.sh $(1)/usr/sbin/blink
endef


define Package/wlanblinker/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/wlanblinker enable
	fi
	exit 0
endef

define Package/wlanblinker/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping service and removing rc.d symlink for wlanblinker"
		/etc/init.d/wlanblinker stop || true
		/etc/init.d/wlanblinker disable
	fi
	exit 0
endef

$(eval $(call BuildPackage,wlanblinker))

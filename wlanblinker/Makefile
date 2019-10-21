# Copyright 2017-2018 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=wlanblinker
PKG_VERSION:=0.0.1
PKG_RELEASE:=8
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/wlanblinker
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+coreutils-sleep +iwinfo
	TITLE:=WLAN Blinker Service
	PKGARCH:=all
endef

define Package/wlanblinker/description
This service can be used to signal WLAN status by the unused LED.
Please see the README for further information.
endef

define Package/wlanblinker/conffiles
/etc/config/wlanblinker
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/files/
	$(CP) ./files/wlanblinker.init $(PKG_BUILD_DIR)/files/wlanblinker.init
	sed -i "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(PKG_BUILD_DIR)/files/wlanblinker.init
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wlanblinker/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/wlanblinker.init $(1)/etc/init.d/wlanblinker
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/wlanblinker.conf $(1)/etc/config/wlanblinker
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DATA) ./files/blink.sh $(1)/usr/sbin/blink
	chmod 0755 $(1)/usr/sbin/blink
endef


define Package/wlanblinker/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		while [ ! -z "$(uci -q get ucitrack.@wlanblinker[-1] 2>/dev/null)" ] ; do
			uci -q delete ucitrack.@wlanblinker[-1]
		done

		uci -q batch <<-EOF >/dev/null
			add ucitrack wlanblinker
			set ucitrack.@wlanblinker[-1].init='wlanblinker'
			add_list ucitrack.@firewall[-1].affects='wlanblinker'
			commit ucitrack
	EOF
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

		while [ ! -z "$(uci -q get ucitrack.@wlanblinker[-1] 2>/dev/null)" ] ; do
			uci -q delete ucitrack.@wlanblinker[-1]
		done

	fi
	exit 0
endef

$(eval $(call BuildPackage,wlanblinker))

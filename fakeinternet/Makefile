# Copyright 2017-2018 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=fakeinternet
PKG_VERSION:=0.1.4
PKG_RELEASE:=4
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/fakeinternet
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+uhttpd +uhttpd-mod-ubus
	TITLE:=Fakeinternet Service
	PKGARCH:=all
endef

define Package/fakeinternet/description
This service can be used to fake internet connectivity for local devices.
Can be used on routers with no internet access to suppress warnings on local devices of no internet connectivity.
endef

define Package/fakeinternet/conffiles
/etc/config/fakeinternet
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/files/
	$(CP) ./files/fakeinternet.init $(PKG_BUILD_DIR)/files/fakeinternet.init
	sed -i "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(PKG_BUILD_DIR)/files/fakeinternet.init
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/fakeinternet/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/fakeinternet.init $(1)/etc/init.d/fakeinternet
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/fakeinternet.conf $(1)/etc/config/fakeinternet
	$(INSTALL_DIR) $(1)/www_fakeinternet
	$(INSTALL_BIN) ./files/fakeinternet.cgi $(1)/www_fakeinternet/error.cgi
	chmod 0755 $(1)/www_fakeinternet/error.cgi
endef

define Package/fakeinternet/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/fakeinternet enable

		while [ ! -z "$(uci -q get ucitrack.@fakeinternet[-1] 2>/dev/null)" ] ; do
			uci -q delete ucitrack.@fakeinternet[-1]
			uci commit ucitrack
		done

		uci -q batch <<-EOF >/dev/null
			add ucitrack fakeinternet
			set ucitrack.@fakeinternet[-1].init='fakeinternet'
			commit ucitrack
	EOF
	fi
	exit 0
endef

define Package/fakeinternet/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping service and removing rc.d symlink for fakeinternet"
		/etc/init.d/fakeinternet stop || true
		/etc/init.d/fakeinternet disable || true
		while [ ! -z "$(uci -q get ucitrack.@fakeinternet[-1] 2>/dev/null)" ] ; do
			uci -q delete ucitrack.@fakeinternet[-1]
			uci commit ucitrack
		done
	fi
	exit 0
endef

$(eval $(call BuildPackage,fakeinternet))

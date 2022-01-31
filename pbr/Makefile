# Copyright 2017-2018 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=pbr
PKG_VERSION:=0.9.4
PKG_RELEASE:=6
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

include $(INCLUDE_DIR)/package.mk

define Package/pbr/default
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=VPN
	PROVIDES:=pbr
	TITLE:=Policy Based Routing Service
	URL:=https://docs.openwrt.melmac.net/pbr/
	DEPENDS:=+jshn +ipset +iptables +resolveip +kmod-ipt-ipset +iptables-mod-ipopt +ip-full
	CONFLICTS:=vpnbypass vpn-policy-routing
	PKGARCH:=all
endef

define Package/pbr-ipt
$(call Package/pbr/default)
	TITLE+= with iptables/ipset support
endef

define Package/pbr-netifd
$(call Package/pbr/default)
	TITLE+= with netifd support
endef

define Package/pbr/description
This service enables policy-based routing for WAN interfaces and various VPN tunnels.
endef

Package/pbr-ipt/description = $(Package/pbr/description)
Package/pbr-netifd/description = $(Package/pbr/description)

define Package/pbr/conffiles
/etc/config/pbr
endef

Package/pbr-ipt/conffiles = $(Package/pbr/conffiles)
Package/pbr-netifd/conffiles = $(Package/pbr/conffiles)

define Build/Configure
endef

define Build/Compile
endef

define Package/pbr/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/share/pbr
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/hotplug.d/firewall
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_CONF) ./files/pbr.config $(1)/etc/config/pbr
	$(INSTALL_DATA) ./files/pbr.hotplug.iface $(1)/etc/hotplug.d/iface/70-pbr
	$(INSTALL_DATA) ./files/pbr.user.aws $(1)/usr/share/pbr/pbr.user.aws
	$(INSTALL_DATA) ./files/pbr.user.netflix $(1)/usr/share/pbr/pbr.user.netflix
	$(INSTALL_DATA) ./files/pbr.firewall.include $(1)/usr/share/pbr/pbr.firewall.include
	$(INSTALL_DATA) ./files/pbr.hotplug.firewall $(1)/etc/hotplug.d/firewall/70-pbr
endef
#	$(INSTALL_BIN) ./files/pbr.defaults $(1)/etc/uci-defaults/90-pbr
#Package/pbr-ipt/install = $(Package/pbr/install,$(1),pbr.init)
#Package/pbr-netifd/install = $(Package/pbr/install,$(1),pbr.netifd.init)

define Package/pbr-ipt/install
$(call Package/pbr/install,$(1),pbr.ipt.init)
	$(INSTALL_BIN) ./files/pbr.ipt.init $(1)/etc/init.d/pbr
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/pbr
endef

define Package/pbr-netifd/install
$(call Package/pbr/install,$(1),pbr.netifd.init)
	$(INSTALL_BIN) ./files/pbr.netifd.init $(1)/etc/init.d/pbr
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/pbr
endef

define Package/pbr-ipt/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo -n "Installing rc.d symlink for pbr... "
		/etc/init.d/pbr enable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr-ipt/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping pbr service... "
		/etc/init.d/pbr stop || true
		echo -n "Removing rc.d symlink for pbr... "
		/etc/init.d/pbr disable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr-netifd/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo -n "Installing rc.d symlink for pbr... "
		/etc/init.d/pbr enable && echo "OK" || echo "FAIL"
	#	echo -n "Installing netifd support for pbr... "
	#	/etc/init.d/pbr netifd install && echo "OK" || echo "FAIL"
	#	echo -n "Restarting network... "
	#	/etc/init.d/network restart && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr-netifd/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping pbr service... "
		/etc/init.d/pbr stop || true
	#	echo -n "Removing netifd support for pbr... "
	#	/etc/init.d/pbr netifd remove && echo "OK" || echo "FAIL"
		echo -n "Removing rc.d symlink for pbr... "
		/etc/init.d/pbr disable && echo "OK" || echo "FAIL"
	#	echo -n "Restarting network... "
	#	/etc/init.d/network restart && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

$(eval $(call BuildPackage,pbr-ipt))
$(eval $(call BuildPackage,pbr-netifd))

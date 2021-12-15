# Copyright 2017-2018 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=pbr
PKG_VERSION:=0.9.3
PKG_RELEASE:=5
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

include $(INCLUDE_DIR)/package.mk

define Package/pbr
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Policy Based Routing Service
	URL:=https://docs.openwrt.melmac.net/pbr/
	DEPENDS:=+jshn +ipset +iptables +resolveip +kmod-ipt-ipset +iptables-mod-ipopt +ip-full
	CONFLICTS:=vpnbypass vpn-policy-routing
	PKGARCH:=all
endef

define Package/pbr/description
This service enables policy-based routing for WAN interfaces and various VPN tunnels.
endef

define Package/pbr/conffiles
/etc/config/pbr
endef

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
	$(INSTALL_BIN) ./files/pbr.init $(1)/etc/init.d/pbr
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/pbr
	$(INSTALL_CONF) ./files/pbr.config $(1)/etc/config/pbr
	$(INSTALL_DATA) ./files/pbr.hotplug.iface $(1)/etc/hotplug.d/iface/70-pbr
	$(INSTALL_DATA) ./files/pbr.user.aws $(1)/usr/share/pbr/pbr.user.aws
	$(INSTALL_DATA) ./files/pbr.user.netflix $(1)/usr/share/pbr/pbr.user.netflix
endef
#	$(INSTALL_BIN) ./files/pbr.defaults $(1)/etc/uci-defaults/99-pbr
#	$(INSTALL_DATA) ./files/pbr.firewall.include $(1)/usr/share/pbr/pbr.firewall.include
#	$(INSTALL_DATA) ./files/pbr.hotplug.firewall $(1)/etc/hotplug.d/firewall/70-pbr

define Package/pbr/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/pbr enable
	fi
	exit 0
endef

define Package/pbr/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping service and removing rc.d symlink for pbr"
		/etc/init.d/pbr stop || true
		/etc/init.d/pbr disable || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,pbr))

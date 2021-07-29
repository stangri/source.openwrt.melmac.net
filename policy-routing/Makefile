# Copyright 2017-2018 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.
#	$(INSTALL_DATA) ./files/policy-routing.hotplug.iface $(1)/etc/hotplug.d/iface/70-policy-routing

include $(TOPDIR)/rules.mk

PKG_NAME:=policy-routing
PKG_VERSION:=0.9.1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/policy-routing
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Policy Based Routing Service
	URL:=https://docs.openwrt.melmac.net/policy-routing/
	DEPENDS:=+jshn +ipset +iptables +resolveip +kmod-ipt-ipset +iptables-mod-ipopt +ip-full
	CONFLICTS:=vpnbypass vpn-policy-routing
	PKGARCH:=all
endef

define Package/policy-routing/description
This service enables policy-based routing for WAN interfaces and various VPN tunnels.
endef

define Package/policy-routing/conffiles
/etc/config/policy-routing
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/policy-routing/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/firewall $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/policy-routing.init $(1)/etc/init.d/policy-routing
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/policy-routing
	$(INSTALL_CONF) ./files/policy-routing.config $(1)/etc/config/policy-routing
	$(INSTALL_DATA) ./files/policy-routing.hotplug.firewall $(1)/etc/hotplug.d/firewall/70-policy-routing
	$(INSTALL_DATA) ./files/policy-routing.user.aws $(1)/etc/policy-routing.user.aws
	$(INSTALL_DATA) ./files/policy-routing.user.netflix $(1)/etc/policy-routing.user.netflix
endef

define Package/policy-routing/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/policy-routing enable
	fi
	exit 0
endef

define Package/policy-routing/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping service and removing rc.d symlink for policy-routing"
		/etc/init.d/policy-routing stop || true
		/etc/init.d/policy-routing disable || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,policy-routing))

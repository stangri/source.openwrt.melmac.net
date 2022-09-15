# Copyright 2017-2022 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=pbr
PKG_VERSION:=0.9.7
PKG_RELEASE:=1
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
	DEPENDS:=+jshn +resolveip +ip-full
	CONFLICTS:=vpnbypass vpn-policy-routing
	PKGARCH:=all
endef

define Package/pbr-iptables
$(call Package/pbr/default)
	TITLE+= with iptables/ipset support
	DEPENDS+=+ipset +iptables +kmod-ipt-ipset +iptables-mod-ipopt
endef

define Package/pbr-nftables
$(call Package/pbr/default)
	TITLE+= with nftables/nft set support
	DEPENDS+=+kmod-nft-core +kmod-nft-nat +nftables-json
endef

define Package/pbr-netifd
$(call Package/pbr/default)
	TITLE+= with netifd support
endef

define Package/pbr/description
This service enables policy-based routing for WAN interfaces and various VPN tunnels.
endef

Package/pbr-iptables/description = $(Package/pbr/description)
Package/pbr-nftables/description = $(Package/pbr/description)
Package/pbr-netifd/description = $(Package/pbr/description)

define Package/pbr/conffiles
/etc/config/pbr
endef

Package/pbr-iptables/conffiles = $(Package/pbr/conffiles)
Package/pbr-nftables/conffiles = $(Package/pbr/conffiles)
Package/pbr-netifd/conffiles = $(Package/pbr/conffiles)

define Build/Configure
endef

define Build/Compile
endef

define Package/pbr/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/hotplug.d/firewall
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/share/pbr
	$(INSTALL_BIN) ./files/etc/init.d/pbr.init $(1)/etc/init.d/pbr
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/pbr
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/70-pbr $(1)/etc/hotplug.d/iface/70-pbr
	$(INSTALL_DATA) ./files/etc/hotplug.d/firewall/70-pbr $(1)/etc/hotplug.d/firewall/70-pbr
	$(INSTALL_BIN)  ./files/etc/uci-defaults/90-pbr $(1)/etc/uci-defaults/90-pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.firewall.include $(1)/usr/share/pbr/pbr.firewall.include
endef

define Package/pbr-iptables/install
$(call Package/pbr/install,$(1))
	$(INSTALL_CONF) ./files/etc/config/pbr.iptables $(1)/etc/config/pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.iptables.aws $(1)/usr/share/pbr/pbr.user.aws
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.iptables.netflix $(1)/usr/share/pbr/pbr.user.netflix
endef

define Package/pbr-nftables/install
$(call Package/pbr/install,$(1))
	$(INSTALL_CONF) ./files/etc/config/pbr.nftables $(1)/etc/config/pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.nftables.aws $(1)/usr/share/pbr/pbr.user.aws
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.nftables.netflix $(1)/usr/share/pbr/pbr.user.netflix
	$(INSTALL_DIR) $(1)/usr/share/nftables.d
	$(CP) ./files/usr/share/nftables.d/* $(1)/usr/share/nftables.d/
endef

define Package/pbr-netifd/install
$(call Package/pbr/install,$(1))
	$(INSTALL_BIN) ./files/etc/init.d/pbr.netifd.init $(1)/etc/init.d/pbr
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/pbr
	$(INSTALL_CONF) ./files/etc/config/pbr.iptables $(1)/etc/config/pbr
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.iptables.aws $(1)/usr/share/pbr/pbr.user.aws
	$(INSTALL_DATA) ./files/usr/share/pbr/pbr.user.iptables.netflix $(1)/usr/share/pbr/pbr.user.netflix
endef

define Package/pbr-iptables/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo -n "Installing rc.d symlink for pbr... "
		/etc/init.d/pbr enable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr-iptables/prerm
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

define Package/pbr-nftables/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo -n "Installing rc.d symlink for pbr... "
		/etc/init.d/pbr enable && echo "OK" || echo "FAIL"
	fi
	exit 0
endef

define Package/pbr-nftables/prerm
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

$(eval $(call BuildPackage,pbr-iptables))
$(eval $(call BuildPackage,pbr-nftables))
# $(eval $(call BuildPackage,pbr-netifd))

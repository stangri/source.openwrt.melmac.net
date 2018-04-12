# Copyright (c) 2017 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=slider-support
PKG_VERSION:=0.0.1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/slider-support
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+ethtool +swconfig +relayd
	TITLE:=Slider support for GL-Inet AR300M and MT300N/v2
	PKGARCH:=all
endef

define Package/slider-support/description
This service can be used to signal WLAN status by the unused LED.
Please see the README for further information.
endef

define Package/slider-support/conffiles
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/files/
	$(CP) ./files/slider.sh $(PKG_BUILD_DIR)/files/slider.sh
	sed -i "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(PKG_BUILD_DIR)/files/slider.sh
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/slider-support/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/stabridge.hotplug $(1)/etc/hotplug.d/iface/99-stabridge
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DATA) ./files/slider.sh $(1)/usr/sbin/slider
	chmod 0755 $(1)/usr/sbin/slider
endef


define Package/$(PKG_NAME)/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		sed -i '\|sleep 10; /usr/sbin/slider &|d' /etc/rc.local
		sed -i '$i \sleep 10; /usr/sbin/slider &' /etc/rc.local
	fi
	source /usr/share/libubox/jshn.sh
	json_load "$(/bin/ubus call system board)"
	json_get_vars model
	model="$(echo $model | tr '[A-Z]' '[a-z]')"
	case $model in
	    gl-mt300n*)
				[ ! -s /etc/rc.button/BTN_0 ] && echo '#!/bin/sh' > /etc/rc.button/BTN_0
				echo '/usr/sbin/slider' >> /etc/rc.button/BTN_0
				chmod +x /etc/rc.button/BTN_0
	       ;;
	    gl-ar300m*)
				[ ! -s /etc/rc.button/BTN_1 ] && echo '#!/bin/sh' > /etc/rc.button/BTN_1
				echo '/usr/sbin/slider' >> /etc/rc.button/BTN_1
				chmod +x /etc/rc.button/BTN_1
        ;;
	    *)
				echo "$(PKG_NAME) Unknown router model: $model"
				logger -t "$(PKG_NAME)" "Unknown router model: $model"
        ;;
	esac
	exit 0
endef

define Package/$(PKG_NAME)/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		sed -i '\|sleep 10; /usr/sbin/slider &|d' /etc/rc.local
		source /usr/share/libubox/jshn.sh
		json_load "$(/bin/ubus call system board)"
		json_get_vars model
		model="$(echo $model | tr '[A-Z]' '[a-z]')"
		case $model in
				gl-mt300n*)
					rm -f /etc/rc.button/BTN_0
					 ;;
				gl-ar300m*)
					rm -f /etc/rc.button/BTN_1
					;;
		esac
	fi
	exit 0
endef

$(eval $(call BuildPackage,slider-support))

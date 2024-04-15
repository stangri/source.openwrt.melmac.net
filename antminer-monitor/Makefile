# Copyright 2017-2018 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=antminer-monitor
PKG_VERSION:=0.4.0
PKG_RELEASE:=6
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

include $(INCLUDE_DIR)/package.mk

define Package/antminer-monitor
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Antminer Monitor Service
	URL:=https://docs.openwrt.melmac.net/antminer-monitor/
	DEPENDS:=+python-light +python-pip
	PKGARCH:=all
endef

define Package/antminer-monitor/description
This service can be used to monitor Antminers on local network.
endef

AMSRC=v$(PKG_VERSION)
define Download/antminer-monitor
	URL:=https://github.com/anselal/$(PKG_NAME)/archive/
	FILE:=$(AMSRC).tar.gz
	HASH:=24491144471ba3df590cd1cb7be6a3f646f5ec3adf150cf214f9ed448414762d
endef
$(eval $(call Download,antminer-monitor))

define Build/Prepare
	$(PKG_UNPACK)
	tar -C $(PKG_BUILD_DIR) -xvzf $(DL_DIR)/$(AMSRC).tar.gz
	$(SED) '/logger\./d' $(PKG_BUILD_DIR)/antminer-monitor-$(PKG_VERSION)/app/views/antminer.py
	$(SED) "s/app.config\['DEBUG'\] = True/app.config\['DEBUG'\] = False/" $(PKG_BUILD_DIR)/antminer-monitor-$(PKG_VERSION)/app/__init__.py
	mkdir -p $(PKG_BUILD_DIR)/files/
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/antminer-monitor/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/antminer-monitor.init $(1)/etc/init.d/antminer-monitor
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/antminer-monitor
	$(CP) $(PKG_BUILD_DIR)/antminer-monitor-$(PKG_VERSION) $(1)/usr/sbin/antminer-monitor
endef

define Package/antminer-monitor/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/antminer-monitor enable
		/usr/bin/python -m pip install -r /usr/sbin/antminer-monitor/requirements.txt
		[ -s /tmp/antminer-monitor-backup.db ] && mv /tmp/antminer-monitor-backup.db /usr/sbin/antminer-monitor/app/db/app.db || true
		/usr/bin/python /usr/sbin/antminer-monitor/create_db.py
		/usr/bin/python /usr/sbin/antminer-monitor/update_db.py
	fi
	exit 0
endef

define Package/antminer-monitor/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/antminer-monitor stop || true
		/etc/init.d/antminer-monitor disable
		[ -s /usr/sbin/antminer-monitor/app/db/app.db ] && cp /usr/sbin/antminer-monitor/app/db/app.db /tmp/antminer-monitor-backup.db || true
		rm -rf /usr/sbin/antminer-monitor || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,antminer-monitor))

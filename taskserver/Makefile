include $(TOPDIR)/rules.mk

PKG_NAME:=taskserver
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/GothenburgBitFactory/taskserver
PKG_SOURCE_DATE:=1.2.0
PKG_SOURCE_VERSION:=13269ffa72622a4d6e8241e79038f4afcdc27fb0
PKG_MIRROR_HASH:=c447941744f85f8720cb3d00ebd027650fc7f99ae81ed950039900a5ba744a59
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/taskserver
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Taskserver
	DEPENDS:=+libgnutls +libstdcpp +libuuid
endef

define Package/taskserver/description
Taskserver is a daemon or service that will allow you to share tasks among different
client applications, primarily Taskwarrior.
Please see https://github.com/GothenburgBitFactory/taskserver for more information.
endef

define Package/taskserver/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/doc/taskd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/bin/taskd $(1)/usr/sbin/taskd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/bin/taskdctl $(1)/usr/sbin/taskdctl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/share/doc/taskd/NEWS $(1)/usr/share/doc/taskd/NEWS
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/share/doc/taskd/ChangeLog $(1)/usr/share/doc/taskd/ChangeLog
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/share/doc/taskd/INSTALL $(1)/usr/share/doc/taskd/INSTALL
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/share/doc/taskd/AUTHORS $(1)/usr/share/doc/taskd/AUTHORS
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/share/doc/taskd/COPYING $(1)/usr/share/doc/taskd/COPYING
endef

$(eval $(call BuildPackage,taskserver))

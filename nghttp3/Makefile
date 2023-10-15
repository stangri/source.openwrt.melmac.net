include $(TOPDIR)/rules.mk

PKG_NAME:=nghttp3
PKG_VERSION:=0.15.0
PKG_RELEASE:=rc3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/ngtcp2/nghttp3/releases/download/v$(PKG_VERSION)/
PKG_HASH:=3c56d9fa6f1b58b37bd7b1b53eaf16cd71118bc2d5cadbc904f09d6f6466b42f

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libnghttp3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=HTTP/3 library written in C
  URL:=https://nghttp2.org/nghttp3
endef

define Package/libnghttp3/description
nghttp3 is a thin HTTP/3 layer over an underlying QUIC stack.
endef

CONFIGURE_ARGS += --enable-lib-only

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/nghttp3
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/nghttp3/*.h $(1)/usr/include/nghttp3/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libnghttp3.so* $(1)/usr/lib/
endef

define Package/libnghttp3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libnghttp3.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libnghttp3))

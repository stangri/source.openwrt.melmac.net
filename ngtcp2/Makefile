include $(TOPDIR)/rules.mk

PKG_NAME:=ngtcp2
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/ngtcp2/ngtcp2/releases/download/v$(PKG_VERSION)/
PKG_HASH:=a40b18af654baaebee3431af9bb4e347f40080bf1189d658ad53f8e66bf39da3

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libngtcp2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Implementation of QUIC protocol
  URL:=https://nghttp2.org/ngtcp2
  DEPENDS:=+libnghttp3 +libopenssl
endef

define Package/libngtcp2/description
 ngtcp2 project is an effort to implement QUIC protocol which is now being discussed in IETF QUICWG for its standardization.
endef

CONFIGURE_ARGS += --enable-lib-only

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/ngtcp2
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/ngtcp2/*.h $(1)/usr/include/ngtcp2/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libngtcp2*.so* $(1)/usr/lib/
endef

define Package/libngtcp2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libngtcp2*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libngtcp2))

include $(TOPDIR)/rules.mk

PKG_NAME:=ngtcp2
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ngtcp2/ngtcp2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b566a7574a6c58bb19ec5b916300141283ef05139768de2b021ff37676b63dff

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libngtcp2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Implementation of QUIC protocol
  URL:=https://nghttp2.org/ngtcp2
  DEPENDS:=+libnghttp3
endef

define Package/libngtcp2/description
ngtcp2 project is an effort to implement QUIC protocol which is now being
discussed in IETF QUICWG for its standardization.
endef

CMAKE_OPTIONS += -DENABLE_LIB_ONLY=ON

define Package/libngtcp2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libngtcp2*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libngtcp2))

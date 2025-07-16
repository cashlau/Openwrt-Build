include $(TOPDIR)/rules.mk

PKG_NAME:=python3-netifaces
PKG_VERSION:=0.11.0
PKG_RELEASE:=1

PYPI_NAME:=netifaces
PKG_HASH:=0f9c1fe2e5adf2611b202cd18063aa98c650da13b3b1ce4068cd8c901c5ec1e0

PKG_SOURCE:=$(PYPI_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/n/netifaces
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PYPI_NAME)-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Your Name <you@example.com>

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-netifaces
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=netifaces module for Python
  URL:=https://pypi.org/project/netifaces/
  DEPENDS:=+python3
endef

define Package/python3-netifaces/description
  netifaces is a Python module that provides access to the information about 
  the network interfaces on the machine.
endef

$(eval $(call Py3Package,python3-netifaces))
$(eval $(call BuildPackage,python3-netifaces))

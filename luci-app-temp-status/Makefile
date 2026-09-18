#
# Based on luci-app-temp-status by gSpotx2f
# Licensed under the MIT License
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-temp-status
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

LUCI_TITLE:=Hardware temperature status for LuCI
LUCI_DEPENDS:=+ucode +ucode-mod-fs
LUCI_PKGARCH:=all

PKG_LICENSE:=MIT

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

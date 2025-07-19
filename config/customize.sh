#!/bin/bash
set -e

# 如果源码根目录就是 openwrt ，就保留
cd openwrt

# 修改默认 LAN IP
sed -i 's/192.168.1.1/192.168.50.2/g' package/base-files/files/bin/config_generate

# 设置时区和主机名
sed -i "s/'UTC'/'Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='OpenWrt'/hostname='HUAWEI'/g" package/base-files/files/bin/config_generate

# 修改默认主题为 argon，确保主题已存在
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

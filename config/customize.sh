#!/bin/bash
cd openwrt

# 默认 IP
sed -i 's/192.168.1.1/192.168.50.2/g' package/base-files/files/bin/config_generate

# 时区与主机名
sed -i "s/'UTC'/'Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='OpenWrt'/hostname='HUAWEI'/g" package/base-files/files/bin/config_generate

# 默认主题（可选）
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

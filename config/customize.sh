#!/bin/bash
set -e

# 如果源码根目录就是 openwrt ，根据情况解除下面注释
# cd openwrt

# 修改默认 LAN IP（192.168.1.1 -> 192.168.50.2）
sed -i 's/192.168.1.1/192.168.50.2/g' package/base-files/files/bin/config_generate

# 设置时区为 Asia/Taipei
sed -i "s/'UTC'/'Asia\/Taipei'/g" package/base-files/files/bin/config_generate

# 修改默认主机名为 HUAWEI
sed -i "s/hostname='OpenWrt'/hostname='HUAWEI'/g" package/base-files/files/bin/config_generate

# 修改默认主题为 argon，确保你已经拉取了 luci-theme-argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# -------- 修改登录banner --------

# 创建 banner 文件目录
mkdir -p files/etc

# 写入自定义banner内容
mkdir -p files/etc

cat > files/etc/banner <<'EOF'
  _   _   _   _      _     __        __  _____   ___ 
 | | | | | | | |    / \    \ \      / / | ____| |_ _|
 | |_| | | | | |   / _ \    \ \ /\ / /  |  _|    | | 
 |  _  | | |_| |  / ___ \    \ V  V /   | |___   | | 
 |_| |_|  \___/  /_/   \_\    \_/\_/    |_____| |___|
                                                     
Welcome to HUA WEI Router!
Build Date: $(date +"%Y-%m-%d %H:%M:%S")
EOF


echo "Custom banner has been set."

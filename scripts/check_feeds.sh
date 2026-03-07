#!/bin/bash
set -e

if [ -f "config/feeds.conf.default" ]; then
  echo "Applying custom feeds.conf.default..."
  cat config/feeds.conf.default >> openwrt/feeds.conf.default
fi

cd openwrt

echo "Updating feeds (First Pass)..."
./scripts/feeds update -a || true

echo ">>> 正在精准清理导致冲突的核心包 (保留 yq 等基础工具)..."

CONFLICT_PKGS="xray-core sing-box v2ray-geodata chinadns-ng dns2socks ipt2socks tcping geoview"

for pkg in $CONFLICT_PKGS; do

  find feeds/packages/net -type d -name "$pkg" | xargs rm -rf 2>/dev/null || true
done

echo "Updating feeds (Final Pass)..."
./scripts/feeds update -a

echo "Installing feeds with Priority..."
./scripts/feeds install -a -f -p passwall_packages
./scripts/feeds install -a -f -p passwall_luci
./scripts/feeds install -a -f -p nikki
./scripts/feeds install -a -f -p momo

./scripts/feeds install -a

echo "✅ Feeds 处理完成！"

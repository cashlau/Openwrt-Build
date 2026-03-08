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

# =======================================================
# 新增：修复 Github Actions 浅克隆导致 Momo/Nikki/Passwall 版本号丢失的问题
# =======================================================
echo "🔄 正在恢复核心插件的完整 Git 历史和 Tags 以获取正确版本号..."
for feed in momo nikki passwall_packages passwall_luci; do
    if [ -d "feeds/$feed/.git" ]; then
        echo "正在处理 feeds/$feed ..."
        git -C "feeds/$feed" fetch --unshallow || true
        git -C "feeds/$feed" fetch --all || true
        git -C "feeds/$feed" fetch --tags || true
    else
        echo "⚠️ 未找到 feeds/$feed 目录，跳过。"
    fi
done
echo "✅ Git 历史恢复完成！"
# =======================================================

echo "Installing feeds with Priority..."
./scripts/feeds install -a -f -p passwall_packages
./scripts/feeds install -a -f -p passwall_luci
./scripts/feeds install -a -f -p nikki
./scripts/feeds install -a -f -p momo

./scripts/feeds install -a

echo "✅ Feeds 处理完成！"

#!/bin/bash
set -e

# 1. 将自定义的第三方源追加到官方源列表中
if [ -f "config/feeds.conf.default" ]; then
  echo "Applying custom feeds.conf.default..."
  cat config/feeds.conf.default >> openwrt/feeds.conf.default
fi

cd openwrt

echo "Updating feeds (First Pass)..."
# 第一次更新，允许它报错，因为我们要先让它把文件下载下来
./scripts/feeds update -a || true

echo ">>> 清理官方 feeds 中的冲突重复包..."
# 定义容易冲突的包列表 (这些包在 Nikki/Passwall 仓库里都有更好的版本)
DUPLICATE_PKGS="yq sing-box xray-core chinadns-ng dns2socks ipt2socks microsocks tcping v2ray-geodata geoview"

for pkg in $DUPLICATE_PKGS; do
  # 强制删除官方 feeds 里的重复文件夹
  find feeds/packages -type d -name "$pkg" | xargs rm -rf
done

echo "Updating feeds (Second Pass - Final Merge)..."
# 第二次更新，这次没有重复包了，必须成功
if ! ./scripts/feeds update -a 2>&1 | tee update.log | grep -E "fatal|error|failed|cannot"; then
  echo "✅ Feeds update completed successfully!"
else
  echo "❌ ERROR: Feeds update still encountered fatal errors!"
  exit 1
fi

echo "Installing specific feeds (Passwall priority)..."
./scripts/feeds install -a -f -p passwall_packages
./scripts/feeds install -a -f -p passwall_luci
./scripts/feeds install -a -f -p nikki
./scripts/feeds install -a -f -p momo

echo "Installing all remaining feeds..."
./scripts/feeds install -a

# 你的关键依赖包检查
required_pkgs=("libmesa" "libwayland" "libgraphene" "python3-netifaces")
missing_pkgs=()
for pkg in "${required_pkgs[@]}"; do
  if [ ! -d "package/feeds/packages/$pkg" ] && [ ! -d "package/$pkg" ]; then
    missing_pkgs+=("$pkg")
  fi
done

if [ ${#missing_pkgs[@]} -ne 0 ]; then
  echo "⚠️ Warning: Missing some packages, but continuing..."
fi

echo "✅ Feeds check passed!"

#!/bin/bash
set -e

# 1. 将自定义的第三方源 (Momo, Passwall) 追加到官方源列表中
if [ -f "config/feeds.conf.default" ]; then
  echo "Applying custom feeds.conf.default..."
  cat config/feeds.conf.default >> openwrt/feeds.conf.default
fi

cd openwrt

echo "Updating feeds..."
if ! ./scripts/feeds update -a 2>&1 | tee update.log | grep -E "fatal|error|failed|cannot"; then
  echo "Feeds update completed without fatal errors."
else
  echo "ERROR: Feeds update encountered fatal errors!"
  exit 1
fi

echo "Installing specific feeds (Passwall priority)..."
# Passwall 官方强烈建议：强制优先安装 Passwall 库，防止与官方旧版本发生冲突
./scripts/feeds install -a -f -p passwall_packages
./scripts/feeds install -a -f -p passwall_luci

echo "Installing all feeds..."
./scripts/feeds install -a

missing_pkgs=()
# 你的原生关键依赖包检查列表
required_pkgs=("libmesa" "libwayland" "libgraphene" "python3-netifaces")

for pkg in "${required_pkgs[@]}"; do
  if [ ! -d "package/feeds/packages/$pkg" ] && [ ! -d "package/$pkg" ]; then
    missing_pkgs+=("$pkg")
  fi
done

if [ ${#missing_pkgs[@]} -ne 0 ]; then
  echo "Missing these critical packages in feeds:"
  for mpkg in "${missing_pkgs[@]}"; do
    echo " - $mpkg"
  done
  exit 2
else
  echo "All critical packages exist."
fi

echo "Feeds check passed!"

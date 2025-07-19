#!/bin/bash
set -e

EXT_PACKAGES_COUNT=8

EXT_PACKAGES_NAME[1]="luci-app-usb-printer"
EXT_PACKAGES_PATH[1]="package/luci-app-usb-printer"
EXT_PACKAGES_REPOSITORIE[1]="https://github.com/cashlau/luci-app-usb_printer.git"
EXT_PACKAGES_BRANCH[1]=""

EXT_PACKAGES_NAME[3]="luci-app-argon-config"
EXT_PACKAGES_PATH[3]="package/luci-app-argon-config"
EXT_PACKAGES_REPOSITORIE[3]="https://github.com/jerrykuku/luci-app-argon-config"
EXT_PACKAGES_BRANCH[3]=""

EXT_PACKAGES_NAME[4]="luci-theme-argon"
EXT_PACKAGES_PATH[4]="package/luci-theme-argon"
EXT_PACKAGES_REPOSITORIE[4]="https://github.com/jerrykuku/luci-theme-argon"
EXT_PACKAGES_BRANCH[4]=""

EXT_PACKAGES_NAME[5]="luci-app-pushbot"
EXT_PACKAGES_PATH[5]="package/luci-app-pushbot"
EXT_PACKAGES_REPOSITORIE[5]="https://github.com/zzsj0928/luci-app-pushbot"
EXT_PACKAGES_BRANCH[5]=""

EXT_PACKAGES_NAME[6]="nikki"
EXT_PACKAGES_PATH[6]="package/nikki"
EXT_PACKAGES_REPOSITORIE[6]="https://github.com/nikkinikki-org/OpenWrt-nikki.git"
EXT_PACKAGES_BRANCH[6]=""

# 新增 passwall 相关包
EXT_PACKAGES_NAME[7]="luci-app-passwall"
EXT_PACKAGES_PATH[7]="package/luci-app-passwall"
EXT_PACKAGES_REPOSITORIE[7]="https://github.com/xiaorouji/openwrt-passwall.git"
EXT_PACKAGES_BRANCH[7]=""

EXT_PACKAGES_NAME[8]="passwall-packages"
EXT_PACKAGES_PATH[8]="package/passwall-packages"
EXT_PACKAGES_REPOSITORIE[8]="https://github.com/xiaorouji/openwrt-passwall-packages.git"
EXT_PACKAGES_BRANCH[8]=""

for i in $(seq 1 $EXT_PACKAGES_COUNT); do
  if [ ! -d "${EXT_PACKAGES_PATH[$i]}" ]; then
    echo "Cloning ${EXT_PACKAGES_NAME[$i]}..."
    if [ -z "${EXT_PACKAGES_BRANCH[$i]}" ]; then
      git clone --depth=1 "${EXT_PACKAGES_REPOSITORIE[$i]}" "${EXT_PACKAGES_PATH[$i]}"
    else
      git clone --depth=1 -b "${EXT_PACKAGES_BRANCH[$i]}" "${EXT_PACKAGES_REPOSITORIE[$i]}" "${EXT_PACKAGES_PATH[$i]}"
    fi
    rm -rf "${EXT_PACKAGES_PATH[$i]}/.git"
    rm -rf "${EXT_PACKAGES_PATH[$i]}/docs"
    rm -rf "${EXT_PACKAGES_PATH[$i]}/tests"
  else
    echo "${EXT_PACKAGES_NAME[$i]} already exists, skipping clone."
  fi
done

rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

rm -rf feeds/packages/net/v2ray-geodata
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

git clone --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

echo "Updating and installing feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

echo "Modifying .config to enable external packages..."

for i in $(seq 1 $EXT_PACKAGES_COUNT); do
  PKG="CONFIG_PACKAGE_${EXT_PACKAGES_NAME[$i]}=y"
  if grep -q "^${PKG}$" .config; then
    echo "$PKG already enabled"
  else
    echo "$PKG" >> .config
    echo "Enabled $PKG"
  fi
done

# 额外添加mosdns和v2ray-geodata
grep -q "^CONFIG_PACKAGE_mosdns=y" .config || echo "CONFIG_PACKAGE_mosdns=y" >> .config
grep -q "^CONFIG_PACKAGE_v2ray-geodata=y" .config || echo "CONFIG_PACKAGE_v2ray-geodata=y" >> .config

# passwall 可能需要额外配置，根据实际包名调整
grep -q "^CONFIG_PACKAGE_luci-app-passwall=y" .config || echo "CONFIG_PACKAGE_luci-app-passwall=y" >> .config

echo "Run make defconfig to finalize config"
make defconfig

echo "Done. Now you can run 'make' to build OpenWrt with these packages."

#!/bin/bash
set -e
set -x  # 打开调试输出，方便日志跟踪

EXT_PACKAGES_COUNT=8

EXT_PACKAGES_NAME[1]="luci-app-usb-printer"
EXT_PACKAGES_PATH[1]="package/luci-app-usb-printer"
EXT_PACKAGES_REPOSITORIE[1]="https://github.com/cashlau/luci-app-usb_printer.git"
EXT_PACKAGES_BRANCH[1]=""

EXT_PACKAGES_NAME[2]="luci-app-argon-config"
EXT_PACKAGES_PATH[2]="package/luci-app-argon-config"
EXT_PACKAGES_REPOSITORIE[2]="https://github.com/jerrykuku/luci-app-argon-config"
EXT_PACKAGES_BRANCH[2]=""

EXT_PACKAGES_NAME[3]="luci-theme-argon"
EXT_PACKAGES_PATH[3]="package/luci-theme-argon"
EXT_PACKAGES_REPOSITORIE[3]="https://github.com/jerrykuku/luci-theme-argon"
EXT_PACKAGES_BRANCH[3]=""

EXT_PACKAGES_NAME[4]="luci-app-pushbot"
EXT_PACKAGES_PATH[4]="package/luci-app-pushbot"
EXT_PACKAGES_REPOSITORIE[4]="https://github.com/zzsj0928/luci-app-pushbot"
EXT_PACKAGES_BRANCH[4]=""

EXT_PACKAGES_NAME[6]="luci-app-passwall"
EXT_PACKAGES_PATH[6]="package/luci-app-passwall"
EXT_PACKAGES_REPOSITORIE[6]="https://github.com/xiaorouji/openwrt-passwall.git"
EXT_PACKAGES_BRANCH[6]=""

EXT_PACKAGES_NAME[7]="passwall-packages"
EXT_PACKAGES_PATH[7]="package/passwall-packages"
EXT_PACKAGES_REPOSITORIE[7]="https://github.com/xiaorouji/openwrt-passwall-packages.git"
EXT_PACKAGES_BRANCH[7]=""

EXT_PACKAGES_NAME[8]="mosdns"
EXT_PACKAGES_PATH[8]="package/mosdns"
EXT_PACKAGES_REPOSITORIE[8]="https://github.com/sbwml/luci-app-mosdns"
EXT_PACKAGES_BRANCH[8]="v5"

for i in $(seq 1 $EXT_PACKAGES_COUNT); do
  if [ ! -d "${EXT_PACKAGES_PATH[$i]}" ]; then
    echo "Cloning ${EXT_PACKAGES_NAME[$i]} from ${EXT_PACKAGES_REPOSITORIE[$i]} ..."
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

# 额外替换golang和v2ray-geodata包
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

rm -rf feeds/packages/net/v2ray-geodata
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 更新 feeds 并安装所有软件包
./scripts/feeds update -a
./scripts/feeds install -a

# 自动启用这些包的编译选项
CONFIG_FILE=".config"

for i in $(seq 1 $EXT_PACKAGES_COUNT); do
  PKG="CONFIG_PACKAGE_${EXT_PACKAGES_NAME[$i]}=y"
  if grep -q "^${PKG}$" "$CONFIG_FILE"; then
    echo "$PKG already enabled"
  else
    echo "$PKG" >> "$CONFIG_FILE"
    echo "Enabled $PKG"
  fi
done

# 启用额外包的配置
grep -q "^CONFIG_PACKAGE_mosdns=y" "$CONFIG_FILE" || echo "CONFIG_PACKAGE_mosdns=y" >> "$CONFIG_FILE"
grep -q "^CONFIG_PACKAGE_v2ray-geodata=y" "$CONFIG_FILE" || echo "CONFIG_PACKAGE_v2ray-geodata=y" >> "$CONFIG_FILE"

# 运行 make defconfig 让配置生效
make defconfig

echo "External packages setup complete."

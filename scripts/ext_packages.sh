#!/bin/bash
set -e

EXT_PACKAGES_COUNT=6

EXT_PACKAGES_NAME[1]="luci-app-usb-printer"
EXT_PACKAGES_PATH[1]="applications/luci-app-usb-printer"
EXT_PACKAGES_REPOSITORIE[1]="https://github.com/coolsnowwolf/luci"
EXT_PACKAGES_BRANCH[1]=""


EXT_PACKAGES_NAME[3]="luci-app-argon-config"
EXT_PACKAGES_PATH[3]="applications/luci-app-argon-config"
EXT_PACKAGES_REPOSITORIE[3]="https://github.com/jerrykuku/luci-app-argon-config"
EXT_PACKAGES_BRANCH[3]=""

EXT_PACKAGES_NAME[4]="luci-theme-argon"
EXT_PACKAGES_PATH[4]="applications/luci-theme-argon"
EXT_PACKAGES_REPOSITORIE[4]="https://github.com/jerrykuku/luci-theme-argon"
EXT_PACKAGES_BRANCH[4]=""

EXT_PACKAGES_NAME[5]="luci-app-pushbot"
EXT_PACKAGES_PATH[5]="applications/luci-app-pushbot"
EXT_PACKAGES_REPOSITORIE[5]="https://github.com/zzsj0928/luci-app-pushbot"
EXT_PACKAGES_BRANCH[5]=""

EXT_PACKAGES_NAME[6]="nikki"
EXT_PACKAGES_PATH[6]="applications/nikki"
EXT_PACKAGES_REPOSITORIE[6]="https://github.com/nikkinikki-org/OpenWrt-nikki.git"
EXT_PACKAGES_BRANCH[6]=""

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

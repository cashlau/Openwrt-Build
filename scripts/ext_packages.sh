#!/bin/bash
set -e
set -x  # 打开调试输出，方便日志跟踪

declare -A EXT_PACKAGES_NAME=(
  [1]="luci-app-usb-printer"
  [2]="luci-app-argon-config"
  [3]="luci-theme-argon"
  [4]="luci-app-pushbot"
  [5]="luci-app-passwall"
  [6]="passwall-packages"
  [7]="mosdns"
  [8]="nikki"
  [9]="luci-app-netspeedtest"
)

declare -A EXT_PACKAGES_PATH=(
  [1]="package/luci-app-usb-printer"
  [2]="package/luci-app-argon-config"
  [3]="package/luci-theme-argon"
  [4]="package/luci-app-pushbot"
  [5]="package/luci-app-passwall"
  [6]="package/passwall-packages"
  [7]="package/mosdns"
  [8]="package/OpenWrt-nikki"
  [9]="package/luci-app-netspeedtest"
)

declare -A EXT_PACKAGES_REPOSITORY=(
  [1]="https://github.com/cashlau/luci-app-usb_printer.git"
  [2]="https://github.com/jerrykuku/luci-app-argon-config"
  [3]="https://github.com/jerrykuku/luci-theme-argon"
  [4]="https://github.com/zzsj0928/luci-app-pushbot"
  [5]="https://github.com/xiaorouji/openwrt-passwall.git"
  [6]="https://github.com/xiaorouji/openwrt-passwall-packages.git"
  [7]="https://github.com/sbwml/luci-app-mosdns"
  [8]="https://github.com/nikkinikki-org/OpenWrt-nikki.git"
  [9]="https://github.com/muink/luci-app-netspeedtest.git"
)

declare -A EXT_PACKAGES_BRANCH=(
  [1]=""
  [2]=""
  [3]=""
  [4]=""
  [5]=""
  [6]=""
  [7]="v5"
  [8]="main"
  [9]="master"
)

for i in "${!EXT_PACKAGES_NAME[@]}"; do
  pkg_name="${EXT_PACKAGES_NAME[$i]}"
  pkg_path="${EXT_PACKAGES_PATH[$i]}"
  pkg_repo="${EXT_PACKAGES_REPOSITORY[$i]}"
  pkg_branch="${EXT_PACKAGES_BRANCH[$i]}"

  if [ ! -d "$pkg_path" ]; then
    echo "Cloning $pkg_name from $pkg_repo ..."
    if [ -z "$pkg_branch" ]; then
      git clone --depth=1 "$pkg_repo" "$pkg_path"
    else
      git clone --depth=1 -b "$pkg_branch" "$pkg_repo" "$pkg_path"
    fi
    rm -rf "$pkg_path/.git" "$pkg_path/docs" "$pkg_path/tests"
  else
    echo "$pkg_name already exists, skipping clone."
  fi
done

# 额外替换golang和v2ray-geodata包
#rm -rf feeds/packages/lang/golang
#git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

#rm -rf feeds/packages/net/v2ray-geodata
#git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 更新 feeds 并安装所有软件包
./scripts/feeds update -a
./scripts/feeds install -a

# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages

# 移除 openwrt feeds 过时的luci版本
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall-luci

# 自动启用这些包的编译选项
CONFIG_FILE=".config"

for i in "${!EXT_PACKAGES_NAME[@]}"; do
  PKG="CONFIG_PACKAGE_${EXT_PACKAGES_NAME[$i]}=y"
  if grep -q "^${PKG}$" "$CONFIG_FILE"; then
    echo "$PKG already enabled"
  else
    echo "$PKG" >> "$CONFIG_FILE"
    echo "Enabled $PKG"
  fi
done

# 启用额外包的配置（保证mosdns和v2ray-geodata被启用）
grep -q "^CONFIG_PACKAGE_mosdns=y" "$CONFIG_FILE" || echo "CONFIG_PACKAGE_mosdns=y" >> "$CONFIG_FILE"
grep -q "^CONFIG_PACKAGE_v2ray-geodata=y" "$CONFIG_FILE" || echo "CONFIG_PACKAGE_v2ray-geodata=y" >> "$CONFIG_FILE"

# 运行 make defconfig 让配置生效
make defconfig

echo "External packages setup complete."

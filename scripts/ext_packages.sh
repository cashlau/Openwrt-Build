#!/bin/bash
set -e
set -x  # 打开调试输出，方便日志跟踪

# ===============================
# 外部扩展包配置
# ===============================
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
  [7]="v5"      # ✅ luci-app-mosdns 最新版本分支
  [8]="main"
  [9]="master"
)

# ===============================
# 克隆外部包
# ===============================
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

# ===============================
# 替换 Go 工具链（mosdns v5 必须）
# ===============================
echo ">>> Replacing golang with sbwml Go 1.24.x"
rm -rf feeds/packages/lang/golang
git clone --depth=1 -b 25.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# ===============================
# 更新 feeds 并安装所有软件包
# ===============================
./scripts/feeds update -a
./scripts/feeds install -a

# ===============================
# 移除 OpenWrt 自带旧核心库
# ===============================
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}

# ===============================
# 强制覆盖 passwall 相关
# ===============================
rm -rf package/passwall-packages
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages.git package/passwall-packages

rm -rf feeds/luci/applications/luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/passwall-luci

# ===============================
# 启用编译选项
# ===============================
CONFIG_FILE=".config"

for i in "${!EXT_PACKAGES_NAME[@]}"; do
  PKG="CONFIG_PACKAGE_${EXT_PACKAGES_NAME[$i]}=y"
  if ! grep -q "^${PKG}$" "$CONFIG_FILE"; then
    echo "$PKG" >> "$CONFIG_FILE"
    echo "Enabled $PKG"
  else
    echo "$PKG already enabled"
  fi
done

# 强制启用核心依赖
grep -q "^CONFIG_PACKAGE_mosdns=y" "$CONFIG_FILE" || echo "CONFIG_PACKAGE_mosdns=y" >> "$CONFIG_FILE"
grep -q "^CONFIG_PACKAGE_v2ray-geodata=y" "$CONFIG_FILE" || echo "CONFIG_PACKAGE_v2ray-geodata=y" >> "$CONFIG_FILE"

# ===============================
# 生成配置
# ===============================
make defconfig

echo "✅ External packages setup complete."

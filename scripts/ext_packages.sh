#!/bin/bash
set -e
set -x  # 开启调试输出

# ===============================
# 1. 外部扩展包配置
# ===============================
declare -A EXT_PACKAGES_NAME=(
  [1]="luci-app-usb-printer"
  [2]="luci-app-argon-config"
  [3]="luci-theme-argon"
  [4]="luci-app-pushbot"
  [7]="mosdns"
  [8]="nikki"
  [9]="luci-app-netspeedtest"
)

declare -A EXT_PACKAGES_PATH=(
  [1]="package/luci-app-usb-printer"
  [2]="package/luci-app-argon-config"
  [3]="package/luci-theme-argon"
  [4]="package/luci-app-pushbot"
  [7]="package/mosdns"
  [8]="package/OpenWrt-nikki"
  [9]="package/luci-app-netspeedtest"
)

declare -A EXT_PACKAGES_REPOSITORY=(
  [1]="https://github.com/cashlau/luci-app-usb_printer.git"
  [2]="https://github.com/jerrykuku/luci-app-argon-config"
  [3]="https://github.com/jerrykuku/luci-theme-argon"
  [4]="https://github.com/zzsj0928/luci-app-pushbot"
  [7]="https://github.com/sbwml/luci-app-mosdns"
  [8]="https://github.com/nikkinikki-org/OpenWrt-nikki.git"
  [9]="https://github.com/muink/luci-app-netspeedtest.git"
)

declare -A EXT_PACKAGES_BRANCH=(
  [1]=""
  [2]=""
  [3]=""
  [4]=""
  [7]="v5"
  [8]="main"
  [9]="master"
)

# ===============================
# 2. 克隆非 feeds 的扩展包
# ===============================
for i in "${!EXT_PACKAGES_NAME[@]}"; do
  pkg_name="${EXT_PACKAGES_NAME[$i]}"
  pkg_path="${EXT_PACKAGES_PATH[$i]}"
  pkg_repo="${EXT_PACKAGES_REPOSITORY[$i]}"
  pkg_branch="${EXT_PACKAGES_BRANCH[$i]}"

  rm -rf "$pkg_path" # 确保目录干净
  echo "Cloning $pkg_name ..."
  if [ -z "$pkg_branch" ]; then
    git clone --depth=1 "$pkg_repo" "$pkg_path"
  else
    git clone --depth=1 -b "$pkg_branch" "$pkg_repo" "$pkg_path"
  fi
  rm -rf "$pkg_path/.git"
done

# ===============================
# 3. 处理 OpenWrt-momo
# ===============================
if [ ! -d "package/momo" ]; then
  rm -rf package/OpenWrt-momo
  git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-momo.git package/OpenWrt-momo
  mv package/OpenWrt-momo/momo package/momo
  mv package/OpenWrt-momo/luci-app-momo package/luci-app-momo
  [ -d "package/OpenWrt-momo/luci-i18n-momo-zh-cn" ] && mv package/OpenWrt-momo/luci-i18n-momo-zh-cn package/luci-i18n-momo-zh-cn
  rm -rf package/OpenWrt-momo
fi

# ===============================
# 4. 替换 Go 工具链 (OpenWrt 25.12.0 编译高版本插件必备)
# ===============================
echo ">>> Replacing golang with sbwml Go 25.x"
rm -rf feeds/packages/lang/golang
git clone --depth=1 -b 25.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# ===============================
# 5. 清理官方冲突包 (不要在这里 install，交给 .yml 处理)
# ===============================
echo ">>> 正在清理官方 feeds 中的冲突组件..."
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}

# ===============================
# 6. 写入编译选项到 .config
# ===============================
CONFIG_FILE=".config"

# 启用上面循环中克隆的所有包
for i in "${!EXT_PACKAGES_NAME[@]}"; do
  echo "CONFIG_PACKAGE_${EXT_PACKAGES_NAME[$i]}=y" >> "$CONFIG_FILE"
done

# 启用 Passwall (因为它在 feeds 里，所以手动写一行)
echo "CONFIG_PACKAGE_luci-app-passwall=y" >> "$CONFIG_FILE"
echo "CONFIG_PACKAGE_luci-app-passwall_Iptables_Transparent_Proxy=y" >> "$CONFIG_FILE"

# 启用 momo 及其语言包
echo "CONFIG_PACKAGE_momo=y" >> "$CONFIG_FILE"
echo "CONFIG_PACKAGE_luci-app-momo=y" >> "$CONFIG_FILE"
[ -d "package/luci-i18n-momo-zh-cn" ] && echo "CONFIG_PACKAGE_luci-i18n-momo-zh-cn=y" >> "$CONFIG_FILE"

# 启用核心依赖
echo "CONFIG_PACKAGE_mosdns=y" >> "$CONFIG_FILE"
echo "CONFIG_PACKAGE_v2ray-geodata=y" >> "$CONFIG_FILE"

echo "✅ 扩展包拉取与冲突清理完成！(后续的安装和配置生成将由 Github Actions 接管)"

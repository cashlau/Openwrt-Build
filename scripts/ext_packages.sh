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
  [5]="mosdns"
  [6]="luci-app-netspeedtest"
)

declare -A EXT_PACKAGES_PATH=(
  [1]="package/luci-app-usb-printer"
  [2]="package/luci-app-argon-config"
  [3]="package/luci-theme-argon"
  [4]="package/luci-app-pushbot"
  [5]="package/mosdns"
  [6]="package/luci-app-netspeedtest"
)

declare -A EXT_PACKAGES_REPOSITORY=(
  [1]="https://github.com/cashlau/luci-app-usb_printer.git"
  [2]="https://github.com/jerrykuku/luci-app-argon-config"
  [3]="https://github.com/jerrykuku/luci-theme-argon"
  [4]="https://github.com/zzsj0928/luci-app-pushbot"
  [5]="https://github.com/sbwml/luci-app-mosdns"
  [6]="https://github.com/muink/luci-app-netspeedtest.git"
)

declare -A EXT_PACKAGES_BRANCH=(
  [1]=""
  [2]=""
  [3]=""
  [4]=""
  [5]="v5"
  [6]="master"
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
# 3. 特殊处理：v2ray-geodata 与 Go 工具链
# ===============================
# 按照 sbwml 的建议拉取 v2ray-geodata 源码
rm -rf package/v2ray-geodata
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 替换 Go 工具链 (OpenWrt 25.12.0 编译高版本插件必备)
echo ">>> Replacing golang with sbwml Go 25.x"
rm -rf feeds/packages/lang/golang
git clone --depth=1 -b 25.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# ===============================
# 4. 写入编译选项到 .config
# ===============================
CONFIG_FILE=".config"

# 自动写入上面数组里定义好的所有包
for i in "${!EXT_PACKAGES_NAME[@]}"; do
  echo "CONFIG_PACKAGE_${EXT_PACKAGES_NAME[$i]}=y" >> "$CONFIG_FILE"
done

# 注意：Momo、Passwall 和 Nikki 的基础勾选已经在你的基础 config/.config 文件里了
# 这里只追加其他杂项和依赖
echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> "$CONFIG_FILE"
echo "CONFIG_PACKAGE_v2ray-geodata=y" >> "$CONFIG_FILE"

echo "✅ 扩展包拉取与配置写入完成！"

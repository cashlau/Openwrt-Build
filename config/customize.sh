#!/bin/bash
set -e

# 在 OpenWrt 源码根目录执行，顺序：
# 安装 feeds → 执行本脚本 → make defconfig → 编译

CONFIG_FILE="package/base-files/files/bin/config_generate"
LUCIMK="feeds/luci/collections/luci/Makefile"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TEMP_STATUS_SRC="$REPO_ROOT/luci-app-temp-status"

if [ ! -f "$CONFIG_FILE" ] || [ ! -f ".config" ]; then
    echo "❌ 请在已有 .config 的 OpenWrt 源码根目录执行本脚本"
    exit 1
fi


# -------- 检查自有 luci-app-temp-status --------

for file in \
    "$TEMP_STATUS_SRC/Makefile" \
    "$TEMP_STATUS_SRC/LICENSE" \
    "$TEMP_STATUS_SRC/htdocs/luci-static/resources/view/status/include/27_temperature.js" \
    "$TEMP_STATUS_SRC/root/usr/share/rpcd/ucode/luci.temp-status" \
    "$TEMP_STATUS_SRC/root/usr/share/rpcd/acl.d/luci-app-temp-status.json"
do
    if [ ! -s "$file" ]; then
        echo "❌ 自有温度插件文件不存在或为空：$file"
        exit 1
    fi
done

echo "✅ 自有 luci-app-temp-status 文件检查完成"


# -------- 固定使用 MT7925 20260605 Wi-Fi 固件 --------

MT7925_FW_COMMIT="bd1c66cf"
MT7925_FW_BASE="https://kernel.googlesource.com/pub/scm/linux/kernel/git/firmware/linux-firmware/+/${MT7925_FW_COMMIT}/mediatek/mt7925"
MT7925_FW_DEST="files/lib/firmware/mediatek/mt7925"

mkdir -p "$MT7925_FW_DEST"

for firmware in \
    WIFI_MT7925_PATCH_MCU_1_1_hdr.bin \
    WIFI_RAM_CODE_MT7925_1_1.bin
do
    wget -qO- "${MT7925_FW_BASE}/${firmware}?format=TEXT" |
        base64 -d > "${MT7925_FW_DEST}/${firmware}"

    if [ ! -s "${MT7925_FW_DEST}/${firmware}" ]; then
        echo "❌ MT7925 固件下载失败：${firmware}"
        exit 1
    fi
done

(
    cd "$MT7925_FW_DEST"

    echo "089dd0252a7eb95feed55950ad0fd9e6f751a07b4cf22273de722b73fa50d49e  WIFI_MT7925_PATCH_MCU_1_1_hdr.bin" |
        sha256sum -c -

    echo "7e4ed27d1e9fe21cdefda35a22da32137b2473fada350617fb603489af19346a  WIFI_RAM_CODE_MT7925_1_1.bin" |
        sha256sum -c -
)

echo "✅ MT7925 20260605 Wi-Fi 固件已写入镜像覆盖目录"


# -------- 内置 Momo 规则集 --------

RULE_DIR="files/etc/momo/rules"
mkdir -p "$RULE_DIR"

while read -r name url; do
    echo "下载 Momo 规则：$name"

    if ! wget -q --tries=3 --timeout=30 -O "$RULE_DIR/$name" "$url"; then
        echo "❌ 规则下载失败：$name"
        exit 1
    fi

    if [ ! -s "$RULE_DIR/$name" ]; then
        echo "❌ 规则文件为空：$name"
        exit 1
    fi
done <<'EOF'
geosite-fakeipfilter.json https://raw.githubusercontent.com/qichiyuhub/rule/main/rules/fakeipfilter.json
geosite-ai.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/category-ai-!cn.srs
geosite-youtube.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/youtube.srs
geosite-google.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/google.srs
geosite-github.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/github.srs
geosite-onedrive.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/onedrive.srs
geosite-microsoft.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/microsoft.srs
geosite-apple.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/apple.srs
geosite-telegram.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/telegram.srs
geosite-tiktok.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/tiktok.srs
geosite-netflix.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/netflix.srs
geosite-paypal.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/paypal.srs
geosite-steamcn.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/steam@cn.srs
geosite-steam.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/steam.srs
geosite-!cn.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/geolocation-!cn.srs
geosite-cn.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/cn.srs
geoip-google.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/google.srs
geoip-apple.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo-lite/geoip/apple.srs
geoip-telegram.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/telegram.srs
geoip-netflix.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/netflix.srs
geoip-cn.srs https://raw.githubusercontent.com/qljsyph/ruleset-icon/main/sing-box/geoip/China-ASN-combined-ip.srs
geosite-speedtest.srs https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/speedtest.srs
geosite-anti-ad.srs https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblocksingbox.srs
geosite-siri.srs https://raw.githubusercontent.com/cashlau/sing-box-rules/main/rules/siri.srs
EOF

echo "✅ Momo 初始规则已写入固件"

# -------- 修改默认配置 --------

sed -i 's/192\.168\.1\.1/192.168.50.1/g' "$CONFIG_FILE"
sed -i "s/hostname='OpenWrt'/hostname='HUAWEI'/g" "$CONFIG_FILE"
sed -i "s/timezone='UTC'/timezone='CST-8'/g" "$CONFIG_FILE"

if grep -Eq '^[[:space:]]*set system\.@system\[-1\]\.zonename=' "$CONFIG_FILE"; then
    sed -i \
        "s|^\([[:space:]]*set system\.@system\[-1\]\.zonename=\).*|\1'Asia/Taipei'|" \
        "$CONFIG_FILE"
else
    sed -i \
        "/set system\.@system\[-1\]\.timezone='CST-8'/a\\
        set system.@system[-1].zonename='Asia/Taipei'" \
        "$CONFIG_FILE"
fi

if [ -f "$LUCIMK" ]; then
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$LUCIMK"
fi

echo "✅ 默认配置修改完成"


# -------- 修改登录 banner --------

mkdir -p files/etc
BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')
cat <<'EOT' > files/etc/banner
 __    __   __    __       ___   ____    __    ____  _______  __  
|  |  |  | |  |  |  |     /   \  \   \  /  \  /   / |   ____||  | 
|  |__|  | |  |  |  |    /  ^  \  \   \/    \/   /  |  |__   |  | 
|   __   | |  |  |  |   /  /_\  \  \            /   |   __|  |  | 
|  |  |  | |  `--'  |  /  _____  \  \    /\    /    |  |____ |  | 
|__|  |__|  \______/  /__/     \__\  \__/  \__/     |_______||__| 
                                                                                                                    
-----------------------------------------------------------------                                                                                          
Welcome to HUA WEI Router!
Build Date: __BUILD_DATE__
EOT

sed -i "s|__BUILD_DATE__|$BUILD_DATE|g" files/etc/banner

echo "✅ Custom banner has been set."


# -------- DHCP 顺序分配 --------

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-dhcp-sequential <<'EOF'
#!/bin/sh
uci set dhcp.lan.start='10'
uci set dhcp.lan.limit='150'
uci set dhcp.@dnsmasq[0].sequential_ip='1'
uci commit dhcp
EOF

chmod +x files/etc/uci-defaults/99-dhcp-sequential

echo "✅ DHCP 顺序配置写入完成"


# -------- 自动识别实体网口，固定 eth1 为 PPPoE WAN --------

mkdir -p files/etc/board.d

cat > files/etc/board.d/99-default_network <<'EOF'
#!/bin/sh

. /lib/functions/uci-defaults.sh

wan_if="eth1"
lan_if=""

# 只接受 eth + 数字命名、且存在硬件 device 的网口。
# 排除 VLAN、桥接、隧道等虚拟接口。
for path in /sys/class/net/eth*; do
    [ -e "$path" ] || continue
    [ -e "$path/device" ] || continue

    iface="${path##*/}"
    suffix="${iface#eth}"

    case "$suffix" in
        ''|*[!0-9]*) continue ;;
    esac

    [ "$iface" = "$wan_if" ] && continue
    lan_if="${lan_if:+$lan_if }$iface"
done

# 不满足条件时保留原板级网络定义。
if [ ! -e "/sys/class/net/$wan_if/device" ] || [ -z "$lan_if" ]; then
    logger -t default-network \
        "未找到 eth1 或没有可用 LAN 网口，保留默认网络定义"
    exit 0
fi

board_config_update

# 清除原 LAN/WAN 接口定义，避免残留 ports/device。
# 其余板级信息保持原样。
json_select_object network
json_remove lan
json_remove wan
json_select ..

ucidef_set_interface_lan "$lan_if"
ucidef_set_interface_wan "$wan_if" "pppoe"

board_config_flush

logger -t default-network "WAN=$wan_if (PPPoE), LAN=$lan_if"
exit 0
EOF

chmod +x files/etc/board.d/99-default_network

echo "✅ 网络初始化脚本写入完成：eth1 为 WAN，其余实体 eth 网口为 LAN"


# -------- 默认使用 Argon 主题 --------

cat > files/etc/uci-defaults/99-argon-temp <<'EOF'
#!/bin/sh
set -e

uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

exit 0
EOF

chmod +x files/etc/uci-defaults/99-argon-temp


# -------- 加入自有 luci-app-temp-status --------

TEMP_STATUS_DIR="package/custom/luci-app-temp-status"

# 删除编译树中可能存在的其它同名包，避免重复定义。
for old_dir in \
    package/luci-app-temp-status \
    package/feeds/*/luci-app-temp-status
do
    if [ -e "$old_dir" ] || [ -L "$old_dir" ]; then
        echo "ℹ️ 移除同名温度插件：$old_dir"
        rm -rf "$old_dir"
    fi
done

# 每次重新复制自己的插件，避免残留旧文件。
rm -rf "$TEMP_STATUS_DIR"
mkdir -p "$TEMP_STATUS_DIR"

cp -a "$TEMP_STATUS_SRC/." "$TEMP_STATUS_DIR/"

if [ ! -s "$TEMP_STATUS_DIR/Makefile" ]; then
    echo "❌ luci-app-temp-status 复制失败"
    exit 1
fi

if [ ! -s "$TEMP_STATUS_DIR/htdocs/luci-static/resources/view/status/include/27_temperature.js" ] || \
   [ ! -s "$TEMP_STATUS_DIR/root/usr/share/rpcd/ucode/luci.temp-status" ] || \
   [ ! -s "$TEMP_STATUS_DIR/root/usr/share/rpcd/acl.d/luci-app-temp-status.json" ]; then
    echo "❌ luci-app-temp-status 文件复制不完整"
    exit 1
fi

echo "✅ 自有 luci-app-temp-status 已加入编译树"


# -------- 添加编译配置，避免重复条目 --------

enable_package() {
    local option="CONFIG_PACKAGE_$1"

    sed -i \
        -e "/^${option}=/d" \
        -e "/^# ${option} is not set$/d" \
        .config

    printf '%s=y\n' "$option" >> .config
}

enable_package luci-theme-argon
enable_package luci-app-temp-status
enable_package kmod-hwmon-coretemp
enable_package kmod-video-uvc
enable_package ppp-mod-pppoe

echo "✅ 温度驱动、温度插件、Argon、UVC、PPPoE 编译配置已加入"


# -------- 关闭代理插件默认启用开关 --------

NIKKI_CONFIG="package/feeds/nikki/nikki/files/nikki.config"
PASSWALL_CONFIG="package/feeds/passwall_luci/luci-app-passwall/root/etc/config/passwall"

if [ -f "$NIKKI_CONFIG" ]; then
    sed -i \
        "s/^[[:space:]]*option[[:space:]]\+enabled[[:space:]].*/\toption enabled '0'/" \
        "$NIKKI_CONFIG"
else
    echo "ℹ️ 未找到指定 Nikki 配置路径，跳过源码修改"
fi

if [ -f "$PASSWALL_CONFIG" ]; then
    sed -i \
        "s/^[[:space:]]*option[[:space:]]\+enabled[[:space:]].*/\toption enabled '0'/" \
        "$PASSWALL_CONFIG"
else
    echo "ℹ️ 未找到指定 PassWall 配置路径，跳过源码修改"
fi

# 首次启动时再关闭服务自启，避免仅修改配置但服务仍被启动。
cat > files/etc/uci-defaults/99-disable-proxy-autostart <<'EOF'
#!/bin/sh

for service in nikki passwall; do
    if [ -x "/etc/init.d/$service" ]; then
        "/etc/init.d/$service" disable
        "/etc/init.d/$service" stop
    fi
done

exit 0
EOF

chmod +x files/etc/uci-defaults/99-disable-proxy-autostart


# -------- 首次启动时禁用指定 APK 软件源 --------

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-disable-custom-apk-feeds <<'EOF'
#!/bin/sh
set -e

FEEDS_FILE="/etc/apk/repositories.d/distfeeds.list"

# 文件不存在时保留脚本，下次启动再尝试。
[ -f "$FEEDS_FILE" ] || exit 1

# 只注释指定源，已注释的行不会重复添加 #。
sed -i \
    -e '\|^[[:space:]]*https\?://.*/momo/packages\.adb[[:space:]]*$|s/^/#/' \
    -e '\|^[[:space:]]*https\?://.*/nikki/packages\.adb[[:space:]]*$|s/^/#/' \
    -e '\|^[[:space:]]*https\?://.*/passwall_luci/packages\.adb[[:space:]]*$|s/^/#/' \
    -e '\|^[[:space:]]*https\?://.*/passwall_packages/packages\.adb[[:space:]]*$|s/^/#/' \
    -e '\|^[[:space:]]*https\?://.*/rtp2httpd/packages\.adb[[:space:]]*$|s/^/#/' \
    "$FEEDS_FILE"

exit 0
EOF

chmod +x files/etc/uci-defaults/99-disable-custom-apk-feeds

echo "✅ APK 指定软件源自动注释脚本已写入"

echo "🎉 全部操作完成！请在后续编译步骤执行 make defconfig"

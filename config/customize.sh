#!/bin/bash
set -e

# 在 OpenWrt 源码根目录执行，顺序：
# 安装 feeds → 执行本脚本 → make defconfig → 编译

CONFIG_FILE="package/base-files/files/bin/config_generate"
LUCIMK="feeds/luci/collections/luci/Makefile"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$CONFIG_FILE" ] || [ ! -f ".config" ]; then
    echo "❌ 请在已有 .config 的 OpenWrt 源码根目录执行本脚本"
    exit 1
fi

# -------- 查找已上传的温度卡片文件 --------

TEMP_JS=""

for candidate in \
    "$SCRIPT_DIR/27_temperature.js" \
    "$PWD/27_temperature.js" \
    "$PWD/config/27_temperature.js" \
    "${GITHUB_WORKSPACE:-$PWD}/config/27_temperature.js"
do
    if [ -s "$candidate" ]; then
        TEMP_JS="$candidate"
        break
    fi
done

if [ -z "$TEMP_JS" ]; then
    echo "❌ 未找到 27_temperature.js"
    echo "请确认 config/27_temperature.js 已提交到仓库，"
    echo "且编译流程保留该文件或将它复制到源码根目录。"
    exit 1
fi

# -------- 查找自动识别硬件型号的后台文件 --------

TEMP_BACKEND=""

for candidate in \
    "$SCRIPT_DIR/luci.temp-status" \
    "$PWD/luci.temp-status" \
    "$PWD/config/luci.temp-status" \
    "${GITHUB_WORKSPACE:-$PWD}/config/luci.temp-status"
do
    if [ -s "$candidate" ]; then
        TEMP_BACKEND="$candidate"
        break
    fi
done

if [ -z "$TEMP_BACKEND" ]; then
    echo "❌ 未找到 config/luci.temp-status，请先上传后台文件"
    exit 1
fi

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

# -------- 添加温度插件并覆盖概览卡片 --------

# 优先复用已有插件源码，避免重复下载同名包。
TEMP_STATUS_DIR=""

for candidate in \
    package/custom/luci-app-temp-status \
    package/luci-app-temp-status \
    package/feeds/*/luci-app-temp-status
do
    if [ -f "$candidate/Makefile" ]; then
        TEMP_STATUS_DIR="$candidate"
        break
    fi
done

if [ -z "$TEMP_STATUS_DIR" ]; then
    TEMP_STATUS_DIR="package/custom/luci-app-temp-status"
    mkdir -p package/custom

    git clone --depth=1 \
        https://github.com/gSpotx2f/luci-app-temp-status.git \
        "$TEMP_STATUS_DIR"
fi

if [ ! -s "${TEMP_JS:-}" ] || [ ! -s "${TEMP_BACKEND:-}" ]; then
    echo "❌ 温度文件路径无效，请检查 config/27_temperature.js 和 config/luci.temp-status"
    printf 'TEMP_JS=%s\nTEMP_BACKEND=%s\n' "${TEMP_JS:-}" "${TEMP_BACKEND:-}"
    exit 1
fi

install -Dm0644 "$TEMP_JS" \
    "$TEMP_STATUS_DIR/htdocs/luci-static/resources/view/status/include/27_temperature.js"

install -Dm0644 "$TEMP_BACKEND" \
    "$TEMP_STATUS_DIR/root/usr/share/rpcd/ucode/luci.temp-status"

echo "✅ Argon 温度卡片及硬件型号识别后台已加入"

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
    -e '\|^[[:space:]]*https\?://.*/video/packages\.adb[[:space:]]*$|s/^/#/' \
    "$FEEDS_FILE"

exit 0
EOF

chmod +x files/etc/uci-defaults/99-disable-custom-apk-feeds

echo "✅ APK 指定软件源自动注释脚本已写入"

echo "🎉 全部操作完成！请在后续编译步骤执行 make defconfig"

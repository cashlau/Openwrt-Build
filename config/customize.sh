#!/bin/bash
set -e

# -------- 修改默认配置 --------

#!/bin/bash

CONFIG_FILE="package/base-files/files/bin/config_generate"
LUCIMK="feeds/luci/collections/luci/Makefile"

sed -i "s/192.168.1.1/192.168.50.2/g" "$CONFIG_FILE"
sed -i "s/set system.@system\[-1\].hostname='OpenWrt'/set system.@system[-1].hostname='HUAWEI'/" "$CONFIG_FILE"
sed -i "s/set system.@system\[-1\].timezone='UTC'/set system.@system[-1].timezone='CST-8'/" "$CONFIG_FILE"
grep -q "set system.@system\[-1\].zonename=" "$CONFIG_FILE" || \
  sed -i "/set system.@system\[-1\].timezone='CST-8'/a\		set system.@system[-1].zonename='Asia/Taipei'" "$CONFIG_FILE"
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$LUCIMK"
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


# -------- 自动桥接 LAN 口及设置 WAN --------

mkdir -p files/etc/board.d

cat > files/etc/board.d/99-default_network <<'EOF'
#!/bin/sh

. /lib/functions/system.sh
. /lib/functions/uci-defaults.sh

board_config_update

case "$(board_name)" in
*)
    eth_ifaces=$(ip -o link show | awk -F': ' '{print $2}' | sed 's/ //g' | grep '^e' | grep -vE "(@|\.)")

    count=$(echo "$eth_ifaces" | wc -l)

    if [ "$count" -gt 2 ]; then
        wan_if="eth1"
        lan_if=$(echo "$eth_ifaces" | grep -v "^$wan_if$" | tr '\n' ' ' | sed 's/ $//')
        ucidef_set_interfaces_lan_wan "$lan_if" "$wan_if"
    else
        ucidef_set_interfaces_lan_wan "eth0" "eth1"
    fi
    ;;
esac

board_config_flush

exit 0
EOF

chmod +x files/etc/board.d/99-default_network

echo "✅ 自动网口识别脚本写入完成"
echo "全部操作完成！"

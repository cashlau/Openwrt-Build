#!/bin/bash
set -e

CONFIG_FILE="package/base-files/files/bin/config_generate"
LUCIMK="feeds/luci/collections/luci/Makefile"

# 1. 修改默认 LAN IP（192.168.1.1 -> 192.168.50.2）
sed -i "s/192.168.1.1/192.168.50.2/g" "$CONFIG_FILE"

# 2. 修改默认主机名（OpenWrt -> HUAWEI）
sed -i "s/hostname='OpenWrt'/hostname='HUAWEI'/g" "$CONFIG_FILE"

# 3. 删除旧的 timezone 和 zonename 设置，防止重复
sed -i "/set system.@system\[-1\].timezone/d" "$CONFIG_FILE"
sed -i "/set system.@system\[-1\].zonename/d" "$CONFIG_FILE"

# 4. 在设置主机名的行后追加新的时区和时区名设置
sed -i "/hostname='HUAWEI'/a \\
uci set system.@system[-1].timezone='CST-8';\\
uci set system.@system[-1].zonename='Asia/Taipei';" "$CONFIG_FILE"

# 5. 修改默认主题为 argon，确保你已经拉取了 luci-theme-argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$LUCIMK"

echo "✅ config_generate 已成功修改："
echo "- LAN IP => 192.168.50.2"
echo "- 主机名 => HUAWEI"
echo "- 时区 => CST-8"
echo "- 时区名 => Asia/Taipei"
echo "- 默认主题 => luci-theme-argon"


# -------- 修改登录 banner --------

#!/bin/bash

# 创建 banner 文件目录
mkdir -p files/etc

# 生成构建时间
BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# 使用 cat <<'EOF' 保留原始格式，避免 shell 替换 ASCII 字符
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

# 替换占位符
sed -i "s|__BUILD_DATE__|$BUILD_DATE|g" files/etc/banner

echo "✅ Custom banner has been set."



# -------- 设置 DHCP 顺序分配和起始地址 --------

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-dhcp-sequential <<'EOF'
#!/bin/sh
uci set dhcp.lan.start='10'
uci set dhcp.lan.limit='150'
uci set dhcp.@dnsmasq[0].sequential_ip='1'
uci commit dhcp
EOF

chmod +x files/etc/uci-defaults/99-dhcp-sequential
echo "DHCP 顺序分配设置已完成（起始地址 .10）"


# -------- 自动桥接 LAN 口及设置 WAN PPPoE --------

cat > files/etc/uci-defaults/99-auto-network <<'EOF'
#!/bin/sh

wan_if="eth1"

# 收集所有以 eth 开头且不是 wan_if 的接口
lan_ports=""
for iface in $(ls /sys/class/net | grep '^eth'); do
  [ "$iface" != "$wan_if" ] && lan_ports="$lan_ports $iface"
done

# 删除旧的 lan/wans 配置
uci -q delete network.lan
uci -q delete network.wan
uci -q delete network.wan6

# 删除旧的 br-lan 设备配置（防止重复）
for dev in $(uci show network | grep "=device" | cut -d. -f2); do
  [ "$(uci get network.$dev.name 2>/dev/null)" = "br-lan" ] && uci delete network.$dev
done

# 新建桥接设备 br-lan
uci set network.br_lan=device
uci set network.br_lan.type='bridge'
uci set network.br_lan.name='br-lan'

# 添加所有 lan_ports 到 br-lan 的 ports 列表
for port in $lan_ports; do
  uci add_list network.br_lan.ports="$port"
done

# 配置 LAN 接口绑定到 br-lan
uci set network.lan=interface
uci set network.lan.device='br-lan'
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.50.2'
uci set network.lan.netmask='255.255.255.0'

# 配置 WAN 接口（pppoe）
uci set network.wan=interface
uci set network.wan.device="$wan_if"
uci set network.wan.proto='pppoe'
uci set network.wan.username=''
uci set network.wan.password=''
uci set network.wan.ipv6='0'

# 配置 WAN6（dhcpv6）
uci set network.wan6=interface
uci set network.wan6.device="$wan_if"
uci set network.wan6.proto='dhcpv6'

# 提交配置
uci commit network

exit 0

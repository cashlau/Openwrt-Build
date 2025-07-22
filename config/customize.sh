#!/bin/bash
set -e

# 如果源码根目录就是 openwrt ，根据情况解除下面注释
# cd openwrt

# 修改默认 LAN IP（192.168.1.1 -> 192.168.50.2）
sed -i 's/192.168.1.1/192.168.50.2/g' package/base-files/files/bin/config_generate

# 设置时区为 Asia/Taipei
sed -i "s/'UTC'/'Asia\/Taipei'/g" package/base-files/files/bin/config_generate

# 修改默认主机名为 HUAWEI
sed -i "s/hostname='OpenWrt'/hostname='HUAWEI'/g" package/base-files/files/bin/config_generate

# 修改默认主题为 argon，确保你已经拉取了 luci-theme-argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

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

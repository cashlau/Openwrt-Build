#!/bin/bash
set -e

CONFIG_FILE="openwrt/package/base-files/files/etc/uci-defaults/99-custom-settings"

mkdir -p "$(dirname "$CONFIG_FILE")"

cat > "$CONFIG_FILE" <<EOF
#!/bin/sh

# 设置时区
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'

# 设置主机名
uci set system.@system[0].hostname='OpenWrt-X86'

# 设置 LAN 默认 IP
uci set network.lan.ipaddr='192.168.50.5'

# 设置 root 密码为空
passwd -d root

# 提交更改
uci commit system
uci commit network
EOF

chmod +x "$CONFIG_FILE"

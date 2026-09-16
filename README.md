# OpenWrt x86_64 Build

简体中文 | [English](README.en.md) | [正體中文](README.zh-TW.md)

基于官方 OpenWrt 源码，通过 GitHub Actions 自动编译集成常用插件的 **x86_64 固件**，并发布至 GitHub Releases。

可直接下载使用，也可以 **Fork 本仓库**，根据自己的硬件和需求修改插件、配置及编译选项，通过 GitHub Actions 自行编译。如需调整依赖或功能，可使用 ChatGPT、Claude 等 AI 工具辅助修改。

---

### 主要功能

- 自动拉取 OpenWrt 官方最新稳定版源码并使用 GitHub Actions 编译
- 支持 English、简体中文、正體中文
- 默认使用 **PPPoE** 拨号，LAN 地址：`192.168.50.1`
- 支持 **Intel X710 万兆光网卡**
- 支持查看 CPU、NVMe、芯片组及部分无线网卡温度
- 每周三自动检查并编译最新稳定版本
- 支持自行 Fork、修改插件及编译配置

### 默认插件

- **Passwall**：网络代理及规则分流
- **MosDNS**：DNS 分流、优化及广告域名过滤
- **全能推送**：微信、钉钉、Telegram 等消息通知
- **WOL 网络唤醒**：支持 Etherwake、Wake-on-LAN
- **动态 DNS**：自动更新动态公网 IP
- **Nikki**：基于 Mihomo 的透明代理管理插件
- **Momo**：基于 Sing-Box 的透明代理管理插件
- **rtp2httpd**：IPTV RTP / UDP 转 HTTP
- **USB 打印服务器**：局域网共享 USB 打印机
- **Cloudflare Tunnel**：无需开放公网端口即可访问内部服务

插件及软件源配置详见 `scripts/ext_packages.sh` 和 `feeds.conf.default`。

---

### 使用方法

浏览器访问：`http://192.168.50.1`  
默认用户名：`root`，首次登录请设置密码。  
固件下载：https://github.com/cashlau/Openwrt-Build/releases

### 自行编译

Fork 本仓库 → 修改配置 → 打开 **Actions** → **Run workflow** → 等待编译完成，即可在 Releases 或 Actions 中下载固件，无需本地搭建编译环境。

### 注意事项

- 仅针对 **x86_64** 平台编译和测试
- 首次刷写或跨大版本升级建议不要保留旧配置
- 默认使用 PPPoE，需自行填写宽带账号密码
- 已测试部分 Intel X710 网卡，其他硬件请自行测试
- 建议升级前备份配置，首次设置使用有线连接
- 第三方插件可能因上游更新出现兼容或编译问题

### 免责声明

本项目仅供 OpenWrt 学习、研究及个人设备使用。固件基于 OpenWrt 官方源码及第三方开源插件构建，不对第三方插件的安全性、稳定性和兼容性作保证。刷写前请备份重要数据并确认设备兼容性。

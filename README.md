# OpenWrt x86_64 Build

[简体中文](README.md) | [English](README.en.md) | [正體中文](README.zh-TW.md)

[![Latest Release](https://img.shields.io/github/v/release/cashlau/OpenWrt-Build?label=Latest%20Release&style=flat-square)](https://github.com/cashlau/OpenWrt-Build/releases/latest)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-Official-00B5E2?logo=openwrt&logoColor=white&style=flat-square)](https://openwrt.org/)

基于官方 OpenWrt 源码，通过 GitHub Actions 自动编译集成常用插件的 x86_64 固件，并发布至 GitHub Releases。

可直接下载使用，也可以 **Fork 本仓库**，根据自己的硬件和需求修改插件、配置及编译选项，通过 GitHub Actions 自行编译。

---
> **提示：** 如需了解各功能、配置项或编译流程，可将**本仓库链接**提供给 **ChatGPT、Claude、Gemini** 等 AI 工具进行解读和辅助配置。
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

- **PassWall**：透明代理、规则分流及服务端功能，支持远程接入家庭网络并经软路由代理出口上网
- **MosDNS**：DNS 分流、优化及广告域名过滤
- **全能推送**：微信、钉钉、Telegram 等消息通知
- **WOL 网络唤醒**：支持 Etherwake、Wake-on-LAN
- **动态 DNS**：公网 IP 变化时自动更新域名解析记录
- **Nikki**：基于 Mihomo 的透明代理管理插件
- **Momo**：基于 sing-box 的透明代理管理插件
- **rtp2httpd**：IPTV RTP / UDP 转 HTTP
- **USB 打印服务器**：局域网共享 USB 打印机
- **Cloudflare Tunnel**：无需开放公网端口即可访问内部服务

插件及软件源配置详见 `scripts/ext_packages.sh` 和 `feeds.conf.default`。

---

### 使用方法

浏览器访问：`http://192.168.50.1`  
默认用户名：`root`，首次登录请设置密码。  
固件下载：https://github.com/cashlau/OpenWrt-Build/releases

### 自行编译

Fork 本仓库 → 修改配置 → 打开 **Actions** → **Run workflow** → 等待编译完成，即可在 Releases 或 Actions 中下载固件，无需本地搭建编译环境。

### 注意事项

- 仅针对 **x86_64** 平台编译和测试
- 首次刷写或跨大版本升级建议不要保留旧配置
- 默认使用 PPPoE，需自行填写宽带账号密码
- 已测试部分 Intel X710 网卡，其他硬件请自行测试
- 建议升级前备份配置，首次设置使用有线连接
- 第三方插件可能因上游更新出现兼容或编译问题

## 免责声明

本项目仅供 OpenWrt 学习、研究及个人设备使用。固件基于 OpenWrt 官方源码及第三方开源插件构建，不对第三方插件的安全性、稳定性及兼容性作任何保证。

使用本项目产生的设备异常、配置丢失、数据损坏或网络故障等风险由使用者自行承担。刷写固件前请备份重要数据，并确认设备及硬件兼容性。

部分功能可能受地区、网络环境及相关法规限制，请使用者自行确认并遵守所在地的法律法规及服务条款。

---

### LuCI 界面预览

<img width="1920" height="1031" alt="image" src="https://github.com/user-attachments/assets/b384eb96-0c18-4a43-a084-0f3f25ac5874" />

## 致谢

感谢 [OpenWrt](https://github.com/openwrt/openwrt) 项目以及所有第三方开源软件的作者和维护者。

本项目使用或集成了以下开源项目：

- [PassWall](https://github.com/Openwrt-Passwall/openwrt-passwall)
- [MosDNS](https://github.com/sbwml/luci-app-mosdns)
- [Nikki](https://github.com/nikkinikki-org/OpenWrt-nikki)
- [Momo](https://github.com/nikkinikki-org/OpenWrt-momo)
- [Argon](https://github.com/jerrykuku/luci-theme-argon) — 默认 LuCI 主题

感谢所有开发者及贡献者为开源社区所做的贡献。

各项目的版权及许可证归其原作者所有。


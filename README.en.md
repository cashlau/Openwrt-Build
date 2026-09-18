# OpenWrt x86_64 Build

[简体中文](README.md) | [English](README.en.md) | [正體中文](README.zh-TW.md)

[![Latest Release](https://img.shields.io/github/v/release/cashlau/OpenWrt-Build?label=Latest%20Release&style=flat-square)](https://github.com/cashlau/OpenWrt-Build/releases/latest)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-Official-00B5E2?logo=openwrt&logoColor=white&style=flat-square)](https://openwrt.org/)

Automatically builds OpenWrt x86_64 firmware from the official OpenWrt source with commonly used packages via GitHub Actions, and publishes the builds to GitHub Releases.

You can download the prebuilt firmware directly, or **Fork this repository** and customize packages, configuration, and build options for your own hardware. **ChatGPT**, **Claude**, or other AI tools can also help with dependency and configuration changes.

---
> **Tip:** If you need help understanding the features, configuration options, or build process, you can provide the **repository URL** to AI tools such as **ChatGPT, Claude, or Gemini** for explanation and configuration assistance.
---

### Features

- Automatically tracks the latest stable OpenWrt source and builds with GitHub Actions
- Supports English, Simplified Chinese, and Traditional Chinese
- Uses **PPPoE** by default; LAN address: `192.168.50.1`
- Includes support for **Intel X710 10GbE adapters**
- Shows temperatures for CPU, NVMe, chipset, and some wireless adapters
- Automatically checks and builds every Wednesday
- Can be freely forked and customized

### Included Packages

- **PassWall**: Transparent proxy, rule-based traffic routing, and server-side functionality, with support for remote access to your home network through the router's proxy gateway
- **MosDNS**: DNS routing, optimization, and ad-domain filtering
- **PushBot**: Notifications for WeChat, DingTalk, Telegram, and more
- **Wake on LAN**: Etherwake and Wake-on-LAN support
- **Dynamic DNS**: Automatically updates DNS records when the public IP address changes
- **Nikki**: Mihomo-based transparent proxy manager
- **Momo**: Sing-Box-based transparent proxy manager
- **rtp2httpd**: Converts IPTV RTP / UDP streams to HTTP
- **USB Print Server**: Shares USB printers over the LAN
- **Cloudflare Tunnel**: Access internal services without directly exposing public ports

Package and feed configuration can be found in `scripts/ext_packages.sh` and `feeds.conf.default`.

---

### Usage

Open: `http://192.168.50.1`  
Default username: `root`. Please set a password after first login.  
Firmware downloads: https://github.com/cashlau/OpenWrt-Build/releases

### Build It Yourself

Fork this repository → edit the configuration → open **Actions** → click **Run workflow** → wait for the build to finish. The firmware can then be downloaded from Releases or Actions, with no local OpenWrt build environment required.

### Notes

- Built and tested for **x86_64** only
- Do not keep old configuration on first flash or major-version upgrades
- PPPoE is enabled by default; enter your broadband username and password manually
- Intel X710 adapters are tested; other hardware should be tested individually
- Back up your configuration before upgrades and use a wired connection for initial setup
- Third-party packages may occasionally fail to build or become incompatible after upstream updates

## Disclaimer

This project is intended solely for OpenWrt learning, research, and personal device use. The firmware is built from the official OpenWrt source code together with third-party open-source packages. No guarantee is made regarding the security, stability, or compatibility of third-party packages.

Users assume all risks associated with using this project, including device malfunction, configuration loss, data loss, or network issues. Please back up important data and verify hardware compatibility before flashing the firmware.

Some features may be subject to regional restrictions, network conditions, applicable laws, regulations, or service terms. Users are responsible for ensuring compliance with the laws and service terms applicable in their region.

---

### Homepage Preview

<img width="1920" height="1031" alt="image" src="https://github.com/user-attachments/assets/c18197b7-25f0-4156-9105-a3e84a8d308f" />

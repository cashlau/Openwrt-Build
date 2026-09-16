# OpenWrt x86_64 Build

[简体中文](README.md) | English | [正體中文](README.zh-TW.md)

Automatically builds an **x86_64 OpenWrt firmware** from the official OpenWrt source using GitHub Actions, with commonly used packages included and releases published to GitHub Releases.

You can download the prebuilt firmware directly, or **Fork this repository** and customize packages, configuration, and build options for your own hardware. ChatGPT, Claude, or other AI tools can also help with dependency and configuration changes.

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

- **Passwall**: Proxy management and traffic routing
- **MosDNS**: DNS routing, optimization, and ad-domain filtering
- **All-in-One Push**: Notifications for WeChat, DingTalk, Telegram, and more
- **WOL**: Etherwake and Wake-on-LAN support
- **Dynamic DNS**: Automatically updates DNS records for dynamic public IP addresses
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
Firmware downloads: https://github.com/cashlau/Openwrt-Build/releases

### Build It Yourself

Fork this repository → edit the configuration → open **Actions** → click **Run workflow** → wait for the build to finish. The firmware can then be downloaded from Releases or Actions, with no local OpenWrt build environment required.

### Notes

- Built and tested for **x86_64** only
- Do not keep old configuration on first flash or major-version upgrades
- PPPoE is enabled by default; enter your broadband username and password manually
- Intel X710 adapters are tested; other hardware should be tested individually
- Back up your configuration before upgrades and use a wired connection for initial setup
- Third-party packages may occasionally fail to build or become incompatible after upstream updates

### Disclaimer

This project is intended for OpenWrt learning, research, and personal use. Firmware is built from official OpenWrt source together with third-party open-source packages. No guarantee is made regarding the security, stability, or compatibility of third-party packages. Back up important data and confirm hardware compatibility before flashing.

### Homepage Preview

<img width="1920" height="1031" alt="image" src="https://github.com/user-attachments/assets/c18197b7-25f0-4156-9105-a3e84a8d308f" />

# OpenWrt x86_64 Build

[簡體中文](README.md) | [English](README.en.md) | **正體中文**

[![Latest Release](https://img.shields.io/github/v/release/cashlau/OpenWrt-Build?label=Latest%20Release&style=flat-square)](https://github.com/cashlau/OpenWrt-Build/releases/latest)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-Official-00B5E2?logo=openwrt&logoColor=white&style=flat-square)](https://openwrt.org/)

基於官方 OpenWrt 原始碼，透過 GitHub Actions 自動編譯整合常用外掛的 x86_64 韌體，並發佈至 GitHub Releases。

可直接下載使用，也可以 **Fork 本儲存庫**，依照自己的硬體與需求修改外掛、設定及編譯選項，透過 GitHub Actions 自行編譯。

---
> **提示：** 如需瞭解各項功能、設定項目或編譯流程，可將**本儲存庫連結**提供給 **ChatGPT、Claude、Gemini** 等 AI 工具進行解讀及協助設定。
---

### 主要功能

- 自動取得 OpenWrt 官方最新穩定版原始碼並使用 GitHub Actions 編譯
- 預設採用 **Argon LuCI 主題**，提供更現代化的 Web 管理介面
- 預設支援 正體中文、简体中文、English
- 預設使用 **PPPoE 撥號**，多網口設備預設將 **eth1** 設為 WAN，其餘實體網口作為 LAN；不符合條件時保留 OpenWrt 預設網路設定
- 支援 **Intel X710 萬兆網路卡**
- 支援查看 CPU、NVMe、晶片組及部分無線網路卡溫度
- 每週三自動檢查並編譯最新穩定版本
- 支援自行 Fork、修改外掛及編譯設定

### 預設外掛

- **PassWall**：透明代理、規則分流及伺服器端功能，支援遠端接入家庭網路並經軟路由代理出口上網
- **MosDNS**：DNS 分流、最佳化及廣告網域過濾
- **全能推送**：微信、釘釘、Telegram 等訊息通知
- **WOL 網路喚醒**：支援 Etherwake、Wake-on-LAN
- **動態 DNS**：公網 IP 變更時自動更新網域名稱解析記錄
- **Nikki**：基於 Mihomo 的透明代理管理外掛
- **Momo**：基於 Sing-Box 的透明代理管理外掛
- **rtp2httpd**：IPTV RTP / UDP 轉 HTTP
- **USB 列印伺服器**：區域網路共享 USB 印表機
- **Cloudflare Tunnel**：無需直接開放公網連接埠即可存取內部服務

外掛及軟體來源設定請參考 `scripts/ext_packages.sh` 和 `feeds.conf.default`。

---

## 使用方法

瀏覽器開啟：`http://192.168.50.1`

- 預設使用者名稱：`root`
- 預設密碼：空白
- 首次登入後請立即設定密碼
韌體下載：https://github.com/cashlau/OpenWrt-Build/releases

### 自行編譯

Fork 本專案 → 修改設定 → 開啟 **Actions** → **Run workflow** → 等待編譯完成，即可在 Releases 或 Actions 中下載韌體，不需要在本機建立 OpenWrt 編譯環境。

### 注意事項

- 僅針對 **x86_64** 平台編譯與測試
- 首次刷寫或跨大版本升級時建議不要保留舊設定
- 預設使用 PPPoE，需自行填寫寬頻帳號與密碼
- 已測試部分 Intel X710 網路卡，其他硬體請自行測試
- 建議升級前備份設定，首次設定時使用有線連線
- 第三方外掛可能因上游更新而出現相容性或編譯問題

## 免責聲明

本專案僅供 OpenWrt 學習、研究及個人設備使用。韌體基於 OpenWrt 官方原始碼及第三方開源外掛建置，不對第三方外掛的安全性、穩定性及相容性作任何保證。

使用本專案所產生的設備異常、設定遺失、資料損壞或網路故障等風險由使用者自行承擔。刷寫韌體前請備份重要資料，並確認設備及硬體相容性。

部分功能可能受到地區、網路環境及相關法規限制，請使用者自行確認並遵守所在地的法律法規及服務條款。

---

## LuCI 介面預覽

<img width="1920" height="1031" alt="image" src="https://github.com/user-attachments/assets/535a58fc-8838-4473-b146-71cb28f683a0" />

## 致謝

感謝 [OpenWrt](https://github.com/openwrt/openwrt) 專案以及所有第三方開源軟體的作者與維護者。

本專案使用或整合了以下開源專案：

- [PassWall](https://github.com/Openwrt-Passwall/openwrt-passwall)
- [MosDNS](https://github.com/sbwml/luci-app-mosdns)
- [Nikki](https://github.com/nikkinikki-org/OpenWrt-nikki)
- [Momo](https://github.com/nikkinikki-org/OpenWrt-momo)
- [Argon](https://github.com/jerrykuku/luci-theme-argon) — 預設 LuCI 主題

感謝所有開發者及貢獻者為開源社群所做的貢獻。

各專案的版權及授權條款歸其原作者所有。


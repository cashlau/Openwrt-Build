# OpenWrt x86_64 Build

[简体中文](README.md) | [English](README.en.md) | 正體中文

基於官方 OpenWrt 原始碼，透過 GitHub Actions 自動編譯整合常用外掛的 **x86_64 韌體**，並發佈至 GitHub Releases。

可直接下載使用，也可以 **Fork 本專案**，依照自己的硬體與需求修改外掛、設定及編譯選項，再透過 GitHub Actions 自行編譯。如需調整相依套件或功能，也可使用 ChatGPT、Claude 等 AI 工具協助修改。

---

### 主要功能

- 自動取得 OpenWrt 官方最新穩定版原始碼並使用 GitHub Actions 編譯
- 支援 English、简体中文、正體中文
- 預設使用 **PPPoE** 撥號，LAN 位址：`192.168.50.1`
- 支援 **Intel X710 萬兆網路卡**
- 支援查看 CPU、NVMe、晶片組及部分無線網路卡溫度
- 每週三自動檢查並編譯最新穩定版本
- 支援自行 Fork、修改外掛及編譯設定

### 預設外掛

- **Passwall**：透明代理、規則分流及伺服器端功能，支援遠端接入家庭網路並經軟路由代理出口上網
- **MosDNS**：DNS 分流、最佳化及廣告網域過濾
- **全能推送**：微信、釘釘、Telegram 等訊息通知
- **WOL 網路喚醒**：支援 Etherwake、Wake-on-LAN
- **動態 DNS**：自動更新動態公網 IP
- **Nikki**：基於 Mihomo 的透明代理管理外掛
- **Momo**：基於 Sing-Box 的透明代理管理外掛
- **rtp2httpd**：IPTV RTP / UDP 轉 HTTP
- **USB 列印伺服器**：區域網路共享 USB 印表機
- **Cloudflare Tunnel**：無需直接開放公網連接埠即可存取內部服務

外掛及軟體來源設定請參考 `scripts/ext_packages.sh` 和 `feeds.conf.default`。

---

### 使用方法

瀏覽器開啟：`http://192.168.50.1`  
預設使用者名稱：`root`，首次登入後請設定密碼。  
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

### 免責聲明

本專案僅供 OpenWrt 學習、研究及個人設備使用。韌體基於 OpenWrt 官方原始碼及第三方開源外掛建置，不保證第三方外掛的安全性、穩定性或相容性。刷寫前請先備份重要資料並確認設備相容性。

---

### 首頁預覽

<img width="1920" height="1031" alt="image" src="https://github.com/user-attachments/assets/535a58fc-8838-4473-b146-71cb28f683a0" />


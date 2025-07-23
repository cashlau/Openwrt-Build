# OpenWrt x86_64 自动构建固件

基于官方 OpenWrt 源码，自动编译集成常用插件的 x86_64 固件，发布至 GitHub Releases。

---

### 主要功能

- 自动拉取最新稳定版源码  
- 集成自定义插件（见 `scripts/ext_packages.sh`）  
- 默认后台地址：`192.168.50.2`  
- 自动发布到 Releases  

---

### 使用方法

- 浏览器访问后台：http://192.168.50.2  
- 默认用户名：`root`，首次登录请设置密码  
- 下载固件：[Releases](https://github.com/cashlau/Openwrt-Build/releases)  

---

### 项目结构


---

### 注意事项

- 插件可能增大固件体积，编译时间较长  
- 推荐有线连接访问后台，保证稳定  
- 请保持固件和配置同步更新  

---

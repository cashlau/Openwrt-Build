#!/bin/bash
set -euo pipefail

# Run from the OpenWrt source root, after feeds installation.
test -f include/toplevel.mk
test -d feeds/packages/lang/golang

clone_package() {
    local destination="$1" repository="$2" branch="${3:-}"
    if [ -e "$destination" ]; then
        echo "Existing package directory: $destination; refusing to overwrite"
        exit 1
    fi
    if [ -n "$branch" ]; then
        git clone --depth=1 --branch "$branch" "$repository" "$destination"
    else
        git clone --depth=1 "$repository" "$destination"
    fi
}

clone_package package/luci-app-usb-printer https://github.com/cashlau/luci-app-usb_printer.git
clone_package package/luci-app-argon-config https://github.com/jerrykuku/luci-app-argon-config
clone_package package/luci-theme-argon https://github.com/jerrykuku/luci-theme-argon
clone_package package/luci-app-pushbot https://github.com/zzsj0928/luci-app-pushbot
clone_package package/mosdns https://github.com/sbwml/luci-app-mosdns v5
clone_package package/luci-app-netspeedtest https://github.com/muink/luci-app-netspeedtest.git master
# 蓝牙管理及配套依赖
clone_package package/luci-app-bluetooth https://github.com/sbwml/luci-app-bluetooth.git main
clone_package package/expect https://github.com/sbwml/package_new_expect.git
clone_package package/bluez-alsa https://github.com/sbwml/package_new_bluez-alsa.git main

# Reuse geodata supplied by an installed feed to avoid duplicate packages.
GEODATA_FOUND=0
for candidate in package/v2ray-geodata package/feeds/*/v2ray-geodata; do
    if [ -f "$candidate/Makefile" ]; then GEODATA_FOUND=1; break; fi
done
if [ "$GEODATA_FOUND" -eq 0 ]; then
    clone_package package/v2ray-geodata https://github.com/sbwml/v2ray-geodata
fi

# Update the OpenWrt host Go toolchain, not Ubuntu's system Go.
# Download and inspect the replacement before moving the existing directory.
GO_STAGE=$(mktemp -d "$PWD/.golang-update.XXXXXX")
git clone --depth=1 --branch 27.x \
    https://github.com/sbwml/packages_lang_golang.git "$GO_STAGE/new"
echo 'Downloaded Go version declarations:'
grep -E '^[[:space:]]*(GO_VERSION_MAJOR_MINOR|GO_VERSION_PATCH|PKG_VERSION)[[:space:]]*[:?+]?=' \
    "$GO_STAGE/new/golang/Makefile" || true
if ! grep -Eq '^[[:space:]]*(GO_VERSION_MAJOR_MINOR|PKG_VERSION)[[:space:]]*[:?]?=[[:space:]]*1\.27([.[:space:]]|$)' \
    "$GO_STAGE/new/golang/Makefile"; then
    echo "Go 1.27 version check failed; original toolchain retained."
    exit 1
fi
test -s "$GO_STAGE/new/golang-package.mk"
mv feeds/packages/lang/golang "$GO_STAGE/original"
mv "$GO_STAGE/new" feeds/packages/lang/golang
echo "Go build files updated; original saved at $GO_STAGE/original"
grep -E '^[[:space:]]*(GO_VERSION_MAJOR_MINOR|GO_VERSION_PATCH|PKG_VERSION)[[:space:]]*[:?+]?=' \
    feeds/packages/lang/golang/golang/Makefile

# The workflow copies config/.config AFTER this script. Apply these options
# at make defconfig time, so that copy cannot erase them.
mkdir -p files/etc/uci-defaults
cat > .external-package-options <<'EOF'
luci-app-usb-printer
luci-app-argon-config
luci-theme-argon
luci-app-pushbot
mosdns
luci-app-mosdns
luci-app-netspeedtest
luci-app-bluetooth
expect
bluez-alsa
EOF

echo 'External packages and Go toolchain prepared.'
echo 'Apply .external-package-options after copying config/.config.'

#!/bin/bash
set -e
source scripts/ext_packages.sh

mkdir -p openwrt/package/custom

for index in $(seq 1 4); do
    name="${EXT_PACKAGES_NAME[$index]}"
    path="${EXT_PACKAGES_PATH[$index]}"
    repo="${EXT_PACKAGES_REPOSITORIE[$index]}"
    branch="${EXT_PACKAGES_BRANCH[$index]}"

    echo "Cloning $name from $repo"
    mkdir -p "openwrt/package/custom/$(dirname $path)"
    if [ -n "$branch" ]; then
        git clone --depth 1 -b "$branch" "$repo" "openwrt/package/custom/tmp-$name"
    else
        git clone --depth 1 "$repo" "openwrt/package/custom/tmp-$name"
    fi
    mv "openwrt/package/custom/tmp-$name/$path" "openwrt/package/custom/$path"
    rm -rf "openwrt/package/custom/tmp-$name"
done

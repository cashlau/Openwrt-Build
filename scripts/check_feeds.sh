#!/bin/bash
set -e

cd openwrt

echo "Updating feeds..."
if ! ./scripts/feeds update -a 2>&1 | tee update.log | grep -E "fatal|error|failed|cannot"; then
  echo "Feeds update completed without fatal errors."
else
  echo "ERROR: Feeds update encountered fatal errors!"
  exit 1
fi

echo "Installing feeds..."
./scripts/feeds install -a

missing_pkgs=()
required_pkgs=("libmesa" "libwayland" "libgraphene" "python3-netifaces")

for pkg in "${required_pkgs[@]}"; do
  if [ ! -d "package/feeds/packages/$pkg" ] && [ ! -d "package/$pkg" ]; then
    missing_pkgs+=("$pkg")
  fi
done

if [ ${#missing_pkgs[@]} -ne 0 ]; then
  echo "Missing these critical packages in feeds:"
  for mpkg in "${missing_pkgs[@]}"; do
    echo " - $mpkg"
  done
  exit 2
else
  echo "All critical packages exist."
fi

echo "Feeds check passed!"

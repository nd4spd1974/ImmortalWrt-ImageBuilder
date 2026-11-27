#!/bin/bash
# ============================================================
# 为 ImmortalWrt 25.12.2 x86-64 镜像准备用户指定的 6 个插件
#
# 产物：
#   extra-packages/custom/*.apk  -> build25.sh 会把它们整理进 packages/，
#                                   ImageBuilder 自动生成 packages.adb 索引
#   files/                       -> 通过 FILES 参数直接写入 rootfs
#   custom/                      -> 挂载为 files/etc/config
#
# 插件对应关系：
#   1. anothaDev/luci-theme-vantage     -> apk (Release v1.2.1, 25.12 apk 版)
#   2. gaobin89/luci-app-timecontrol    -> apk (Release 2026-09-28)
#   3. mufeng05/turboacc                -> LuCI 源文件直接写入 files/
#   4. gdy666/lucky                     -> apk (wukongdaily/apk, build25.sh 自动同步)
#   5. tohojo/sqm-scripts               -> 官方源 sqm-scripts + luci-app-sqm
#   6. sirpdboy/luci-app-poweroffdevice -> apk (Release v2.7 SNAPSHOT-x86_64)
# ============================================================
set -euo pipefail

ROOT="$(pwd)"
WORK="$ROOT/.plugin-work"
mkdir -p "$ROOT/extra-packages/custom" "$ROOT/files" "$ROOT/custom" "$WORK"

echo "===== 1/4 下载 Vantage 主题与仪表盘 apk ====="
VANTAGE_BASE="https://github.com/anothaDev/luci-theme-vantage/releases/download/v1.2.1"
for apk in \
  luci-theme-vantage-1.2.1-r1.apk \
  luci-app-vantage-1.2.1-r1.apk \
  luci-i18n-vantage-theme-zh-cn-1.2.1-r1.apk \
  luci-i18n-vantage-zh-cn-1.2.1-r1.apk ; do
  echo "  -> $apk"
  curl -fL --retry 3 --retry-delay 2 -o "$ROOT/extra-packages/custom/$apk" "$VANTAGE_BASE/$apk"
done

echo "===== 2/4 下载 TimeControl apk ====="
curl -fL --retry 3 --retry-delay 2 \
  -o "$ROOT/extra-packages/custom/luci-app-timecontrol-2.4.10-r20260928.apk" \
  "https://github.com/gaobin89/luci-app-timecontrol/releases/download/2026-09-28/luci-app-timecontrol-2.4.10-r20260928.apk"

echo "===== 3/4 下载 PowerOffDevice apk ====="
curl -fL --retry 3 --retry-delay 2 -o "$WORK/poweroffdevice.tar.gz" \
  "https://github.com/sirpdboy/luci-app-poweroffdevice/releases/download/v2.7/SNAPSHOT-x86_64.tar.gz"
mkdir -p "$WORK/poweroffdevice"
tar xzf "$WORK/poweroffdevice.tar.gz" -C "$WORK/poweroffdevice"
find "$WORK/poweroffdevice" -type f -name '*.apk' -exec cp -f {} "$ROOT/extra-packages/custom/" \;

echo "===== 4/4 准备 TurboACC (mufeng05) 的 LuCI 文件 ====="
git clone --depth=1 https://github.com/mufeng05/turboacc.git "$WORK/turboacc"
mkdir -p "$WORK/turboacc-app"
cp -a "$WORK/turboacc/lede/luci-app-turboacc/." "$WORK/turboacc-app/"
# custom/ 下的文件覆盖 lede/ 下的同名文件
cp -a "$WORK/turboacc/custom/luci-app-turboacc/." "$WORK/turboacc-app/"
for d in root htdocs; do
  if [ -d "$WORK/turboacc-app/$d" ]; then
    cp -a "$WORK/turboacc-app/$d/." "$ROOT/files/"
  fi
done
# custom/ 目录会被挂载为 files/etc/config，单独把 turboacc 配置文件放进去
if [ -f "$ROOT/files/etc/config/turboacc" ]; then
  cp -f "$ROOT/files/etc/config/turboacc" "$ROOT/custom/turboacc"
fi

echo "===== 准备完成，本次加入的 apk：====="
ls -lh "$ROOT/extra-packages/custom/"*.apk
echo "===== TurboACC 写入的文件：====="
find "$ROOT/files" -path '*turboacc*' -type f | head -30

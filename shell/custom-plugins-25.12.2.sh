# 25.12.2 x86-64 用户指定插件包列表
# 由 .github/workflows/build-x86-64-25.12.x.yml 在构建时追加到 apk-custom-packages.sh
# 注意：luci-app-turboacc 不作为 apk 安装，其 LuCI 文件由 fetch-25.12.2-plugins.sh
#       写入 files/ 并随 FILES 参数固化进 rootfs。

# 1. anothaDev/luci-theme-vantage (主题 + 仪表盘 + 中文语言包)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-vantage luci-app-vantage luci-i18n-vantage-theme-zh-cn luci-i18n-vantage-zh-cn"

# 2. gaobin89/luci-app-timecontrol
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-timecontrol"

# 4. gdy666/lucky (apk 来自 wukongdaily/apk，build25.sh 自动同步)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-lucky lucky luci-i18n-lucky-zh-cn"

# 5. tohojo/sqm-scripts (官方源)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES sqm-scripts luci-app-sqm luci-i18n-sqm-zh-cn"

# 6. sirpdboy/luci-app-poweroffdevice
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-poweroffdevice"

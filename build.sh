#!/bin/bash

# This script is modified from https://github.com/ivan-hc/Chrome-appimage/raw/fe079615eb4a4960af6440fc5961a66c953b0e2d/chrome-builder.sh
set -euo pipefail
shopt -s inherit_errexit

APP=WeChat
URL="${DOWNLOAD_URL:-https://github.com/zydou/WeChat-AppImage/releases/download/backup/com.tencent.wechat_1.0.0.236_amd64.deb}"

mkdir ./tmp
cd ./tmp
wget -q -O appimagetool "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage"
chmod a+x ./appimagetool
wget -q -O wechat.deb "$URL"
ar x ./wechat.deb
tar -xvf ./data.tar.*
mkdir $APP.AppDir
cp -v -r ./opt/apps/com.tencent.wechat/files/* ./$APP.AppDir/
cp -v ./opt/apps/com.tencent.wechat/entries/applications/*.desktop ./$APP.AppDir/
sed -i 's#/usr/bin/wechat#wechat#g' ./$APP.AppDir/*.desktop
cp -v ./opt/apps/com.tencent.wechat/entries/icons/hicolor/256x256/apps/com.tencent.wechat.png ./$APP.AppDir/com.tencent.wechat.png

tar -xvf ./control.tar.*
VERSION=$(grep Version control | cut -c 10-)
echo "$VERSION" | tee ../version.txt  # log version

echo "Create a tarball"
cd ./$APP.AppDir
tar -cJvf ../"$APP-$VERSION-x86_64.tar.xz" .
cd ..
mv -v ./"$APP-$VERSION-x86_64.tar.xz" ..

cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
APP=wechat
HERE="$(dirname "$(readlink -f "${0}")")"
exec "${HERE}"/$APP "$@"
EOF
chmod a+x ./$APP.AppDir/AppRun

echo "Create an AppImage"
ARCH=x86_64 ./appimagetool -n --verbose ./$APP.AppDir ../"$APP-$VERSION-x86_64.AppImage"
cd ..
rm -rf ./tmp

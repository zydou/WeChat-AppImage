#!/bin/bash

# This script is modified from https://github.com/ivan-hc/Chrome-appimage/raw/fe079615eb4a4960af6440fc5961a66c953b0e2d/chrome-builder.sh
set -euo pipefail
shopt -s inherit_errexit

APP=WeChat

# extract deb
mkdir ./tmp
cd ./tmp
wget -q -O appimagetool "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$(uname -m).AppImage"
chmod a+x ./appimagetool
wget -q -O wechat.deb "$URL"
ar x ./wechat.deb
tar -xvf ./data.tar.*
mkdir $APP.AppDir
cp -v -r ./opt/apps/com.tencent.wechat/files/* ./$APP.AppDir/
cp -v ./opt/apps/com.tencent.wechat/entries/applications/*.desktop ./$APP.AppDir/
sed -i 's#/usr/bin/wechat#wechat#g' ./$APP.AppDir/*.desktop
cp -v ./opt/apps/com.tencent.wechat/entries/icons/hicolor/256x256/apps/com.tencent.wechat.png ./$APP.AppDir/com.tencent.wechat.png

# log version
tar -xvf ./control.tar.*
VERSION=$(grep Version control | cut -c 10-)
echo "$VERSION" | tee ../version.txt  # log version

# install proot
wget -q -O proot "https://github.com/zydou/WeChat-AppImage/releases/download/backup/proot-$ARCH"
chmod a+x proot
mv proot $APP.AppDir/

# install license
wget -q -O license.tar.gz "https://github.com/zydou/WeChat-AppImage/releases/download/backup/license.tar.gz"
tar -xvf ./license.tar.gz
mv license $APP.AppDir/

# create tarball
echo "Create a tarball"
cd ./$APP.AppDir
tar -cJvf ../"$APP-$VERSION-$ARCH.tar.xz" .
cd ..
mv -v ./"$APP-$VERSION-$ARCH.tar.xz" ..

# create appimage
cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
APP=wechat
HERE="$(dirname "$(readlink -f "${0}")")"
exec $HERE/proot -b $HERE/libuosdevicea.so:/usr/lib/license/libuosdevicea.so \
  -b $HERE/license/etc/os-release:/etc/os-release \
  -b $HERE/license/etc/lsb-release:/etc/lsb-release \
  -b $HERE/license/var/lib/uos-license/.license.json:/var/lib/uos-license/.license.json \
  -b $HERE/license/var/uos/.license.key:/var/uos/.license.key \
  $HERE/wechat "$@"
EOF
chmod a+x ./$APP.AppDir/AppRun

echo "Create an AppImage"
./appimagetool -n --verbose ./$APP.AppDir ../"$APP-$VERSION-$ARCH.AppImage"
cd ..
rm -rf ./tmp

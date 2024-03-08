#!/bin/bash

# This script is modified from https://github.com/ivan-hc/Chrome-appimage/raw/fe079615eb4a4960af6440fc5961a66c953b0e2d/chrome-builder.sh

APP=WeChat
URL="${DOWNLOAD_URL:-https://cdn4.cnxclm.com/uploads/2024/03/05/3VDyAc0x_wechat-beta_1.0.0.145_amd64.deb}"
mkdir ./tmp
cd ./tmp
wget -O appimagetool "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage"
chmod a+x ./appimagetool
wget -O wechat.dev "$URL"
ar x ./*.deb
tar -xJf ./data.tar.xz
mkdir $APP.AppDir
mv ./opt/wechat-beta/* ./$APP.AppDir/
mv ./usr/share/applications/*.desktop ./$APP.AppDir/
sed -i 's#/usr/bin/wechat#wechat#g' ./$APP.AppDir/*.desktop
sed -i 's#/opt/wechat-beta/icons/wechat.png#wechat#g' ./$APP.AppDir/*.desktop
cp ./$APP.AppDir/icons/wechat.png ./$APP.AppDir/wechat.png

tar -xJf ./control.tar.xz
VERSION=$(cat control | grep Version | cut -c 10-)
echo "$VERSION" > ../version  # log version

echo "Create a tarball"
cd ./$APP.AppDir
tar -cJvf ../$APP-$VERSION-x86_64.tar.xz .
cd ..
mv ./$APP-$VERSION-x86_64.tar.xz ..

cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
APP=wechat
HERE="$(dirname "$(readlink -f "${0}")")"
exec "${HERE}"/$APP "$@"
EOF
chmod a+x ./$APP.AppDir/AppRun

echo "Create an AppImage"
ARCH=x86_64 ./appimagetool -n --verbose ./$APP.AppDir ../$APP-$VERSION-x86_64.AppImage
cd ..
rm -rf ./tmp

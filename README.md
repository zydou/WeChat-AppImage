# WeChat AppImage

AppImage version of WeChat client for linux desktop.

微信客户端AppImage版。

## Bypass Login Detection

Currently, WeChat is only allowed to be used on specific Linux distributions (Kyrin or UOS). You will be prompted with a message "Login Failed" if you are using other distributions.

To bypass this limitation, you should use the files in [login-detection](./login-detection) folder to fake your system information.

```sh
sudo cp -r ./login-detection/etc/.kyact /etc/.kyact
sudo cp -r ./login-detection/etc/LICENSE /etc/LICENSE
sudo cp -r ./login-detection/usr/lib/libactivation.so /usr/lib/libactivation.so

# backup lsb-release
sudo cp /etc/lsb-release /etc/lsb-release.bak
sudo cp ./login-detection/etc/lsb-release-ukui /etc/lsb-release
```

# raspberry-pi-setup
Handy guided setup for headless rpi

## If you have a clean raspian install
1. You can add an empty ssh file to `/boot` if you want to activate ssh (in Win make sure you remove the extension)
2. If you are not connected by lan you can activate also the [wifi by default](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)

Now run to start
```sh
wget https://raw.githubusercontent.com/GonzaloTorreras/raspberry-pi-setup/master/src/installer.sh && chmod +x installer.sh && ./installer.sh

```

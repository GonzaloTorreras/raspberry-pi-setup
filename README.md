# Raspberry pi guided setup
Handy setup to speed up your initial setup of the pi.

## If you want a headless raspian 
- Add an empty ssh file to `/boot` if you want to activate ssh (in Win make sure you remove the extension).
- If you are not connected by lan you can activate also the [wifi](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)

Now login to your default pi user:
pi:raspberry
and answer the questions as you like!
```sh
wget https://raw.githubusercontent.com/GonzaloTorreras/raspberry-pi-setup/master/src/installer.sh && chmod +x installer.sh && ./installer.sh

```
##### Note:
You can run it at any point of your setup, or with any user.
Recomended to do it with pi user, or a passwordless sudo acces user.

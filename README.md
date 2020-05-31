# Raspberry pi guided setup
Handy setup to speed up your initial setup of the pi.

## If you want a headless raspbian 
- Add an empty ssh file to `/boot` if you want to activate ssh (in Win make sure you remove the extension).
- If you are not connected by lan you can activate also the [wifi](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)

Now login to your default pi user:
pi:raspberry
and answer the questions as you like!
```sh
wget https://raw.githubusercontent.com/GonzaloTorreras/raspberry-pi-setup/master/src/installer.sh && chmod +x installer.sh && ./installer.sh

```
## It helps you to:
- [x] Update the system: `apt update && upgrade -y`
- [x] User related
  - [X] Add a new user
  - [x] Add new user to sudo group
  - [x] Add new user to sudoers to avoid passwd promp
  - [x] Handful aliases
    - [x] To the current user
    - [x] To the $newUser
  - [x] Change default pi password
  - [x] Lock pi user
  - [x] Lock root user
  - [x] Add new user as alias for root `root: $newUser, root \n $newUser: your@email.com >> /etc/aliases`
  - [ ] Delete pi (not yet, having issues if running through pi user)
- [x] Install **UFW**
  - [x] Block any incoming
  - [x] Allow any outgoing
  - [x] Allow any from local (192.168.1.0/24)
  - [x] Activate UFW
- [x] Install **docker** (latest)
 - [x] Add current user ($USER) to docker group
 - [x] Add NEW user ($newUser) to docker group
 - [x] Install **docker-compose** (latest)
- [x] Install a ***speed fan** controller (PWM)

 
### *ALL the above tasks* will be asked one by one BEFORE doing any change [y/n]

##### Note:
You can run it at any point of your setup, or with any user.
Recomended to do it with pi user, or a passwordless sudo acces user.

### To do
- [ ] Improve/expand aliases (maybe split by categories to decide what install such docker related)

**Docker image installers**
- [x] Nginx (with certbot for LetsEncript).
- [X] Node-RED
- [X] Pi Hole
- [ ] MySQL (MariaDB)
- [ ] Traefik
- [ ] NextCloud
- [X] Pi Hole
- [ ] OpenVPN || piVPN
- [ ] RaspberryCast

### Possible ideas:
- [ ] [Localice](https://unix.stackexchange.com/a/318661) the installer for translations
- [ ] Maybe provide common services such MySQL (mariaDB), nginx, nodeRED etc as standalone installations instead all docker based? (at least the posibility to)

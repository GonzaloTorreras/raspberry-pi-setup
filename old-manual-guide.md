
# rpi init:

## configuración básica (teclado locale etc.)
```sh
raspi-config
```

## nuevo user gon
```sh
sudo /usr/sbin/useradd --groups sudo -m gon
```

### contraseña gon
```.sh
sudo passwd gon
```

### No ask for passwd when using sudo command
```sh
echo 'gon ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/010_gon-nopasswd
```

### bloquear login root
```sh
sudo passwd --lock root
```

### bloquear login the user pi
```sh
sudo passwd --lock pi
```

## o eliminar la cuenta pi directamente (incluido su home)
```sh
sudo deluser -remove-home pi
```
## Actualizar rPi
```sh
sudo apt update && sudo apt upgrade -y
```
## how to enable VNC on a pi
```sh
raspi-config
```
1. Go to **boot option** -> **boot into the CLI**.
2. Go to **Interfacing Options** -> **VNC** -> **YES**
3. Go to **advanced Options** -> **Resolution** -> ** force a resolution** (instead default monitor)
4. Exit raspi-config.

### headless CLI (not GUI) bootup system

Modify the `sudo nano /etc/rc.local` file by adding this at the end before exit:
```sh
#Start RealVNC in virtual mode with resolution 1400x900px 
vncserver -randr=1400x900
```

Connect to the virtual with your ip:1 my case `192.168.1.2:1`

### GUI (not CLI) bootup system
Connect to the virtual with your ip:1 my case `192.168.1.2`

If you are going to use VNC **JUST IN YOUR LOCAL NETWORK** you may disable the the cifrado to improve performance.


## RAID 1
his answer assumes that you are creating a new RAID 1 array using two identical new drives. The file system will be ext4 on a single partition taking up the whole drive, not using LVM.

Firstly, identify the device names for your new hard drives by running `sudo fdisk -l`. In my case, the new drives were `/dev/sda` and `/dev/sdb`.

Then create the partition on each drive. The partition table needs to be GPT to allow more than 2TB to be used, so you cannot use `fdisk`.

1. Run `sudo parted /dev/sda.`

2. At the `(parted)` prompt, create the partition table by typing `mklabel gpt`.

3. Check the free space on the drive by typing `print free`. In my case, this shows 6001GB.

4. Create the partition by typing `mkpart primary 1M 6001GB`. This starts the partition a 1M offset giving a 4096 byte alignment. This may or may not be necessary, but won't hurt if its not.

5. Check your partition is set up by typing `p`. Then type `q` to quit.

Repeat steps 1 to 5 for `/dev/sdb`.

Install `mdadm` with `sudo apt install mdadm`
Now create the array using the `mdadm` command:
```sh
sudo mdadm --verbose --create /dev/md0 --level=raid1 --raid-devices=2 /dev/sd[ab]1
```
Create the file system:
```sh
sudo mkfs.ext4 /dev/md0
```
Finally, mount your array somewhere and add it to `/etc/fstab` if you want it to be mounted permanently. I did this:

Create a location to mount the array at by running `sudo mkdir /mnt/md0`.

Edit `sudo nano /etc/fstab` and add the following line:
```sh
/dev/md0	/mnt/md0	auto	defaults,nofail,noatime	0	0
```
###### after pasting the line ideally be sure that after each attr you remove the space and add a tabSpace instead. (we added temporary ```,nofail```to avoid the raspberry pi to prevent the Pi hanging if its booted without the drive attached or any other fail related).

Mount by running sudo `sudo mount /mnt/md0`.

Now you can start using your array. Bear in mind, however, that before it is fully operation it will need to complete its initial sync. You can track its progress by running `sudo mdadm --detail /dev/md0` or `watch -n 1 cat /proc/mdstat`.

Reboot your pi to test the config and automount with `sudo shutdown -h now`

###### for normal USB devices, ideally you want to use the UUID instead, you can get it easily with ```blkid -s UUID -o value /dev/md0```

### For the raspberry Pi 4
USB won't auto mount on start if you don't have HDMI conected or GUI autologin. So to avoid issues specially on headless:
We need to force a resolution on ```raspi-config``` otherwise GUI won't be initiated and the USB won't auto mount.
###### [Extra info](https://www.raspberrypi.org/forums/viewtopic.php?p=1548152&sid=03d0a747573755c43263c032b44ae688#p1548152)



###### Extracted and compiled from [askubuntu.com](https://askubuntu.com/a/463813/971704) and [rpi forums](https://www.raspberrypi.org/forums/viewtopic.php?t=205016)


## MySQL (MariaDB FTW!)
Install mariaDB and run configurator
```sh
sudo apt install mariadb-server
sudo mysql_secure_installation
 ```

### Change default folder for MySQL
I read some issues about changing it, and that you had to deal with different scripts to be sure it works (because apparently while initiating config settings are overwritten while loading more than one config and so on so I decided to just move it and link it).

```sh
sudo mv  /var/lib/mysql /mnt/md0/mysql
sudo ln -s /mnt/md0/mysql/ /var/lib/mysql
sudo chown mysql:mysql /var/lib/mysql
```

### New DB & user
```sh
sudo mysql -u root
```

```sql
CREATE DATABASE myDB;
GRANT ALL ON myDB.* TO testUser@localhost IDENTIFIED BY 't3stP4sW0rd';
FLUSH privileges;
```

#### Change forgotten root password:
1. Shut down the mysql service `sudo systemctl stop mysql`
2. Start MySQL without grant tables `sudo mysqld_safe --skip-grant-tables &`
3. Set the new root password 
```sql
UPDATE mysql.user SET authentication_string = PASSWORD('NEW_PASSWORD')
WHERE User = 'root' AND Host = 'localhost';
FLUSH PRIVILEGES;
```



## Instalar Docker
```sh
curl -sSL https://get.docker.com | sh
```
### Add our user to docker group
```sh
sudo usermod -aG docker $USER
```

### Logout the session
```sh
exit
```

and SSH back to your pi.

### Test the Docker installation
```sh
docker run hello-world
```

### Add Dependencies
```sh
sudo apt install -y libffi-dev libssl-dev
sudo apt install -y python3 python3-pip
sudo apt remove python-configparser
```
#### Install Docker Compose
```sh
sudo pip3 install docker-compose
```
### Traefik to handle all of them!

## instalar ufw
```sh
sudo apt install ufw
```
### bloquear cualquier conexión entrante (salvo las reglas que se añadan)
```sh
sudo ufw default deny incoming
```

### permitir cualquier conexión saliente
```sh
sudo ufw default allow outgoing
```

### permitir cualquier acceso si es local
```sh
sudo ufw allow from 192.168.1.0/24
```


### permitir acceso externo a node red y Nginx (or docker?)
```sh
sudo ufw allow 1880
sudo ufw allow 'Nginx Full'
```
### activate ufw
```sh
sudo ufw enable
```

## instalar logwatch para que te mande resumen diario de lo que ocurre en la rpi
```sh
sudo apt install logwatch
```

### configurar logwatch como quieras
```sh
sudo nano /usr/share/logwatch/default.conf/logwatch.conf
```

### añadir alias para que el correo de logwatch se mande a $user y no a root
```sh
sudo nano /etc/aliases
```
### añadir estas lineas:
```sh
root: **tuUser**,root
**tuUser**: **email@domain.com**
```

### recargar aliases
```sh
sudo /usr/bin/newaliases
```





## install nodered
```sh
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
```
## install php
```sh
sudo apt install php
```
## install nginx
```sh
sudo apt install nginx
```
### configure nginx to use PHP
```sh
sudo nano /etc/nginx/sites-available/default
```
### modify the index line:
index index.php index.html index.html index.nginx-debian.html
### uncomment the location + php:
```nginx
location ~ \.php$ {
	include snippets/fastcgi-php.conf;
	fastcgi_pass unix:/var/run/php7.3-fpm.sock; #this line will change the version over time
}
```
### open 433 for TSL/SSL

### test the config:
```sh
sudo nginx -t
```
### reload nginx
```sh
sudo systemctl reload nginx
```
### install a bot for lets encript certificates
```sh
sudo apt install certbot
```

### exec 
```sh
sudo certbot certonly --webroot -w /var/www/domain.com -d dmain.com -d www.domain.com
```
### Certs
Priv key and chain are saved in /etc/letsencript/live/domain.com/

### edit nginx config for SSL
```sh
sudo nano /etc/nginx/sites-available/domain.com
```
### add lines:
```sh
listen 443 ssl;
ssl_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/domain.com/privkey.pem;
```
### Add protection for DDOS
```sh
sudo nano /etc/nginx/nginx.conf 
```
### add inside http{}


### DDOS Protection
 The code above will prevent bursts of traffic from IP’s that seem suspicous (like one of a DDoS attack). 
 It will also limit the amount of connections a single IP can have to the web server.
```nginx
http{
	limit_req_zone $binary_remote_addr zone=global:10m rate=1r/m;
	limit_conn_zone $binary_remote_addr zone=addr:10m;
	server {
		location / {
			limit_req zone=global burst=10 nodelay;
			limit_conn addr 1;
			limit_rate 100k;
		}
	}
}
```


### install postfix:
[Follow this complete tutorial](https://samhobbs.co.uk/2013/12/raspberry-pi-email-server-part-1-postfix)
```sh
sudo apt install postfix
```

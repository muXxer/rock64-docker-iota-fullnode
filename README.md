# rock64-docker-iota-fullnode

This repository contains the `docker-compose.yml` for IOTA IRI on ROCK64 including Nelson.cli, Nelson.gui and Field.cli.<br>

## Table of contents
- [rock64-docker-iota-fullnode](#rock64-docker-iota-fullnode)
  * [Table of contents](#table-of-contents)
  * [1. WARNING](#1-warning)
  * [2. Install guide](#2-install-guide)
    + [2.1 My hardware part list](#21-my-hardware-part-list)
    + [2.2 Downloading the linux image to the SD card](#22-downloading-the-linux-image-to-the-sd-card)
    + [2.3 Move the root file system to an external hard drive (optional)](#23-move-the-root-file-system-to-an-external-hard-drive--optional-)
    + [2.4 First steps on the ROCK64](#24-first-steps-on-the-rock64)
    + [2.5 Mount an external hard drive and redirect the docker directory](#25-mount-an-external-hard-drive-and-redirect-the-docker-directory)
    + [2.6 Create a swap file](#26-create-a-swap-file)
    + [2.7 Download this repository](#27-download-this-repository)
    + [2.8 Install latest linux kernel image from ayufan](#28-install-latest-linux-kernel-image-from-ayufan)
    + [2.9 Change the IOTA configuration files to fit your needs](#29-change-the-iota-configuration-files-to-fit-your-needs)
        + [2.9.1 Change the Nelson config.ini](#291-change-the-nelson-configini)
        + [2.9.2 Change the Field config.ini](#292-change-the-field-configini)
    + [2.10 Download the IOTA mainnet database](#210-download-the-iota-mainnet-database)
    + [2.11 Open the following ports in your firewall for the ROCK64 ip address](#211-open-the-following-ports-in-your-firewall-for-the-rock64-ip-address)
    + [2.12 Build the docker containers on your own](#212-build-the-docker-containers-on-your-own)
  * [3. Usage](#3-usage)
    + [3.1 Start the node](#31-start-the-node)
    + [3.2 Container Status](#32-container-status)
    + [3.3 Check the logs](#33-check-the-logs)
    + [3.4 Open Nelson GUI](#34-open-nelson-gui)
    + [3.5 Update when a new release of any container is published](#35-update-when-a-new-release-of-any-container-is-published)
  * [4. Warnings](#4-warnings)
    + [4.1 Ports](#41-ports)
    + [4.2 IRI Remote API limits](#42-iri-remote-api-limits)
  * [5. More information](#5-more-information)
  * [6. Author](#6-author)
  * [7. Special thanks to](#7-special-thanks-to)
  * [8. License](#8-license)
  * [9. Donations](#9-donations)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## 1. WARNING

I take no responsibility about eventual damage! This project includes following alpha and beta software:
* IOTA IRI
* CarrIOTA Nelson.cli
* CarrIOTA Nelson.gui
* CarrIOTA Field.cli

## 2. Install guide

These instructions are just my personal step by step description.
You may also be successful with other linux images or hardware than I used. 

### 2.1 My hardware part list
- ROCK64 MEDIA BOARD COMPUTER - 4GB 
- 250GB Samsung 850 Evo 2.5" SATA
- Inter-Tech GD-25609 2.5" USB 3.1 Type C
- ICY BOX IB-RP102 Enclosure for Raspberry Pi
- 32 GB Samsung EVO Plus microSDXC Class 10 UHS
- AUKEY USB-C 3.0 Cable to USB-A
- Heatsinks (important)

### 2.2 Downloading the linux image to the SD card

- Download the latest version of the [PINE64 Installer](https://github.com/pine64dev/PINE64-Installer/releases/latest).
- Download the latest release/prerelease of [ayufans xenial-containers-rock64-XXXXX-arm64.img.xz](https://github.com/ayufan-rock64/linux-build/releases) or use the following command on your computer:
```sh
curl -L `curl -s https://api.github.com/repos/ayufan-rock64/linux-build/releases | grep browser_download_url | grep xenial-containers-rock64 | grep arm64.img.xz | head -n 1 | cut -d '"' -f 4` -O
```

- Insert the SD card into your computer
- Start the PINE64 Installer
 * Click `Choose an OS`
 * Click `Select your board` 
 * Choose `ROCK64 - Popcorn hour transformer`
 * Click `Browse image file from local drive`
 * Select your downloaded `ayufan xenial-container` image

### 2.3 Move the root file system to an external hard drive (optional)

This part is a bit tricky, but i think it is worth it. You will have less problems with dying SD cards or overall system speed. Please follow these steps closely!

- Mount the `linux-root` partition of the SD card (e.g. `/media/YOUR-USERNAME/linux-root/`) in your computer before plugging it in the Rock64 for the first time.
You can easily do this by clicking on the device in your file browser.

- Edit the file `/media/YOUR-USERNAME/linux-root/usr/local/sbin/rock64_first_boot.sh` and remove the following line.
Otherwise your root filesystem on the external hard drive will be destroyed on first system boot up.
```diff
#!/bin/sh

set -x

mkdir -p /var/lib/rock64

if [ ! -e /var/lib/rock64/resized ]; then
   touch /var/lib/rock64/resized
-  /usr/local/sbin/resize_rootfs.sh
fi
```

- Connect the external hard drive and create an ext4 file system (e.g. description `iota-rock64`) with your favorite tool (e.g. `gnome-disks`).
- Mount the new partition of the external hard drive (e.g. `/media/YOUR-USERNAME/iota-rock64/`)
- Copy the root file system from the SD card to the external hard drive with the following command:
```sh
sudo rsync -avPE /media/YOUR-USERNAME/linux-root/ /media/YOUR-USERNAME/iota-rock64/
```

- Mount the `boot` partition of the SD card (e.g. `/media/YOUR-USERNAME/boot/`)
- Get the UUID of the external hard drive (e.g. `3babfcac-8603-4ae8-a4cb-f5932f00640b`)
```sh
sudo blkid
```
- Edit the file ` /media/YOUR-USERNAME/boot/extlinux/extlinux.conf ` and change the following lines according to your UUID.
```diff
timeout 30
default kernel-latest
menu title select kernel

label kernel-latest
    kernel /Image
    initrd /initrd.img
    fdt /dtb
-   append rw root=LABEL=linux-root rootwait rootfstype=ext4 panic=10 init=/sbin/init coherent_pool=1M ethaddr=${ethaddr} eth1addr=${eth1addr} serial=${serial#} cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1
+   append rw root=UUID=YOUR-OWN-UUID rootwait rootfstype=ext4 panic=10 init=/sbin/init coherent_pool=1M ethaddr=${ethaddr} eth1addr=${eth1addr} serial=${serial#} cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1

label kernel-previous
    kernel /Image.bak
    initrd /initrd.img.bak
    fdt /dtb.bak
-   append rw root=LABEL=linux-root rootwait rootfstype=ext4 panic=10 init=/sbin/init coherent_pool=1M ethaddr=${ethaddr} eth1addr=${eth1addr} serial=${serial#} cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1
+   append rw root=UUID=YOUR-OWN-UUID rootwait rootfstype=ext4 panic=10 init=/sbin/init coherent_pool=1M ethaddr=${ethaddr} eth1addr=${eth1addr} serial=${serial#} cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1
```

### 2.4 First steps on the ROCK64

- Insert the SD card into your ROCK64
- Power on the ROCK64
- Get the IP address of the ROCK64 from your router or log in to the shell with an external screen and a usb keyboard (user: rock64, pw: rock64)
```sh
hostname -I
```

- Log in via ssh from your computer
```sh
ssh rock64@YOUR-ROCK64-IP
```

- Change the user password
```sh
passwd
```

- Update your system
```sh
sudo apt update && sudo apt dist-upgrade
```

- Change your timezone and locales
```sh
sudo dpkg-reconfigure tzdata
sudo dpkg-reconfigure locales
```

- Add yourself to the docker group
```sh
sudo adduser ${USER} docker
```

- Copy your ssh key from your computer to the ROCK64
```sh
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
ssh-copy-id rock64@YOUR-ROCK64-IP
```

- Configure `/etc/ssh/sshd_config` to secure your SSH access
```sh
sudo nano /etc/ssh/sshd_config
```
Change the following lines to disable SSH login with password.<br>
**CAUTION, you won't be able to log in via SSH if you didn't copy your SSH key before!**
```diff
PermitRootLogin no
-PasswordAuthentication yes
+PasswordAuthentication no
-X11Forwarding yes
+X11Forwarding no
-UsePAM yes
+UsePAM no
```

- Restart the SSH Server to apply changes
```sh
sudo systemctl restart sshd
```

### 2.5 Mount an external hard drive and redirect the docker directory

The following steps are **only necessary** if you didn't move the root file system to the external drive. See [Step 2.3](#23-move-the-root-file-system-to-an-external-hard-drive--optional-)

- Get the UUID of the external drive (should be something like `/dev/sda`)
```sh
sudo blkid
```

- Create a target directory for the external drive
```sh
sudo mkdir -p /mnt/my_ext_drive/
```

- Add the external drive to your `/etc/fstab`
```sh
sudo nano /etc/fstab
```

- Add the following line (depending on your UUID, target directory, file system)
```diff
+UUID=YOUR-OWN-UUID /mnt/my_ext_drive ext4 defaults,discard 0 2
```

- Mount the new device
```sh
sudo mount -a
```

- Redirect docker containers to your external drive with a symlink
```sh
sudo systemctl stop docker
sudo mv /var/lib/docker /mnt/my_ext_drive/docker
sudo ln -s /mnt/my_ext_drive/docker /var/lib/docker
sudo chown -R root:root /mnt/my_ext_drive/docker
sudo systemctl start docker
```

### 2.6 Create a swap file

By creating a swap file the OS is able to let programs exceed the size of available physical memory.

- Create a swap file by executing the following commands
```
sudo mkdir -p /var/cache/swap 
sudo fallocate -l 8G /var/cache/swap/swap0
sudo chmod 0600 /var/cache/swap/swap0 
sudo mkswap /var/cache/swap/swap0
sudo swapon /var/cache/swap/swap0
```

- Add the swap file to your `/etc/fstab`
```
sudo nano /etc/fstab
```

- Add the following line
```diff
+/var/cache/swap/swap0 none swap sw 0 0
```

- Change the swap settings in the system
```sh
sudo nano /etc/sysctl.conf
```

- Add the following lines at the end of the file
```diff
+vm.swappiness=10
+vm.vfs_cache_pressure=50
```

- Reload the system settings
```sh
sudo sysctl -p
```

### 2.7 Download this repository
Go to a directory mounted on the external drive and clone this repository (needs disk space because of IOTA mainnet database)
```sh
git clone https://github.com/muXxer/rock64-docker-iota-fullnode.git
cd rock64-docker-iota-fullnode/
```

### 2.8 Install latest linux kernel image from ayufan
The shipped kernel had some problems on my ROCK64 with the Ethernet PHY (error messages in dmesg) and the device got quite warm.
I had no problems at all with the latest kernel from ayufan (except HDMI output, but i only use SSH, so that's no problem).
Install it with the following commands:
```sh
chmod +x install_latest_linux_kernel.sh
./install_latest_linux_kernel.sh
```

### 2.9 Change the IOTA configuration files to fit your needs 
#### 2.9.1 Change the Nelson config.ini

Edit the `volumes/nelson.cli/config.ini` file to match your needs, for example the name

```diff
[nelson]
-name = CHANGE ME!
+name = My awesome nelson node
```

#### 2.9.2 Change the Field config.ini

Edit the `volumes/field.cli/config.ini` file to match your needs, for example the name

```diff
[field]
-name = CHANGE ME!
+name = My awesome field node 
```

**Be sure to change your address field to your IOTA address for donations, otherwise thank you for leaving mine or add a new seed to get dynamically unused addresses *DO NOT USE YOUR MAIN WALLET SEED* **

Check your CarrIOTA Field node and donate to IOTA nodes here: http://field.carriota.com

### 2.10 Download the IOTA mainnet database
To download the latest snapshot of the database (faster initial sync) use the following commands:
```sh
chmod +x download_mainnet_db.sh
./download_mainnet_db.sh
```

### 2.11 Open the following ports in your firewall for the ROCK64 ip address
- 14600 UDP - IOTA/IRI UDP connection port
- 15600 TCP - IOTA/IRI TCP connection port
- 16600 TCP - Nelson.cli TCP connection port
- 21310 TCP - Field.cli TCP connection port

### 2.12 Build the docker containers on your own
Use the `build` sections instead of `image` in the file `docker-compose.yml` if you want to build the docker containers on your own.

```diff
-    image: muxxer/rock64_iota_iri:latest
+    #image: muxxer/rock64_iota_iri:latest
-    #build:
-    #  context: ./dockerfiles
-    #  dockerfile: Dockerfile_iri
+    build:
+      context: ./dockerfiles
+      dockerfile: Dockerfile_iri
```

## 3. Usage
### 3.1 Start the node

Enter the main rock64-docker-iota-fullnode folder
```sh
cd rock64-docker-iota-fullnode
```

Run it with:
```sh
docker-compose up -d
```

### 3.2 Container Status

Check if the docker container are up and running
```sh
docker ps
```

### 3.3 Check the logs

Check the IRI logs with
```sh
docker logs iota_iri
```

Check the Nelson logs with
```sh
docker logs iota_nelson.cli
```

### 3.4 Open Nelson GUI

Open your browser to
```http
http://YOUR-ROCK64-IP:5000/
```

### 3.5 Update when a new release of any container is published

This update script will pull all containers if updated or not and stop/remove/start **all containers**

Make the update script executable
```sh
cd rock64-docker-iota-fullnode
chmod +x update_containers.sh
```

Run the update script
```sh
./update_containers.sh
```

## 4. Warnings

### 4.1 Ports

The ports setup in the docker-compose.yml file opens following container ports

Port/Type | Use 
--- | ---
14265 | IOTA/IRI API port
14600/udp | IOTA/IRI UDP connection port
15600/tcp | IOTA/IRI TCP connection port
16600 | Nelson connection port
18600 | Nelson API port
21310 | CarrIOTA Field connection port
5000 | Nelson GUI

Please assure yourself to set your firewall accordingly, the ports are opened on 0.0.0.0 (all IP adresses, internal and external)

### 4.2 IRI Remote API limits

**At this point NO API limits are now default!**

Following API limits are to be set as best practice (see iota.partners site or discussions on discord), but are not enabled as explained in the following table

parameter | explaination 
--- | ---
getNeighbors|No one can see the data of your neighbors
addNeighbors|No one can add neighbors to your node
removeNeighbors|No one can remove neighbors from your node
setApiRateLimit|This will prevent external connections from being able to use this command
interruptAttachingToTangle| To prevent users to do the PoW on your node
attachToTangle| To prevent users to do the PoW on your node

## 5. More information

For more information about the combined projects please refer to the following github repositories:

* [IOTA-IRI](https://github.com/iotaledger/iri)
* [CarrIOTA Nelson client](https://github.com/SemkoDev/nelson.cli)
* [CarrIOTA Nelson GUI](https://github.com/SemkoDev/nelson.gui)
* [CarrIOTA Field client](https://github.com/SemkoDev/field.cli)


## 6. Author
* **muXxer**

## 7. Special thanks to 

* **Antonio Nardella** - [Twitter](https://twitter.com/antonionardella) [GitHub](https://github.com/ioiobzit) - for his nice docker-compose file and detailed README.md (i took a lot from it)
* **Roman Semko** - [Twitter](https://twitter.com/romansemko) [GitHub](https://github.com/SemkoDev) - for beautiful software like Nelson.cli, Nelson.gui and Field.cli
* **Jim Huang** - [Twitter](https://twitter.com/jserv) [GitHub](https://github.com/jserv) - for porting ROCKSDB to ARM64v8
* **ayufan** - [Twitter](https://twitter.com/ayufanpl) [GitHub](https://github.com/ayufan-rock64/) - for great Linux images for ROCK64

## 8. License

This project is licensed under the ICS License - see the [LICENSE.md](LICENSE.md) file for details

## 9. Donations

**Buy us some beer**:

IOTA muXxer:
```raw
PHCIWQQIHQCAKPTJYXSRHIOSMZHHYVBBCALEBGXULYIAYJLBMFNAOHVJZUJZZZJXYUQSXHZZAKUBVLUDCE9AK9ZNVW
```

IOTA Antonio Nardella:
```raw
CHQAYWPQUGQ9GANEWISFH99XBMTZAMHFFMPHWCLUZPFKJTFDFIJXFWCBISUTVGSNW9JI9QCOAHUHFUQC9SYVFXDQ9D
```


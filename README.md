# rock64-docker-iota-fullnode

This repository contains the `docker-compose.yml` for IOTA IRI on ROCK64 including Nelson.cli, Nelson.gui and Field.cli.<br>
The Dockerfiles used to build the included containers can be found [here](https://github.com/muXxer/rock64-docker-iota-fullnode-dockerfiles).

## Table of contents
* [1. WARNING](#1-warning)
* [2. Install guide](#2-install-guide)
  + [2.1 My hardware part list](#21-my-hardware-part-list)
  + [2.2 Downloading the linux image to the SD card](#22-downloading-the-linux-image-to-the-sd-card)
  + [2.3 First steps on the ROCK64](#23-first-steps-on-the-rock64)
  + [2.4 Download this repository](#24-download-this-repository)
  + [2.5 Install latest linux kernel image from ayufan](#25-install-latest-linux-kernel-image-from-ayufan)
  + [2.6 Change the IOTA configuration files to fit your needs](#26-change-the-iota-configuration-files-to-fit-your-needs)
        + [2.6.1 Change the Nelson config.ini](#261-change-the-nelson-configini)
        + [2.6.2 Change the Field config.ini](#262-change-the-field-configini)
  + [2.7 Download the IOTA mainnet database](#27-download-the-iota-mainnet-database)
  + [2.8 Open the following ports in your firewall for the ROCK64 ip address](#28-open-the-following-ports-in-your-firewall-for-the-rock64-ip-address)
* [3. Usage](#3-usage)
  + [3.1 Start the node](#31-start-the-node)
  + [3.2 Check the logs](#32-check-the-logs)
  + [3.3 Open Nelson GUI](#33-open-nelson-gui)
  + [3.4 Update when a new release of any container is published](#34-update-when-a-new-release-of-any-container-is-published)
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
- Insert the SD card into your ROCK64
- Power on the ROCK64
- Get the IP address of the ROCK64 from your router or log in to the shell with an external screen and a usb keyboard (user: rock64, pw: rock64)
```sh
hostname -I
```

### 2.3 First steps on the ROCK64

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
Add the following line (depending on your UUID, target directory, file system)
```
UUID=YOUR-OWN-UUID /mnt/my_ext_drive ext4 defaults,discard 0 2
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

### 2.4 Download this repository
Go to a directory mounted on the external drive and clone this repository (needs disk space because of IOTA mainnet database)
```sh
git clone https://github.com/muXxer/rock64-docker-iota-fullnode.git
cd rock64-docker-iota-fullnode/
```

### 2.5 Install latest linux kernel image from ayufan
The shipped kernel had some problems on my ROCK64 with the Ethernet PHY (error messages in dmesg) and the device got quite warm.
I had no problems at all with the latest kernel from ayufan. Install it with the following commands:
```sh
chmod +x install_latest_linux_kernel.sh
./install_latest_linux_kernel.sh
```

### 2.6 Change the IOTA configuration files to fit your needs 
#### 2.6.1 Change the Nelson config.ini

Edit the `volumes/nelson.cli/config.ini` file to match your needs, for example the name

```diff
[nelson]
-name = CHANGE ME!
+name = My awesome nelson node
```

#### 2.6.2 Change the Field config.ini

Edit the `volumes/field.cli/config.ini` file to match your needs, for example the name

```diff
[field]
-name = CHANGE ME!
+name = My awesome field node 
```

**Be sure to change your address field to your IOTA address for donations, otherwise thank you for leaving mine or add a new seed to get dynamically unused addresses *DO NOT USE YOUR MAIN WALLET SEED* **

Check your CarrIOTA Field node and donate to IOTA nodes here: http://field.carriota.com

### 2.7 Download the IOTA mainnet database
To download the latest snapshot of the database (faster initial sync) use the following commands:
```sh
chmod +x download_mainnet_db.sh
./download_mainnet_db.sh
```

### 2.8 Open the following ports in your firewall for the ROCK64 ip address
- 14600 UDP - IOTA/IRI UDP connection port
- 15600 TCP - IOTA/IRI TCP connection port
- 16600 TCP - Nelson.cli TCP connection port
- 21310 TCP - Field.cli TCP connection port

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
### 3.2 Check the logs

Check the IRI logs with
```sh
docker logs iota_iri
```

Check the Nelson logs with
```sh
docker logs iota_nelson.cli
```

### 3.3 Open Nelson GUI

Open your browser to
```http
http://YOUR-ROCK64-IP:5000/
```

### 3.4 Update when a new release of any container is published

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


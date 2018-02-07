#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function display
{
    echo ""
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "~ $*"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo ""
}

display "Hello "$SUDO_USER".  Welcome to the AstroMaster Raspberry Pi 3 Configuration Script."

display "This will update, install and configure your Raspberry Pi 3 as an INDI server to control your astrophotography equipment."

if [[ $(whoami) != "root" ]]; then
	display "Please run this script with sudo due to the fact that it must do a number of tasks as root.  Exiting now."
	exit 1
elif [[ $SUDO_USER == "root" ]]; then
	display "Please run this script as a user other than root.  This script will modify the user permissions to allow for serial and SMB access."
	exit 1
fi

read -p "Are you ready to proceed (y/n)? " proceed

if [[ $proceed != "y" ]]; then
	exit
fi

#########################################################
#############  Updates

# This would update the Raspberry Pi kernel.  For now it is disabled because there is debate about whether to do it or not.  To enable it, take away the # sign.
#display "Updating Kernel"
#rpi-update

# Fix for Ubuntu server
if [[ $(cat /proc/version) == *"raspi2"*"Ubuntu"* ]]; then
	read -p "Ubuntu installation detected! Is this a fresh installation of Ubuntu Server for RPi 3 (y/n)? " UBUNTU_SERVER_FIX
	if [[ $UBUNTU_SERVER_FIX == "y" ]]; then
		display "Applying Ubuntu Server fix for internal WiFi driver."
		dpkg-divert --divert /lib/firmware/brcm/brcmfmac43430-sdio-2.bin --package linux-firmware-raspi2 --rename --add /lib/firmware/brcm/brcmfmac43430-sdio.bin

		display "Applying Ubuntu Server fix for uBoot"
		sed -i -e 's/device_tree_address=0x100/device_tree_address=0x02008000/g' /boot/firmware/config.txt
		sed -i -e 's/device_tree_end=0x8000/#device_tree_end=0x8000/g' /boot/firmware/config.txt
	fi
fi

# Updates the Raspberry Pi to the latest packages.
display "Updating installed packages"
apt update
apt -y upgrade
apt -y dist-upgrade

# Fix for Ubuntu server WiFi driver
if [[ $UBUNTU_SERVER_FIX == "y" ]]; then
	mv /lib/firmware/brcm/brcmfmac43430-sdio.bin /lib/firmware/brcm/brcmfmac43430-sdio.bin.old
	wget -P /lib/firmware/brcm https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm/brcmfmac43430-sdio.bin
	wget -P /lib/firmware/brcm https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm/brcmfmac43430-sdio.txt
fi

# This will increase the maximum USB current (for all ports combined) from 600mA to 1200mA
CONFIG_FILE=""
if [ -f /boot/config.txt ]; then
	CONFIG_FILE=/boot/config.txt
elif [ -f /boot/firmware/config.txt ]; then
	CONFIG_FILE=/boot/firmware/config.txt
fi
if [[ $CONFIG_FILE != "" ]]; then
	if [[ -z $(grep 'max_usb_current=' $CONFIG_FILE) ]]; then
		cat >> $CONFIG_FILE <<- EOF

max_usb_current=1
EOF
	fi
fi

# This will configure the internal WiFi as an Access Point and set a static IP address
if [ ! -f /etc/network/interfaces.d/60-ap-init.cfg ]; then
	display "Configuring WiFi interface with static IP and enabling Hotspot with DHCP."

	apt -y install hostapd dnsmasq wireless-tools

	# Set the hostname for the RPi
	cat > /etc/hostname <<- EOF
AstroPi
EOF

	# Update hosts file
	sed -i "1s;^;10.0.0.1 AstroPi.local AstroPi\n;" /etc/hosts

	# Configure the WiFi Hotspot
	cat > /etc/hostapd/ap.conf <<- EOF
interface=wlan0
hw_mode=g
channel=11
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_passphrase=Andromeda
ssid=AstroPi
EOF

	# Set Hotspot config file
	cat >> /etc/default/hostapd <<- EOF

DAEMON_CONF="/etc/hostapd/ap.conf"
EOF

	# Configure DHCP
	cat >> /etc/dnsmasq.conf <<- EOF

interface=wlan0
dhcp-range=10.0.0.2,10.0.0.5,255.255.255.0,12h
EOF

	# Configure WiFi interface
	cat > /etc/network/interfaces.d/60-ap-init.cnf <<- EOF
auto wlan0
allow-hotplug wlan0
iface wlan0 inet static
	address 10.0.0.1
	netmask 255.255.255.0
	pre-up ip addr flush dev wlan0
	post-up service hostapd restart
	post-up service dnsmasq restart
	pre-down service dnsmasq stop
	pre-down service hostapd stop
EOF

fi

#########################################################
#############  Very Important Configuration Items

# This will create a swap file for an increased 2 GB of artificial RAM.  This is not needed on all systems, since different cameras download different size images, but if you are using a DSLR, it definitely is.
# This method is disabled in favor of the zram method below. If you prefer this method, you can re-enable it by taking out the #'s
#display "Creating SWAP Memory"
#wget https://raw.githubusercontent.com/Cretezy/Swap/master/swap.sh -O swap
#sh swap 2G
#rm swap

# This will create zram, basically a swap file saved in RAM. It will not read or write to the SD card, but instead, writes to compressed RAM.  
# This is not needed on all systems, since different cameras download different size images, and different SBC's have different RAM capacities but 
# if you are using a DSLR on a Raspberry Pi with 1GB of RAM, it definitely is needed. If you don't want this, comment it out.
display "Installing zRAM for increased RAM capacity, from 1 GB to 1.5 GB"
apt -y install zram-config

# This should fix an issue where you might not be able to use a serial mount connection because you are not in the "dialout" group
display "Enabling Serial Communication"
usermod -aG dialout $SUDO_USER


#########################################################
#############  ASTRONOMY SOFTWARE

# Add Repositories
apt-add-repository ppa:mutlaqja/ppa -y
apt-add-repository ppa:pch/phd2 -y
apt update

# Installs INDI
display "Installing INDI server"
apt -y install indi-full

# Installs the General Star Catalog if you plan on using the simulators to test (If not, you can comment this line out with a #)
display "Installing GSC"
apt -y install gsc

# Installs the Astrometry.net package for supporting offline plate solves.  If you just want the online solver, comment this out with a #.
display "Installing Astrometry.net"
apt -y install astrometry.net

# Installs PHD2 if you want it.  If not, comment each line out with a #.
display "Installing PHD2"
apt -y install phd2

#########################################################
#############  INDI WEB MANAGER

display "Installing and Configuring INDI Web Manager"

# Install Python
apt -y install python-pip
pip install --upgrade pip

# This will install INDI Web Manager
pip install indiweb

# This will prepare the indiwebmanager.service file
cat > /etc/systemd/system/indiwebmanager.service <<- EOF
[Unit]
Description=INDI Web Manager
After=multi-user.target

[Service]
Type=idle
User=$SUDO_USER
ExecStart=/usr/local/bin/indi-web -v
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# This will change the indiwebmanager.service file permissions and enable it.
chmod 644 /etc/systemd/system/indiwebmanager.service
systemctl daemon-reload
systemctl enable indiwebmanager.service

#########################################################
#############  File Sharing Configuration

display "Setting up File Sharing"

# Installs samba so that you can share files to your other computer(s).
apt -y install samba

# Share user directory
cat >> /etc/samba/smb.conf <<- EOF

[$SUDO_USER]
path = /home/$SUDO_USER
valid users = $SUDO_USER
read only = no
EOF

# Adds yourself to the user group of who can use samba.
smbpasswd -a $SUDO_USER

#########################################################
#############  UDEV Script

# This will make the udev in the folder executable in case the user wants to use it.
chmod +x "$DIR/udevRuleScript.sh"

display "Script Execution Complete.  Your Raspberry Pi 3 should now be ready to use for Astrophotography.  You should restart your Pi."


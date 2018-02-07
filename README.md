# AstroPi-Server

Setup Astrophotography control on Raspberry Pi 3 running Ubuntu Server 16.04LTS ARM

This script was inspired from the AstroPi3 project [https://github.com/rlancaste/AstroPi3].
Unlike the original project, this script is designed to setup an INDI Server running in a headless (no GUI) installation of Ubuntu Server instead of Ubuntu MATE.

## Install Instructions

 1) Download the Ubuntu Server 16.04 LTS install for Raspberry Pi 3 [http://www.finnie.org/software/raspberrypi/ubuntu-rpi3/ubuntu-16.04-preinstalled-server-armhf+raspi3.img.xz].
 2) Extract .img file from .xz archive (use 7-zip in Windows or tar in Linux).
 3) Use SD Writer (ie: Win32DiskImager, Etcher, etc... in Windows / dd in Linux) to write .img to SD card.
 4) With LAN cable connected, insert SD into Raspberry Pi 3 and connect power cable.
 5) Log in (via console or SSH) using default credentials (ubuntu/ubuntu).
 6) OS should ask you to change password after first login (if not, run passwd).
 7) Install git (sudo apt install git).
 8) Download AstroPi-Server scripts (git clone https://github.com/slightlyremoveddesign/AstroPi-Server.git).
 9) Browse to the AstroPi-Server directory (cd AstroPi-Server).
10) Make setup script executable (chmod +x setup-AstroPi-Server.sh).
11) Run setup script with sudo (sudo ./setup-AstroPi-Server.sh).  The script must be ran as a normal user using sudo to elevate priviledges (not as root).
12) Follow instructions of script.
13) The last part of the script will ask you to set a password for Samba file access (I recommend using the same password as set in step 6).
14) Reboot Raspberry Pi (sudo reboot).


The WLAN interface will have a static IP of 10.0.0.1 and offer DHCP leases (10.0.0.2-10.0.0.5).

## Script Details (what does it do?)
 1) Ubuntu Server 16.04 has some minor initial problems on the Raspberry Pi 3, this script will apply the needed fixes (see https://raspberrypi.stackexchange.com/questions/72337/how-do-i-install-ubuntu-server-16-04-on-pi3-model-b).
 2) Install updates
 3) Increase Maximum USB Current (for all ports combined) from 600mA to 1200mA.  Make sure your power supply is capable supplying the extra current.
 4) Configure WLAN interface with static IP address (10.0.0.1/24).
 5) Configure WLAN interface to automatically restart/stop services for DHCP and Hotsopt.
 5) Configure WLAN interface to supply IP addresses via DHCP (10.0.0.2-10.0.0.5).
 6) Configure WLAN interface as WiFi Hotspot (SSID: AstroPi / PSK: Andromeda) for use in the field.
 7) Set hostname to AstroPi.
 8) Add AstroPi and AstroPi.local to hosts file for DNS resolution.
 9) Install zram-config (increases RAM from 1GB to 1.5GB using compression, very important for DSLR photo size).
10) Add user to dialout group (allows serial communication).
11) Add INDI and PHD2 repositories to APT.
12) Install Astronomy software (INDI, General Star Catalog, Astrometry.net, and PHD2).
13) Install and update python-pip.
14) Install INDI Web Manager and configure as startup service (accessable at http://AstroPi.local:8624).
15) Install Samba and share user's home directory via SMB.
16) Add user to group with permission to use Samba (asks user to set Samba password).
17) Set udevRuleScript.sh as executable (used to give static names to USB devices, use after rebooting).

## TODO
 - Add script or interface to allow for changing of IP, Hostname, DHCP, Hotspot, etc...
 - Add script or interface to allow for changing of Samba file shares.
 - Create Web interface for controlling equipment (if I find the time).

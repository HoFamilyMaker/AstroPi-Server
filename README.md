# AstroPi

Setup Astrophotography control on Raspberry Pi 3 running Ubuntu Server 16.04LTS ARM

This script was inspired from the AstroPi3 project [https://github.com/rlancaste/AstroPi3].
Unlike the original project, this script is designed to setup an INDI Server running in a headless (no GUI) installation of Ubuntu Server instead of Ubuntu MATE.

### Install Instructions ###

 1) Download the Ubuntu Server 16.04 LTS install for Raspberry Pi 3 [http://www.finnie.org/software/raspberrypi/ubuntu-rpi3/ubuntu-16.04-preinstalled-server-armhf+raspi3.img.xz].
 2) Extract .img file from .xz archive (use 7-zip in Windows or tar in Linux).
 3) Use SD Writer (ie: Win32DiskImager, Etcher, etc... in Windows / dd in Linux) to write .img to SD card.
 4) With LAN cable connected, insert SD into Raspberry Pi 3 and connect power cable
 5) Log in (via console or SSH) using default credentials (ubuntu/ubuntu)
 6) OS should ask you to change password after first login (if not, run passwd)
 7) Install git (sudo apt install git)
 8) Download AstroPi scripts (git clone https://github.com/slightlyremoveddesign/AstroPi.git)
 9) Browse to the AstroPi directory (cd AstroPi)
10) Make setup script executable (chmod +x setupAstroPi.sh)
11) Run setup script with sudo (sudo ./setupAstroPi.sh)
12) Follow instructions of script
13) The last part of the script will ask you to set a password for Samba file access (I recommend using the same password as set in step 6)
14) Reboot Raspberry Pi (sudo reboot)

The script will create a WiFi hotspot using the internal WLAN interface (SSID: AstroPi / PSK: Andromeda) for use in the field.
The WLAN interface will have a static IP of 10.0.0.1 and offer DHCP leases (10.0.0.2-10.0.0.5).

# gvm_install
A script to install GVM / OpenVAS 11 on Ubuntu 20.04

Usage:

Ubuntu:
```
wget https://raw.githubusercontent.com/yu210148/gvm_install/master/install_gvm.sh
chmod +x install_gvm.sh
sudo ./install_gvm.sh 
```

Debian:
```
apt install sudo
wget https://raw.githubusercontent.com/yu210148/gvm_install/master/install_gvm.sh
chmod +x install_gvm.sh
sudo -i
./install_gvm.sh
```
When the script completes if everything went well the web interface should be available on the machine you ran this on. 
Locate the IP address `ip a` is one way to do that. Then, point a web browser to https://<ip-address-of-machine> where <ip-address-of-machine>
is the actual address.

It uses a self-signed certificate so you'll see a warning in the web browser about that. Feel free to replace the cert or ignore the warning.

Based on [koromicha's excellent guide](https://kifarunix.com/install-and-setup-gvm-11-on-ubuntu-20-04/). Thanks to the commenters there as well for useful troubleshooting info.

Takes a while to do everything (a couple of hours on my last test).

When creating a task be sure to select the "Created OpenVAS Scanner" from the drop-down.

Tested successfully in VMs in December of 2020. Your experience may be different. Use at your own risk.



Licensed under GPLv3 or later.

# gvm_install
A script to install GVM / 20 on Ubuntu 20.04

Usage:

Ubuntu:
```
wget https://raw.githubusercontent.com/yu210148/gvm_install/master/install_gvm.sh
chmod +x install_gvm.sh
sudo ./install_gvm.sh 
```

Debian:
* Note, I had an issue when testing GVM version 20 on Debian where nmap wasn't detected. I don't have a resolution for this at the moment so if you select version 20 on Debian stable you may run into issues. If you have any idea how to fix this please let me know. 
```
apt install sudo
usermod -aG sudo <your-user-name> # add your user to the sudoer's group
wget https://raw.githubusercontent.com/yu210148/gvm_install/master/install_gvm.sh
chmod +x install_gvm.sh
sudo -i
./install_gvm.sh
```

When the script completes if everything went well the web interface should be available on the machine you ran this on. 
Locate the IP address `ip a` is one way to do that. Then, point a web browser to `https://<ip-address-of-machine>` where `<ip-address-of-machine>`
is the actual address.

It uses a self-signed certificate so you'll see a warning in the web browser about that. Feel free to replace the cert or ignore the warning.

**********
# Post Installation Steps
1) Seems, that after completing the script for version 20 the machine needs to be restarted. 
2) Then you should be able to log into the web interface. 
3) Once logged in, head over to Administration-->Feed Status. 

If any of the feeds show a status of 'Update in progress' wait until they're completed. 

## Steps 4-7 will take a very long time (expect up to 24 hours)

4) Run the below to force an update of the data within Greenbone Security Assistant

      a) On Ubuntu 20.04, sudo -i<br/>
      b) su gvm<br/>
      c) /opt/gvm/sbin/greenbone-feed-sync --type SCAP<br/>
      d) /opt/gvm/bin/greenbone-nvt-sync<br/>
      e) /opt/gvm/sbin/greenbone-feed-sync --type CERT<br/>
      f) /opt/gvm/sbin/greenbone-feed-sync --type GVMD_DATA<br/>
      g) /usr/bin/sudo /opt/gvm/sbin/openvas --update-vt-info<br/>

7) To check the status of each command above go to https://localhost from the server, login with the user credentials (likely gvmadmin and StrongPass), go to Administration, Feed Status. 

Sample of Updating Status
![VirtualBoxVM_6q0KvUTfOU](https://user-images.githubusercontent.com/14837699/115396919-83f4ab80-a1b3-11eb-9383-e345d59eaebd.png)

9) Once all the feeds are showing versions that look like dates (e.g., 20201229T1131 or "Current") and the status is no longer showing as updating you should be able to start a scan using the OpenVAS Scanner under Scans-->Tasks-->New Task.
*********

Depending on how your network is set up--specifically, with regards to IPv4 and IPv6--you may run into issues accessing the web interface. See <a href=https://github.com/yu210148/gvm_install/issues/7>Issue #7</a> for more info. 

Based on [koromicha's excellent guide](https://kifarunix.com/install-and-setup-gvm-11-on-ubuntu-20-04/). Thanks to the commenters there as well for useful troubleshooting info.

Takes a while to do everything (a couple of hours on my last test).

Tested successfully in VMs in December of 2020. Your experience may be different. Use at your own risk.

Licensed under GPLv3 or later.

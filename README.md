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

# Steps 4-7 will take a very long time (expect up to 24 hours)

4) While you're waiting, log in to a command prompt on the machine and become the GVM user (e.g., sudo -i, su gvm). 
5) List the gvm user's crontab file with 'crontab -l' and manually execute the commands shown there (e.g., '/opt/gvm/sbin/greenbone-feed-sync --type SCAP') once the feed status changes from 'Update in progress' to the feed's actual status.
6) When you run the commands from the crontab the feed status update as shown in the web interface will change back to show that it's updating. Again, wait for it to complete before running the next line from the crontab. 
7) Once all the feeds are showing versions that look like dates (e.g., 20201229T1131) and the status is no longer showing as updating you should be able to start a scan using the OpenVAS Scanner under Scans-->Tasks-->New Task.

*********

Depending on how your network is set up--specifically, with regards to IPv4 and IPv6--you may run into issues accessing the web interface. See <a href=https://github.com/yu210148/gvm_install/issues/7>Issue #7</a> for more info. 

Based on [koromicha's excellent guide](https://kifarunix.com/install-and-setup-gvm-11-on-ubuntu-20-04/). Thanks to the commenters there as well for useful troubleshooting info.

Takes a while to do everything (a couple of hours on my last test).

Tested successfully in VMs in December of 2020. Your experience may be different. Use at your own risk.



Licensed under GPLv3 or later.

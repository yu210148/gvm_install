# gvm_install
A script to install GVM 20 / 21 on Ubuntu 20.04

Usage:

Ubuntu:
```
wget https://raw.githubusercontent.com/yu210148/gvm_install/master/install_gvm.sh
chmod +x install_gvm.sh
sudo ./install_gvm.sh -v 21 -u
```

Debian:
* Note, I had an issue when testing GVM version 20 on Debian where nmap wasn't detected. I don't have a resolution for this at the moment so if you select version 20 on Debian stable you may run into issues. If you have any idea how to fix this please let me know. This doesn't seem to affect GVM version 21. 
* There have been some reports of output lacking results on Ubuntu systems with GVM version 21. This appears to be because the scanner fails to use the installed nmap for port scanning. See <a href=https://github.com/yu210148/gvm_install/issues/48>Issue #48</a> and <a href=https://github.com/yu210148/gvm_install/issues/26#issuecomment-758717805>Issue #26 (comment)</a> for more info and how to manually add it.

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

If you have openvas 20.08 and you upgrade to 21.04, there is a bug in the database version. You need to modify your database before upgrade. Cf: https://github.com/greenbone/gvmd/issues/1497
```
su - postgres
psql gvmd
CREATE TABLE IF NOT EXISTS vt_severities (id SERIAL PRIMARY KEY,vt_oid text NOT NULL,type text NOT NULL, origin text,date integer,score double precision,value text); 
SELECT create_index ('vt_severities_by_vt_oid','vt_severities', 'vt_oid'); 
ALTER TABLE vt_severities OWNER TO gvm;
```

Licensed under GPLv3 or later.

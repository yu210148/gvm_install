# gvm_install
A script to install GVM / OpenVAS 11 on Ubuntu 20.04

Usage (note the text editor line -- use whichever editor you'd like but take a look through the script to see what it's going to do when you run it.):

```
wget https://raw.githubusercontent.com/<account>/gvm_install/master/install_gvm.sh
nano install_gvm.sh 
chmod +x install_gvm.sh
sudo ./install_gvm.sh 
```

Based on [koromicha's excellent guide](https://kifarunix.com/install-and-setup-gvm-11-on-ubuntu-20-04/). Thanks to the commenters there as well for useful troubleshooting info.


Takes a while to do everything (a couple of hours on my last test).

When creating a task be sure to select the "Created OpenVAS Scanner" from the drop-down.

Tested successfully in a VM on 2020-08-12. Your experience may be different. Use at your own risk.

Licensed under GPLv3 or later.

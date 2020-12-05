#!/bin/bash
######################################################################
# Script to install Greenbone/OpenVAS on Ubuntu 20.04
#
# Note: run as root
#
# Usage: sudo ./update_gvm.sh 
#
# Based on:
# https://kifarunix.com/install-and-setup-gvm-11-on-ubuntu-20-04/?amp
#
# Works-for-me as of 2020-05-12. Your experience may be different.
# Use at your own risk.
#
# Licensed under GPLv3 or later
######################################################################

cd /opt/gvm/gvm-libs
sudo -u gvm rm -rf /opt/gvm/gvm-libs/build
sudo -u gvm mkdir /opt/gvm/gvm-libs/build
sudo -u gvm git pull

cd /opt/gvm/openvas-smb
sudo -u gvm rm -rf /opt/gvm/openvas-smb/build
sudo -u gvm mkdir /opt/gvm/openvas-smb/build
sudo -u gvm git pull

#TODO fix pcap_lookupdev 





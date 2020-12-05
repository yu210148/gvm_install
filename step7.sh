#!/bin/bash

usermod -aG tty gvm
chmod g+rw /dev/pts/2

# preamble
sudo -Hiu gvm touch /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc /opt/gvm/.bashrc.bak # save original bashrc file 
sudo -Hiu gvm touch /opt/gvm/.bashrc

# steps to be taken go here

# may need to change the permissions on the target of 
# /dev/stderr (and others?) as root before running this
# and add the gvm user to the tty group
#root@debian-gvm:~# usermod -aG tty gvm
#root@debian-gvm:~# chmod g+rw /dev/pts/2

sudo -Hiu gvm echo "greenbone-nvt-sync" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
# when done clean up with the code below

# Leave gvm environment and clean up
sudo -Hiu gvm echo "exit" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
su gvm
sudo -Hiu gvm rm /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc.bak /opt/gvm/.bashrc

#!/bin/bash

# preamble
sudo -Hiu gvm touch /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc /opt/gvm/.bashrc.bak # save original bashrc file 
sudo -Hiu gvm touch /opt/gvm/.bashrc

# Build and Install Greenbone Vulnerability Manager
sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cd /tmp/gvm-source/gvmd" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc # TODO:this dir doesn't exist!
sudo -Hiu gvm echo "mkdir build" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cd build" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Leave gvm environment and clean up
sudo -Hiu gvm echo "exit" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
su gvm
sudo -Hiu gvm rm /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc.bak /opt/gvm/.bashrc

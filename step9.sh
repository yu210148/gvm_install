#!/bin/bash

# perhaps a way to do this better would be to have it use tee to write a script (separate from .bashrc)
# then call that with su gvm -c
su gvm -c "touch /opt/gvm/gvm_build.sh"
su gvm -c "chmod u+x /opt/gvm/gvm_build.sh"

# Build and Install Greenbone Vulnerability Manager
sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "cd /tmp/gvm-source/gvmd" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "mkdir build" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "cd build" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh

su gvm -c "/opt/gvm/gvm_build.sh"
#su gvm -c "rm /opt/gvm/gvm_build.sh"

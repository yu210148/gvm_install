#!/bin/bash
######################################################################
# Script to install Greenbone/OpenVAS on Ubuntu 20.04
#
# Note: run as root
#
# Usage: sudo ./install_gvm.sh 
#
# Based on:
# https://kifarunix.com/install-and-setup-gvm-11-on-ubuntu-20-04/?amp
#
# Works-for-me as of 2020-05-12. Your experience may be different.
# Use at your own risk.
#
# Licensed under GPLv3 or later
######################################################################
apt-get update
apt-get upgrade
useradd -r -d /opt/gvm -c "GVM (OpenVAS) User" -s /bin/bash gvm
mkdir /opt/gvm
chown gvm:gvm /opt/gvm
apt-get -y install gcc g++ make bison flex libksba-dev curl redis libpcap-dev cmake git pkg-config libglib2.0-dev libgpgme-dev libgnutls28-dev uuid-dev libssh-gcrypt-dev libldap2-dev gnutls-bin libmicrohttpd-dev libhiredis-dev zlib1g-dev libxml2-dev libradcli-dev clang-format libldap2-dev doxygen nmap gcc-mingw-w64 xml-twig-tools libical-dev perl-base heimdal-dev libpopt-dev libsnmp-dev python3-setuptools python3-paramiko python3-lxml python3-defusedxml python3-dev gettext python3-polib xmltoman python3-pip texlive-fonts-recommended xsltproc texlive-latex-extra rsync --no-install-recommends
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update
apt-get -y install yarn
apt-get -y install postgresql postgresql-contrib postgresql-server-dev-all
sudo -Hiu postgres createuser gvm
sudo -Hiu postgres createdb -O gvm gvmd
sudo -Hiu postgres psql -c 'create role dba with superuser noinherit;' gvmd
sudo -Hiu postgres psql -c 'grant dba to gvm;' gvmd
sudo -Hiu postgres psql -c 'create extension "uuid-ossp";' gvmd
systemctl restart postgresql
systemctl enable postgresql
sed -i 's/\"$/\:\/opt\/gvm\/bin\:\/opt\/gvm\/sbin\:\/opt\/gvm\/\.local\/bin\"/g' /etc/environment
echo "/opt/gvm/lib" > /etc/ld.so.conf.d/gvm.conf
sudo -Hiu gvm mkdir /tmp/gvm-source
cd /tmp/gvm-source
sudo -Hiu gvm git clone -b gvm-libs-11.0 https://github.com/greenbone/gvm-libs.git
sudo -Hiu gvm git clone https://github.com/greenbone/openvas-smb.git
sudo -Hiu gvm git clone -b openvas-7.0 https://github.com/greenbone/openvas.git
sudo -Hiu gvm git clone -b ospd-2.0 https://github.com/greenbone/ospd.git
sudo -Hiu gvm git clone -b ospd-openvas-1.0 https://github.com/greenbone/ospd-openvas.git
sudo -Hiu gvm git clone -b gvmd-9.0 https://github.com/greenbone/gvmd.git
sudo -Hiu gvm git clone -b gsa-9.0 https://github.com/greenbone/gsa.git
sudo -Hiu gvm cp --recursive /opt/gvm/* /tmp/gvm-source/
sudo -Hiu gvm touch /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc /opt/gvm/.bashrc.bak # save original bashrc file 
sudo -Hiu gvm touch /opt/gvm/.bashrc
sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Build and Install GVM 11 Libraries
sudo -Hiu gvm echo "cd gvm-libs" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "mkdir build" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cd build" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Build and Install OpenVAS and OpenVAS SMB
sudo -Hiu gvm echo "cd ../../openvas-smb/" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "mkdir build" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cd build" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cd ../../openvas" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "mkdir build" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cd build" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "sed -i 's/set (CMAKE_C_FLAGS_DEBUG\s.*\"\${CMAKE_C_FLAGS_DEBUG} \${COVERAGE_FLAGS}\")/set (CMAKE_C_FLAGS_DEBUG \"\${CMAKE_C_FLAGS_DEBUG} -Werror -Wno-error=deprecated-declarations\")/g' ../../openvas/CMakeLists.txt" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
# Leave gvm environment and clean up
sudo -Hiu gvm echo "exit" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
su gvm
sudo -Hiu gvm rm /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc.bak /opt/gvm/.bashrc

# Configuring OpenVAS
ldconfig
cp /tmp/gvm-source/openvas/config/redis-openvas.conf /etc/redis/
chown redis:redis /etc/redis/redis-openvas.conf
echo "db_address = /run/redis-openvas/redis.sock" > /opt/gvm/etc/openvas/openvas.conf
chown gvm:gvm /opt/gvm/etc/openvas/openvas.conf
usermod -aG redis gvm
echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl -p
touch /etc/systemd/system/disable_thp.service
echo "[Unit]" > /etc/systemd/system/disable_thp.service
echo "Description=Disable Kernel Support for Transparent Huge Pages (THP)" >> /etc/systemd/system/disable_thp.service
echo -e "\n" >> /etc/systemd/system/disable_thp.service
echo "[Service]" >> /etc/systemd/system/disable_thp.service
echo "Type=simple" >> /etc/systemd/system/disable_thp.service
echo -e "ExecStart=/bin/sh -c \"echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag\"" >> /etc/systemd/system/disable_thp.service
echo -e "\n" >> /etc/systemd/system/disable_thp.service
echo "[Install]" >> /etc/systemd/system/disable_thp.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/disable_thp.service
systemctl daemon-reload
systemctl enable --now disable_thp
systemctl start redis-server@openvas
systemctl enable redis-server@openvas
echo "gvm ALL = NOPASSWD: /opt/gvm/sbin/openvas" > /etc/sudoers.d/gvm
# This next line varies between Debian and Ubuntu because it includes /snap/bin on Ubuntu                                                                                                    
ID=`grep ^ID /etc/os-release | sed 's/ID=//g'`

if [ $ID = "debian" ]; then
    sed 's/Defaults\s.*secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin"/Defaults secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/opt\/gvm\/sbin\:\/opt\/gvm\/bin"/g' /etc/sudoers | EDITOR='tee' visudo
    
    # when adapting this script for Debian I found that there's an issue later on when the gvm user
    # tries to run greenbone-nvt-sync. The thing tries to write to /dev/stderr and receives a permission denied message
    # The code below works around the problem by adding the gvm user to the tty group and setting the permissons for group
    # read/write on the target of the /dev/stderr symlink (if you're /dev/stderr doesn't point to /dev/pts/2 you may need
    # to adjust the chmod command below.
    # more info at https://unix.stackexchange.com/questions/38538/bash-dev-stderr-permission-denied
    usermod -aG tty gvm
    chmod g+rw /dev/pts/2 # may be a problem here as this isn't constant
else
    sed 's/Defaults\s.*secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin\"/Defaults secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin:\/opt\/gvm\/sbin\"/g' /etc/sudoers | EDITOR='tee' visudo
fi

#sed 's/Defaults\s.*secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin\"/Defaults secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin:\/opt\/gvm\/sbin\"/g' /etc/sudoers | EDITOR='tee' visudo
echo "gvm ALL = NOPASSWD: /opt/gvm/sbin/gsad" >> /etc/sudoers.d/gvm

#Update OpenVAS NVTs
sudo -Hiu gvm touch /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc /opt/gvm/.bashrc.bak # save original bashrc file 
sudo -Hiu gvm touch /opt/gvm/.bashrc

# This next command fails in get_community_feed function in greenbone-nvt-sync if the
# rsync calls are too close together as only one connection is allowed at a time. So we
# need to add a sleep command in that file to pause the sync so that the NAT connection can close
# file is in /opt/gvm/bin and the line to edit is 364. More info can be found by searching
# greenbone-nvt-sync rsync connection refused
#
# add in the following
#  # sleep to allow NAT connection to close                                                                                                                                                   
#  sleep 300
#sudo -Hiu gvm echo "sed -i '364isleep 300' /opt/gvm/bin/greenbone-nvt-sync" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
#sudo -Hiu gvm echo "echo 'Sleeping for 5 minutes'" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
#sudo -Hiu gvm echo "echo 'More info can be found by searching greenbone-nvt-sync rsync connection refused on Google'" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
#sudo -Hiu gvm echo "greenbone-nvt-sync" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# trying this a different way here
su gvm -c "sed -i '364isleep 300' /opt/gvm/bin/greenbone-nvt-sync"
su gvm -c 'echo "Sleeping for 5 minutes"'
su gvm -c 'echo "More info can be found by searching greenbone-nvt-sync rsync connection refused on Google"'
su gvm -c /opt/gvm/bin/greenbone-nvt-sync
/opt/gvm/sbin/openvas --update-vt-info

#sudo -Hiu gvm echo "sudo openvas --update-vt-info" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Leave gvm environment and clean up
#sudo -Hiu gvm echo "exit" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
#su gvm #TODO this script doesn't appear to execute this line but rather stops here; unclear why or what to do about it as I'm doing exactly the same thing I did above.
# the line above it executes as the 'exit' line appears in /opt/gvm/.bashrc but it doesn't switch over to the gvm user here. I've tried it running sudo steps1-8.sh in a 
# sudo -i session, and in an su session all with the same result.

sudo -Hiu gvm rm /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc.bak /opt/gvm/.bashrc

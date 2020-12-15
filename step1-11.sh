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
apt-get -y install gcc g++ make bison flex libksba-dev curl redis libpcap-dev cmake git pkg-config libglib2.0-dev libgpgme-dev libgnutls28-dev uuid-dev libssh-gcrypt-dev libldap2-dev gnutls-bin libmicrohttpd-dev libhiredis-dev zlib1g-dev libxml2-dev libradcli-dev clang-format libldap2-dev doxygen nmap gcc-mingw-w64 xml-twig-tools libical-dev perl-base heimdal-dev libpopt-dev libsnmp-dev python3-setuptools python3-paramiko python3-lxml python3-defusedxml python3-dev gettext python3-polib xmltoman python3-pip texlive-fonts-recommended xsltproc texlive-latex-extra rsync ufw ntp git --no-install-recommends
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update
apt-get -y install yarn
apt-get -y install postgresql postgresql-contrib postgresql-server-dev-all
systemctl restart postgresql
sudo -Hiu postgres createuser gvm
sudo -Hiu postgres createdb -O gvm gvmd
sudo -Hiu postgres psql -c 'create role dba with superuser noinherit;' gvmd
sudo -Hiu postgres psql -c 'grant dba to gvm;' gvmd
sudo -Hiu postgres psql -c 'create extension "uuid-ossp";' gvmd
systemctl restart postgresql
systemctl enable postgresql

# step 1 above 2 below

# Kali Linux uses postgresql 13 which cmake doesn't know about as of version 3.18 so it get's added here
# should have no effect on Debian stable as the line starts with "11" rather than "12" so it won't be matched
ID=`grep ^ID= /etc/os-release | sed 's/ID=//g'`
if [[ $ID = "debian" ]] || [[ $ID = "kali" ]]; then
    sed -i 's/"12" "11" "10"/"13" "12" "11" "10"/g' /usr/share/cmake-3.18/Modules/FindPostgreSQL.cmake
fi

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

# Kali linux 2020.4 puts a message about python2 in that's causing problems below. This should workaround.
if [[ $ID = "debian" ]] || [[ $ID = "kali" ]]; then
    touch /opt/gvm/.hushlogin
    chown gvm:gvm /opt/gvm/.hushlogin
    touch /root/.hushlogin
fi

sudo -Hiu gvm touch /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc /opt/gvm/.bashrc.bak # save original bashrc file 
sudo -Hiu gvm touch /opt/gvm/.bashrc
sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Build and Install GVM 11 Libraries
sudo -Hiu gvm echo "cd /opt/gvm/gvm-libs" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
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

#step 4 below

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
ID=`grep ^ID= /etc/os-release | sed 's/ID=//g'`
if [[ $ID = "debian" ]] || [[ $ID = "kali" ]]; then
    sed 's/Defaults\s.*secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin"/Defaults secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/opt\/gvm\/sbin\:\/opt\/gvm\/bin"/g' /etc/sudoers | EDITOR='tee' visudo
    
    # when adapting this script for Debian I found that there's an issue later on when the gvm user
    # tries to run greenbone-nvt-sync. The thing tries to write to /dev/stderr and receives a permission denied message
    # The code below works around the problem by adding the gvm user to the tty group and setting the permissons for group
    # read/write on the target of the /dev/stderr symlink (if you're /dev/stderr doesn't point to /dev/pts/2 you may need
    # to adjust the chmod command below.
    # more info at https://unix.stackexchange.com/questions/38538/bash-dev-stderr-permission-denied
    usermod -aG tty gvm
    #chmod g+rw /dev/pts/2 # This doesn't work consistantely 
else
    sed 's/Defaults\s.*secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin\"/Defaults secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin:\/opt\/gvm\/sbin:\/opt\/gvm\/bin"/g' /etc/sudoers | EDITOR='tee' visudo
fi

#sed 's/Defaults\s.*secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin\"/Defaults secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin:\/opt\/gvm\/sbin\"/g' /etc/sudoers | EDITOR='tee' visudo
echo "gvm ALL = NOPASSWD: /opt/gvm/sbin/gsad" >> /etc/sudoers.d/gvm

# step 5 below

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


#sudo -Hiu gvm echo "sudo openvas --update-vt-info" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# trying this a different way here TODO: might need to refactor the rest to use this method. Trouble is that the export PKG_CONFIG_PATH doesn't persist though.
su gvm -c "sed -i '364isleep 300' /opt/gvm/bin/greenbone-nvt-sync"
su gvm -c "sed -i '364iecho Sleeping for 5 minutes' /opt/gvm/bin/greenbone-nvt-sync"
su gvm -c 'echo "More info can be found by searching greenbone-nvt-sync rsync connection refused on Google"'
su gvm -c /opt/gvm/bin/greenbone-nvt-sync
/opt/gvm/sbin/openvas --update-vt-info

# step 6 below

# Build and Install Greenbone Vulnerability Manager
su gvm -c "touch /opt/gvm/gvm_build.sh"
su gvm -c "chmod u+x /opt/gvm/gvm_build.sh"

sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "cd /tmp/gvm-source/gvmd" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "mkdir build" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "cd build" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/gvm_build.sh

su gvm -c "/opt/gvm/gvm_build.sh"
su gvm -c "rm /opt/gvm/gvm_build.sh"

# step 7 below

# Build and Install Greenbone Secuirty Assistant
su gvm -c "touch /opt/gvm/gsa_build.sh"
su gvm -c "chmod u+x /opt/gvm/gsa_build.sh"

sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "cd /tmp/gvm-source/gsa" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "mkdir build" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "cd build" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
# if debian { cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm -DCMAKE_BUILD_TYPE=RELEASE }
ID=`grep ^ID= /etc/os-release | sed 's/ID=//g'`
if [[ $ID = "debian" ]] || [[ $ID = "kali" ]]; then
    sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm -DCMAKE_BUILD_TYPE=RELEASE" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
else
    sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
fi
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh

su gvm -c "/opt/gvm/gsa_build.sh"
su gvm -c "rm /opt/gvm/gsa_build.sh"

# step 8 below

# Update GVM CERT and SCAP data from the feed servers
su gvm -c "touch /opt/gvm/feed.sh"
su gvm -c "chmod u+x /opt/gvm/feed.sh"

sudo -Hiu gvm echo "echo Sleeping 5 minutes" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "sleep 300" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh # allow a NAT connection to close
sudo -Hiu gvm echo "sed -i '368isleep 120' /opt/gvm/sbin/greenbone-scapdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo Sleeping 2 minutes" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "/opt/gvm/sbin/greenbone-scapdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo Sleeping 5 minutes" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "sleep 300" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh # allow a NAT connection to close
sudo -Hiu gvm echo "/opt/gvm/sbin/greenbone-certdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
# Add sleep to future greenbone-certdata-sync calls (https://github.com/yu210148/gvm_install/issues/2 --Thanks kirk56k)
sudo -Hiu gvm echo "sed -i '349isleep 300' /opt/gvm/sbin/greenbone-certdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh

su gvm -c "/opt/gvm/feed.sh"
su gvm -c "rm /opt/gvm/feed.sh"

# step 9 below

# Set cron jobs to run once daily at random times
su gvm -c "touch /opt/gvm/cron.sh"
su gvm -c "chmod u+x /opt/gvm/cron.sh"

HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
sudo -Hiu gvm echo "(crontab -l 2>/dev/null; echo \"${MINUTE} ${HOUR} * * * /opt/gvm/sbin/greenbone-scapdata-sync\") | crontab -" | sudo -Hiu gvm tee -a /opt/gvm/cron.sh

HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
sudo -Hiu gvm echo "(crontab -l 2>/dev/null; echo \"${MINUTE} ${HOUR} * * * /opt/gvm/bin/greenbone-nvt-sync\") | crontab -" | sudo -Hiu gvm tee -a /opt/gvm/cron.sh

HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
sudo -Hiu gvm echo "(crontab -l 2>/dev/null; echo \"${MINUTE} ${HOUR} * * * /opt/gvm/sbin/greenbone-certdata-sync\") | crontab -" | sudo -Hiu gvm tee -a /opt/gvm/cron.sh

# I know this is kludgy as this should be run after the nvt sync but if it gets 
# run once a day that should do
HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
sudo -Hiu gvm echo "(crontab -l 2>/dev/null; echo \"${MINUTE} ${HOUR} * * * /usr/bin/sudo /opt/gvm/sbin/openvas --update-vt-info\") | crontab -" | sudo -Hiu gvm tee -a /opt/gvm/cron.sh

# Configure certs
sudo -Hiu gvm echo "/opt/gvm/bin/gvm-manage-certs -a" | sudo -Hiu gvm tee -a /opt/gvm/cron.sh

su gvm -c "/opt/gvm/cron.sh"
su gvm -c "rm /opt/gvm/cron.sh"

# step 10 below

# Build and Install OSPd and OSPd-OpenVAS
su gvm -c "touch /opt/gvm/ospd.sh"
su gvm -c "chmod u+x /opt/gvm/ospd.sh"

sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh

# another difference here between Ubuntu and Debian
# Debian needs the below to be 'python3.7' while Ubuntu 'python3.8'

# going to just get the python3 version number and use it here. That should be better than trying
# to account for the differences with the release ID

PY3VER=`python3 --version | grep -o [0-9]\.[0-9]`
sudo -Hiu gvm echo "mkdir -p /opt/gvm/lib/python$PY3VER/site-packages/" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python$PY3VER/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh


#ID=`grep ^ID= /etc/os-release | sed 's/ID=//g'`
#if [ $ID = "debian" ]; then
#    sudo -Hiu gvm echo "mkdir -p /opt/gvm/lib/python3.7/site-packages/" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
#    sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python3.7/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
#elif [ $ID = "kali" ]; then
#    sudo -Hiu gvm echo "mkdir -p /opt/gvm/lib/python3.9/site-packages/" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
#    sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python3.9/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
#else
#    sudo -Hiu gvm echo "mkdir -p /opt/gvm/lib/python3.8/site-packages/" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
#    sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python3.8/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
#fi
sudo -Hiu gvm echo "cd /tmp/gvm-source/ospd" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
sudo -Hiu gvm echo "python3 setup.py install --prefix=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
sudo -Hiu gvm echo "cd ../ospd-openvas" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh
sudo -Hiu gvm echo "python3 setup.py install --prefix=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/ospd.sh

su gvm -c "/opt/gvm/ospd.sh"
su gvm -c "rm /opt/gvm/ospd.sh"

# step 11 below

# Start OpenVAS Scanner, GSA and GVM services
# Start OpenVAS
su gvm -c "touch /opt/gvm/start.sh"
su gvm -c "chmod u+x /opt/gvm/start.sh"

PY3VER=`python3 --version | grep -o [0-9]\.[0-9]`
sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python$PY3VER/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/start.sh

#ID=`grep ^ID= /etc/os-release | sed 's/ID=//g'`
#if [[ $ID = "debian" ]] || [[ $ID = "kali" ]]; then
#    sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python3.7/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/start.sh
#else
#    sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python3.8/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/start.sh
#fi

# the line below is failing
sudo -Hiu gvm echo "/usr/bin/python3 /opt/gvm/bin/ospd-openvas --pid-file /opt/gvm/var/run/ospd-openvas.pid --log-file /opt/gvm/var/log/gvm/ospd-openvas.log --lock-file-dir /opt/gvm/var/run -u /opt/gvm/var/run/ospd.sock" | sudo -Hiu gvm tee -a /opt/gvm/start.sh

# Start GVM
sudo -Hiu gvm echo "/opt/gvm/sbin/gvmd --osp-vt-update=/opt/gvm/var/run/ospd.sock" | sudo -Hiu gvm tee -a /opt/gvm/start.sh
# Start GSA
sudo -Hiu gvm echo "sudo /opt/gvm/sbin/gsad" | sudo -Hiu gvm tee -a /opt/gvm/start.sh

# Check the status
#sudo -Hiu gvm echo "ps aux | grep -E \"ospd-openvas|gsad|gvmd\" | grep -v grep" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Wait a moment for the above to start up
sudo -Hiu gvm echo "sleep 10" | sudo -Hiu gvm tee -a /opt/gvm/start.sh

su gvm -c "/opt/gvm/start.sh"
su gvm -c "rm /opt/gvm/start.sh"

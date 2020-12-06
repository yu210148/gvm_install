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
    chmod g+rw /dev/pts/2
else
    sed 's/Defaults\s.*secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin\"/Defaults secure_path=\"\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/snap\/bin:\/opt\/gvm\/sbin:\/opt\/gvm\/bin"/g' /etc/sudoers | EDITOR='tee' visudo
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


#sudo -Hiu gvm echo "sudo openvas --update-vt-info" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# trying this a different way here TODO: might need to refactor the rest to use this method. Trouble is that the export PKG_CONFIG_PATH doesn't persist though.
su gvm -c "sed -i '364isleep 300' /opt/gvm/bin/greenbone-nvt-sync"
su gvm -c "sed -i '364iecho 'Sleeping for 5 minutes' /opt/gvm/bin/greenbone-nvt-sync"
su gvm -c 'echo "More info can be found by searching greenbone-nvt-sync rsync connection refused on Google"'
su gvm -c /opt/gvm/bin/greenbone-nvt-sync
/opt/gvm/sbin/openvas --update-vt-info

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

# Build and Install Greenbone Secuirty Assistant
su gvm -c "touch /opt/gvm/gsa_build.sh"
su gvm -c "chmod u+x /opt/gvm/gsa_build.sh"

sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "cd /tmp/gvm-source/gsa" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "mkdir build" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "cd build" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "make" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh
sudo -Hiu gvm echo "make install" | sudo -Hiu gvm tee -a /opt/gvm/gsa_build.sh

su gvm -c "/opt/gvm/gsa_build.sh"
su gvm -c "rm /opt/gvm/gsa_build.sh"

# Update GVM CERT and SCAP data from the feed servers
sudo -Hiu gvm echo "echo Sleeping 5 minutes" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "sleep 300" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc # allow a NAT connection to close
sudo -Hiu gvm echo "sed -i '368isleep 120' /opt/gvm/sbin/greenbone-scapdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "echo Sleeping 2 minutes" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "greenbone-scapdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "echo Sleeping 5 minutes" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "sleep 300" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc # allow a NAT connection to close
sudo -Hiu gvm echo "greenbone-certdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
# Add sleep to future greenbone-certdata-sync calls (https://github.com/yu210148/gvm_install/issues/2 --Thanks kirk56k)
sudo -Hiu gvm echo "sed -i '349isleep 300' /opt/gvm/sbin/greenbone-certdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Set cron jobs to run once daily at random times
HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
sudo -Hiu gvm echo "(crontab -l 2>/dev/null; echo \"${MINUTE} ${HOUR} * * * /opt/gvm/sbin/greenbone-scapdata-sync\") | crontab -" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
sudo -Hiu gvm echo "(crontab -l 2>/dev/null; echo \"${MINUTE} ${HOUR} * * * /opt/gvm/bin/greenbone-nvt-sync\") | crontab -" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
sudo -Hiu gvm echo "(crontab -l 2>/dev/null; echo \"${MINUTE} ${HOUR} * * * /opt/gvm/sbin/greenbone-certdata-sync\") | crontab -" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# I know this is kludgy as this should be run after the nvt sync but if it gets 
# run once a day that should do
HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
sudo -Hiu gvm echo "(crontab -l 2>/dev/null; echo \"${MINUTE} ${HOUR} * * * /usr/bin/sudo /opt/gvm/sbin/openvas --update-vt-info\") | crontab -" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Configure certs
sudo -Hiu gvm echo "gvm-manage-certs -a" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Build and Install OSPd and OSPd-OpenVAS

sudo -Hiu gvm echo "export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

sudo -Hiu gvm echo "mkdir -p /opt/gvm/lib/python3.8/site-packages/" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python3.8/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "cd /tmp/gvm-source/ospd" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc 
sudo -Hiu gvm echo "python3 setup.py install --prefix=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

sudo -Hiu gvm echo "cd ../ospd-openvas" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo "python3 setup.py install --prefix=/opt/gvm" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Start OpenVAS Scanner, GSA and GVM services
# Start OpenVAS
sudo -Hiu gvm echo "/usr/bin/python3 /opt/gvm/bin/ospd-openvas --pid-file /opt/gvm/var/run/ospd-openvas.pid --log-file /opt/gvm/var/log/gvm/ospd-openvas.log --lock-file-dir /opt/gvm/var/run -u /opt/gvm/var/run/ospd.sock" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
# Start GVM
sudo -Hiu gvm echo "gvmd --osp-vt-update=/opt/gvm/var/run/ospd.sock" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
# Start GSA
sudo -Hiu gvm echo "sudo gsad" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Check the status
#sudo -Hiu gvm echo "ps aux | grep -E \"ospd-openvas|gsad|gvmd\" | grep -v grep" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Wait a moment for the above to start up
sudo -Hiu gvm echo "sleep 10" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Create GVM Scanner
sudo -Hiu gvm echo -e "gvmd --create-scanner=\"Created OpenVAS Scanner\" --scanner-type=\"OpenVAS\" --scanner-host=/opt/gvm/var/run/ospd.sock" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

sudo -Hiu gvm echo "gvmd --get-scanners" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Verify newly created scanner
sudo -Hiu gvm echo -e "UUID=\$(gvmd --get-scanners | grep Created | awk '{print \$\1}')" | sed 's/\\//g' | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Wait a moment then verify the scanner
sudo -Hiu gvm echo "sleep 10" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
sudo -Hiu gvm echo -e "gvmd --verify-scanner=UUID" | sed 's/UUID/\$UUID/g' | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Create OpenVAS (GVM 11) Admin
sudo -Hiu gvm echo -e "gvmd --create-user gvmadmin --password=StrongPass" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc

# Leave gvm environment and clean up
sudo -Hiu gvm echo "exit" | sudo -Hiu gvm tee -a /opt/gvm/.bashrc
su gvm
# Debugging
#sudo -Hiu gvm mv /opt/gvm/.bashrc /opt/gvm/just-ran-bashrc.txt
sudo -Hiu gvm rm /opt/gvm/.bashrc
sudo -Hiu gvm mv /opt/gvm/.bashrc.bak /opt/gvm/.bashrc

# Set firewall to allow access on port 443 and 22
ufw allow 443
ufw allow 22
ufw --force enable

# Create systemd services for OpenVAS Scanner, GSA, and GVM services
echo "[Unit]" > /etc/systemd/system/openvas.service
echo "Description=Control the OpenVAS service" >> /etc/systemd/system/openvas.service
echo "After=redis.service" >> /etc/systemd/system/openvas.service
echo "After=postgresql.service" >> /etc/systemd/system/openvas.service
echo -e "\n" >> /etc/systemd/system/openvas.service
echo "[Service]" >> /etc/systemd/system/openvas.service
echo "ExecStartPre=-rm /opt/gvm/var/run/ospd-openvas.pid /opt/gvm/var/run/ospd.sock /opt/gvm/var/run/gvmd.sock" >> /etc/systemd/system/openvas.service
echo "Type=simple" >> /etc/systemd/system/openvas.service
echo "User=gvm" >> /etc/systemd/system/openvas.service
echo "Group=gvm" >> /etc/systemd/system/openvas.service
echo "Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin" >> /etc/systemd/system/openvas.service
echo "Environment=PYTHONPATH=/opt/gvm/lib/python3.8/site-packages" >> /etc/systemd/system/openvas.service
echo -e "ExecStart=/usr/bin/python3 /opt/gvm/bin/ospd-openvas --pid-file /opt/gvm/var/run/ospd-openvas.pid --log-file /opt/gvm/var/log/gvm/ospd-openvas.log --lock-file-dir /opt/gvm/var/run -u /opt/gvm/var/run/ospd.sock" >> /etc/systemd/system/openvas.service
echo "RemainAfterExit=yes" >> /etc/systemd/system/openvas.service
echo -e "\n" >> /etc/systemd/system/openvas.service
echo "[Install]" >> /etc/systemd/system/openvas.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/openvas.service

echo "[Unit]" > /etc/systemd/system/gvm.service
echo "Description=Control the OpenVAS GVM service" >> /etc/systemd/system/gvm.service
echo "After=openvas.service" >> /etc/systemd/system/gvm.service
echo -e "\n" >> /etc/systemd/system/gvm.service
echo "[Service]" >> /etc/systemd/system/gvm.service
echo "Type=simple" >> /etc/systemd/system/gvm.service
echo "User=gvm" >> /etc/systemd/system/gvm.service
echo "Group=gvm" >> /etc/systemd/system/gvm.service
echo "Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin" >> /etc/systemd/system/gvm.service
echo "Environment=PYTHONPATH=/opt/gvm/lib/python3.8/site-packages" >> /etc/systemd/system/gvm.service
echo -e "ExecStart=/opt/gvm/sbin/gvmd --osp-vt-update=/opt/gvm/var/run/ospd.sock" >> /etc/systemd/system/gvm.service
echo "RemainAfterExit=yes" >> /etc/systemd/system/gvm.service
echo -e "\n" >> /etc/systemd/system/gvm.service
echo "[Install]" >> /etc/systemd/system/gvm.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/gvm.service

echo "[Unit]" > /etc/systemd/system/gvm.path
echo "Description=Start the OpenVAS GVM service when opsd.sock is available" >> /etc/systemd/system/gvm.path
echo -e "\n" >> /etc/systemd/system/gvm.path
echo "[Path]" >> /etc/systemd/system/gvm.path
echo "PathChanged=/opt/gvm/var/run/ospd.sock" >> /etc/systemd/system/gvm.path
echo "Unit=gvm.service" >> /etc/systemd/system/gvm.path
echo -e "\n" >> /etc/systemd/system/gvm.path
echo "[Install]" >> /etc/systemd/system/gvm.path
echo "WantedBy=multi-user.target" >> /etc/systemd/system/gvm.path

echo "[Unit]" > /etc/systemd/system/gsa.service
echo "Description=Control the OpenVAS GSA service" >> /etc/systemd/system/gsa.service
echo "After=openvas.service" >> /etc/systemd/system/gsa.service
echo -e "\n" >> /etc/systemd/system/gsa.service
echo "[Service]" >> /etc/systemd/system/gsa.service
echo "Type=simple" >> /etc/systemd/system/gsa.service
echo "User=gvm" >> /etc/systemd/system/gsa.service
echo "Group=gvm" >> /etc/systemd/system/gsa.service
echo "Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin" >> /etc/systemd/system/gsa.service
echo "Environment=PYTHONPATH=/opt/gvm/lib/python3.8/site-packages" >> /etc/systemd/system/gsa.service
echo -e "ExecStart=/usr/bin/sudo /opt/gvm/sbin/gsad" >> /etc/systemd/system/gsa.service
echo "RemainAfterExit=yes" >> /etc/systemd/system/gsa.service
echo -e "\n" >> /etc/systemd/system/gsa.service
echo "[Install]" >> /etc/systemd/system/gsa.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/gsa.service

echo "[Unit]" > /etc/systemd/system/gsa.path
echo "Description=Start the OpenVAS GSA service when gvmd.sock is available" >> /etc/systemd/system/gsa.path
echo -e "\n" >> /etc/systemd/system/gsa.path
echo "[Path]" >> /etc/systemd/system/gsa.path
echo "PathChanged=/opt/gvm/var/run/gvmd.sock" >> /etc/systemd/system/gsa.path
echo "Unit=gsa.service" >> /etc/systemd/system/gsa.path
echo -e "\n" >> /etc/systemd/system/gsa.path
echo "[Install]" >> /etc/systemd/system/gsa.path
echo "WantedBy=multi-user.target" >> /etc/systemd/system/gsa.path


systemctl daemon-reload
systemctl enable --now openvas
systemctl enable --now gvm.{path,service}
systemctl enable --now gsa.{path,service}


# REMIND USER TO CHANGE DEFAULT PASSWORD
echo "The installation is done, but there may still be an update in progress."
echo "Please be patient if you aren't able to log in at first."
echo "Username is gvmadmin and pasword is StrongPass"
echo "Remember to change this default password"
echo "sudo -Hiu gvm gvmd --user=gvmadmin --new-password=<PASSWORD>"

#!/bin/bash

# Update GVM CERT and SCAP data from the feed servers
su gvm -c "touch /opt/gvm/feed.sh"
su gvm -c "chmod u+x /opt/gvm/feed.sh"

sudo -Hiu gvm echo "echo Sleeping 5 minutes" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "sleep 300" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh # allow a NAT connection to close
sudo -Hiu gvm echo "sed -i '368isleep 120' /opt/gvm/sbin/greenbone-scapdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo Sleeping 2 minutes" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "greenbone-scapdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo Sleeping 5 minutes" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "echo More info can be found by searching greenbone-nvt-sync rsync connection refused on Google" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
sudo -Hiu gvm echo "sleep 300" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh # allow a NAT connection to close
sudo -Hiu gvm echo "greenbone-certdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh
# Add sleep to future greenbone-certdata-sync calls (https://github.com/yu210148/gvm_install/issues/2 --Thanks kirk56k)
sudo -Hiu gvm echo "sed -i '349isleep 300' /opt/gvm/sbin/greenbone-certdata-sync" | sudo -Hiu gvm tee -a /opt/gvm/feed.sh

su gvm -c "/opt/gvm/feed.sh"
su gvm -c "rm /opt/gvm/feed.sh"

#!/bin/bash
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


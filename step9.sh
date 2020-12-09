#!/bin/bash

# Start OpenVAS Scanner, GSA and GVM services
# Start OpenVAS
su gvm -c "touch /opt/gvm/start.sh"
su gvm -c "chmod u+x /opt/gvm/start.sh"

ID=`grep ^ID /etc/os-release | sed 's/ID=//g'`
if [ $ID = "debian" ]; then
    sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python3.7/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/start.sh
else
    sudo -Hiu gvm echo "export PYTHONPATH=/opt/gvm/lib/python3.8/site-packages" | sudo -Hiu gvm tee -a /opt/gvm/start.sh
fi
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

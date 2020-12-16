#!/bin/bash
# Create GVM Scanner
su gvm -c "touch /opt/gvm/scan.sh"
su gvm -c "chmod u+x /opt/gvm/scan.sh"
sudo -Hiu gvm echo -e "/opt/gvm/sbin/gvmd --create-scanner=\"Created OpenVAS Scanner\" --scanner-type=\"OpenVAS\" --scanner-host=/opt/gvm/var/run/ospd.sock" | sudo -Hiu gvm tee -a /opt/gvm/scan.sh

sudo -Hiu gvm echo "/opt/gvm/sbin/gvmd --get-scanners" | sudo -Hiu gvm tee -a /opt/gvm/scan.sh

# Verify newly created scanner
sudo -Hiu gvm echo -e "UUID=\$(/opt/gvm/sbin/gvmd --get-scanners | grep Created | awk '{print \$\1}')" | sed 's/\\//g' | sudo -Hiu gvm tee -a /opt/gvm/scan.sh

# Wait a moment then verify the scanner
sudo -Hiu gvm echo "sleep 10" | sudo -Hiu gvm tee -a /opt/gvm/scan.sh
sudo -Hiu gvm echo -e "/opt/gvm/sbin/gvmd --verify-scanner=UUID" | sed 's/UUID/\$UUID/g' | sudo -Hiu gvm tee -a /opt/gvm/scan.sh

# Create OpenVAS (GVM 11) Admin
sudo -Hiu gvm echo -e "/opt/gvm/sbin/gvmd --create-user gvmadmin --password=StrongPass" | sudo -Hiu gvm tee -a /opt/gvm/scan.sh

su gvm -c "/opt/gvm/scan.sh"
su gvm -c "rm /opt/gvm/scan.sh"

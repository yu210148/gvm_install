#!/bin/bash
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

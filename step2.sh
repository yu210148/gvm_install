#!/bin/bash

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

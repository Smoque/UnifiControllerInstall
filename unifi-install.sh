#!/bin/bash
## Install Unifi Controller on Debian 10/11 (Buster or BullsEye)
LST=/etc/apt/sources.list.d
RLS=`awk '/\(/,/\)/{sub(".*\(","");sub("\).*","");print}' /etc/os-release | uniq`

apt update && apt -y install curl gnupg mc

# Java 8
curl -fsSL https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | gpg --dearmor --yes -o /usr/share/keyrings/adoptopenjdk-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptopenjdk-archive-keyring.gpg] https://adoptopenjdk.jfrog.io/adoptopenjdk/deb $RLS main" | tee $LST/adoptopenjdk.list

# MongoDB 3.6
wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | apt-key add -
echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/3.6 main" | tee $LST/mongodb.list

# UniFi - fresh package
wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg
echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee $LST/unifi.list

# LibSSL 1.0
wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb

PKGs="adoptopenjdk-8-hotspot apt-transport-https mongodb-org-server ./libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb "

case $RLS in
    bullseye)
        wget http://ftp.us.debian.org/debian/pool/main/g/glibc/multiarch-support_2.28-10+deb10u1_amd64.deb
        PKGs+="./multiarch-support_2.28-10+deb10u1_amd64.deb unifi"
    ;;
    buster)
        wget https://dl.ui.com/unifi/5.14.23/unifi_sysvinit_all.deb
        PKGs+="multiarch-support ./unifi_sysvinit_all.deb"
    ;;
esac

apt update && apt -y install $PKGs
apt -y dist-upgrade

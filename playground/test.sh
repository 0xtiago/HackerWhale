#!/bin/bash

apt update



echo "[+] Amass"
go install -v github.com/owasp-amass/amass/v4/...@master


echo "[+] Apache"
apt install apache2 -y
apachectl -v
systemctl start apache2
curl -I http://localhost

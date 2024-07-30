#!/bin/bash

sudo apt update



echo "[+] Amass"
go install -v github.com/owasp-amass/amass/v4/...@master


echo "[+] Amass"
sudo apt install apache2 -y
apachectl -v
sudo systemctl start apache2
curl -I http://localhost

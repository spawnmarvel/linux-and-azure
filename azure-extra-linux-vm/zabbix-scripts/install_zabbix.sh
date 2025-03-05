#!/bin/bash
# cp this to server, will prompt for sudo password on bash install.sh

# update vm
sudo apt update -y
sudo apt upgrade -y
# ok

# get zab, server, frontend, agent, mysql, apache all to localhost
# https://www.zabbix.com/download?zabbix=6.0&os_distribution=ubuntu&os_version=22.04&components=server_frontend_agent&db=mysql&ws=apache

wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo apt update -y
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

# remove
# sudo apt purge zabbix-server-mysql zabbix-frontend-php  zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

echo "Install Zabbix server, frontend, agent successfully"


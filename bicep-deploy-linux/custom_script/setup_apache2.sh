#!/bin/bash
echo "Installing Apache..."
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
echo "Apache installed and running!" > /var/www/html/index.html


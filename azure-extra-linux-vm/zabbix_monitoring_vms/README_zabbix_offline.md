# Zabbix offline

# Misc

https://www.zabbix.com/forum/zabbix-help/360543-server-offline-installation

https://www.reddit.com/r/zabbix/comments/1ii5jyz/offline_installation/


# Install MySQL offline

Do test and get to know it.

# Temp

Installing Zabbix and MySQL (or MariaDB) offline on Ubuntu requires you to manually download all necessary .deb packages and their dependencies on a machine with internet access, transfer them, and then install them on the offline server.
The core steps are:

1. ⚙️ Prepare for Offline Installation
You need a temporary machine (with internet access) running the same version of Ubuntu as your target offline server.
 * Download Zabbix Repository Package: The official Zabbix repository is not included by default. Download the appropriate Zabbix release package (.deb file) for your Ubuntu version. You can find this on the Zabbix website under "Zabbix Packages" by selecting your Ubuntu version and choosing the "Repository" step.
   Example for Zabbix 7.0 on Ubuntu 22.04:
   wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb

 * Gather Package Dependencies (Crucial Step): You need the Zabbix packages (server, frontend, agent, SQL scripts) and MySQL/MariaDB packages, plus all their dependencies.
   * Install apt-rdepends:
     sudo apt update
sudo apt install apt-rdepends -y

   * Generate a list of all required packages: You'll need the core Zabbix packages and the database. The most common setup is: zabbix-server-mysql, zabbix-frontend-php, zabbix-apache-conf (or zabbix-nginx-conf), zabbix-agent, and mariadb-server (or mysql-server).
     # Replace the package list with your actual target packages
apt-rdepends zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf mariadb-server | awk '/^ / {print $1}' | sort -u > zabbix_deps.txt

   * Download the packages:
     sudo apt install --download-only $(cat zabbix_deps.txt)

 * Collect the Files: The downloaded .deb files will be in /var/cache/apt/archives/. Copy the zabbix-release_*.deb file and all the .deb files from /var/cache/apt/archives/ onto a USB drive or shared location.

2. 💾 Install on the Offline Server
Transfer the collected .deb files (and the Zabbix repository .deb) to a single directory on your offline Ubuntu server (e.g., ~/zabbix_offline_install/).
 * Install Zabbix Repository Package: This simply adds the repo information, but since you are offline, you must manually install the other packages.
   sudo dpkg -i zabbix-release_*.deb

 * Install all Downloaded Packages: Use dpkg to install all .deb files simultaneously. The --ignore-depends flag might be necessary for some dependency loop issues, but generally, you want to install them all at once to resolve dependencies you've gathered.
   sudo dpkg -i --recursive ~/zabbix_offline_install/
# If the above fails due to missing dependencies, try to force install and fix:
# sudo dpkg -i --force-depends ~/zabbix_offline_install/*.deb
# sudo apt-get install -f # This won't work offline unless all dependencies were installed by the previous step

3. 🛠️ Configure the Database
After the packages are installed, you need to configure MariaDB/MySQL and Zabbix.
 * Start and Secure MariaDB/MySQL:
   sudo systemctl start mariadb # or mysql
sudo systemctl enable mariadb # or mysql
# Optional: sudo mysql_secure_installation

 * Create Zabbix Database and User: Log into the MySQL/MariaDB shell and create the database and user.
   sudo mysql -u root -p # Log in
# In the MySQL shell:
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
FLUSH PRIVILEGES;
QUIT;

 * Import Initial Zabbix Schema: Import the initial database schema from the installed Zabbix SQL script.
   sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -u zabbix -p zabbix
# Enter 'your_secure_password' when prompted

4. 🚀 Final Zabbix Configuration
 * Edit Zabbix Server Configuration: Edit the server configuration file (/etc/zabbix/zabbix_server.conf) to set the database password.
   sudo nano /etc/zabbix/zabbix_server.conf

   Uncomment and set:
   DBPassword=your_secure_password

 * Start Services:
   sudo systemctl restart zabbix-server
sudo systemctl enable zabbix-server
sudo systemctl enable apache2 # or nginx/php-fpm if you used those

The final step for the frontend is typically accessing the web interface (e.g., http://your_server_ip/zabbix) to complete the setup wizard, which only requires a web browser connection to the local server, not the internet.
You may find this video useful for a complete walkthrough of Installing and Configuring Zabbix 7.4 on Ubuntu 22.04 LTS with MySQL Database Complete Step by Step Guide, although it covers an online installation, the subsequent configuration steps are the same.
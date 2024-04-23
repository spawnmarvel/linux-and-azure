#!/bin/bash
# mariadb
sudo apt install mariadb-server mariadb-client -y

# Make it start at system boot.
sudo systemctl enable --now mariadb
# sudo service mariadb status

# secure it
# sudo mysql_secure_installation

# or run it manually
# https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script

# Make sure that NOBODY can access the server without a password
# sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('CHANGEME') WHERE User = 'root'"
# Kill the anonymous users
# sudo mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
# sudo mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
# sudo mysql -e "DROP DATABASE test"
# Make our changes take effect
# sudo mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
sudo mysql_secure_installation <<EOF

n
n
n
y
y
y
y
EOF


echo "Mariadb successfully created!"

# remove
# sudo apt remove --purge mariadb* -y
# sudo apt autoremove -y
# sudo apt autoclean -y
	
    
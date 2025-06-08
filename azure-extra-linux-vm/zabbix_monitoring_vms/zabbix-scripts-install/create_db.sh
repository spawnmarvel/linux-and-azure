#!/bin/bash
echo "Trying to create database"
# https://qirolab.com/snippets/91745c6b-e4b0-4c7f-846f-c00347bdc7d0


dbname="zabbix"
username="johndee"
input="keys.txt"
declare -a arr=()
result=""
while IFS= read -r line
do
  echo "$line"
  result+=("$line")
done < "$input"
echo "$result"
userpass="$result"
echo "$dbname $username $userpass"

# the --execute (or -e) option can be used with mysql to pass one or more semicolon-separated SQL statements to the server.
echo "Creating new database..."
sudo mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8mb4 collate utf8mb4_bin */;"
sudo mysql -e "SHOW DATABASES";
echo "Database done..."

echo "Creating new user.."
sudo mysql -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
echo "User done..."

echo "Granting ALL privileges on $dbname to $username"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
echo "Grant done..."

echo " Show grants..."
sudo mysql -e "SHOW GRANTS FOR '${username}'@'localhost';"

sudo mysql -e "set global log_bin_trust_function_creators = 1;"
sudo mysql -e "quit;"

# now import the schema

# show stuff and verify
# mysql show character set like '%utf8%
# mysql use zabbix;
# mysql show variables like "character_set_database";
# mysql SELECT SCHEMA_NAME 'database', default_character_set_name 'charset', DEFAULT_COLLATION_NAME 'collation' FROM information_schema.SCHEMATA;

# delete for queick test script again
# DROP DATABASE zabbix;
# DROP USER 'johndee'@'localhost';
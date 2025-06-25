# Security

## Understanding Apache Config Files

- **sites-enabled/** contains symlinks (shortcuts) to the actual configuration files in **sites-available/**.
- You generally **edit the configuration files in sites-available/**. 

Changes are reflected in sites-enabled/ because of the symlinks.

If you change the certificate file names or locations, **edit the virtual host configuration file** (usually in /etc/apache2/sites-available/).

- You do **not** need to edit anything in sites-enabled/.

## Openssl CSR

```bash
sudo apt update

# 1. Install OpenSSL (if not already installed)
openssl version
# or
sudo apt install openssl

# 2. Generate a Private Key
openssl genrsa -out mysite.local.key 4096

# 3. Generate the CSR
openssl req -new -key mysite.local.key -out mydomain.csr

Country Name (2 letter code): The two-letter country code where your organization is legally located.
State or Province Name (full name): The state or province where your organization is located.
Locality Name (eg, city): The city where your organization is located.
Organization Name (eg, company): The legally registered name of your organization/company.
Organizational Unit Name (eg, section): The division of your organization handling the certificate.
Common Name (e.g. server FQDN or YOUR name): The fully qualified domain name (FQDN) for your server. In your case, you would enter mysite.local.
Email Address: An email address where you can be contacted.
A challenge password & optional company name: You can leave these blank for a CSR.
Review the CSR:

# Once you have generated the CSR, you may want to review it to ensure all information is correct.
# This command will display the contents of the CSR in a human-readable format.
openssl req -text -noout -verify -in mydomain.csr

# Submit the CSR:
# For a private domain like mysite.local, you would typically use a self-signed certificate or a private Certificate Authority (CA) since public CAs cannot issue certificates for .local domains. 
# If you have a private CA, submit the CSR to your CA according to their process.

```
## Openssl self signed from CSR (above)

```bash
# Create a self-signed certificate (if not using a CA):
# If you're using the certificate for internal purposes and do not have a private CA, you can create a self-signed certificate with the following command:

openssl x509 -signkey mysite.local.key -in mydomain.csr -req -days 365 -out mydomain.crt
# This will create a certificate file named mysite.local.crt that is valid for 365 days.

```

https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/ubuntu_csr.sh

## Setting up SSL for Zabbix frontend Apache

Other than setting your web frontend URL within Zabbix to https://, ignore zabbix for this task.

Treat it as enabling SSL for apache.

Digital Ocean start

https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-18-04


```bash
# If we use a new cert and continue from above were we generated a key, csr and a selfsigned crt

# copy
sudo cp mysite.local.key /etc/ssl/private/mysite.local.key
sudo cp mydomain.crt /etc/ssl/certs/mydomain.crt

# Tack a backup
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak

# Next, you’ll modify /etc/apache2/sites-available/default-ssl.conf
sudo nano /etc/apache2/sites-available/default-ssl.conf

# Edit
# SSLEngine on
# SSLCertificateFile      /etc/ssl/certs/mydomain.crt
# SSLCertificateKeyFile   /etc/ssl/private/mysite.local.key

# Enable the SSL Module and the Site
sudo a2enmod ssl
sudo a2ensite default-ssl.conf

# Check for syntax errors:
sudo apachectl configtest

# Restart apache2
sudo systemctl restart apache2
sudo systemctl status apache2
```

Verify

https://mydomain/zabbix/zabbix.php?action=dashboard.view

View cert

![cert one](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/https.jpg)

## Renew cert

```bash

# 2. Generate a Private Key
openssl genrsa -out renew_mysite.local.key 4096

# 3. Generate the CSR
openssl req -new -key renew_mysite.local.key -out renew_mydomain.csr

# Once you have generated the CSR, you may want to review it to ensure all information is correct.
# This command will display the contents of the CSR in a human-readable format.
openssl req -text -noout -verify -in renew_mydomain.csr

# Submit the CSR:
# For a private domain like mysite.local, you would typically use a self-signed certificate or a private Certificate Authority (CA) since public CAs cannot issue certificates for .local domains. 
# If you have a private CA, submit the CSR to your CA according to their process.

# Create a self-signed certificate (if not using a CA):
# If you're using the certificate for internal purposes and do not have a private CA, you can create a self-signed certificate with the following command:

openssl x509 -signkey renew_mysite.local.key -in renew_mydomain.csr -req -days 730 -out renew_mydomain.crt
# This will create a certificate file named mysite.local.crt that is valid for 730 days.

# copy
# Tip:** Overwrite the old files with the new ones if you used those filenames in your Apache config. 
# If you change the file names, update the paths in your Apache config as described in the previous answer.
sudo cp renew_mysite.local.key /etc/ssl/private/mysite.local.key
sudo cp renew_mydomain.crt /etc/ssl/certs/mydomain.crt

# Reload or restart Apache so it picks up the new certificate:
sudo systemctl reload apache2
# or
sudo systemctl restart apache2
```

![cert renew](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/https2.jpg)


## To automatically redirect all HTTP traffic to HTTPS in Apache2, you need to update your Apache configuration. Here’s a straightforward way to do it:



```bash
# ## 1. **Enable the Rewrite Module**
sudo a2enmod rewrite
sudo systemctl reload apache2

# ## 2. **Edit Your HTTP Virtual Host**
sudo nano /etc/apache2/sites-available/000-default.conf
```

```ini
# <VirtualHost *:80>

    ServerName yourdomain.com
    ServerAlias www.yourdomain.com

    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# </VirtualHost>

```

```bash
# Test it
sudo apachectl configtest

# Reload
sudo systemctl reload apache2
```


http://mydomain/zabbix/zabbix.php?action=dashboard.view should go to https://mydomain/zabbix/zabbix.php?action=dashboard.view
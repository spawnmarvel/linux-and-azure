# Security

## Openssl self signed

Extra linux vm public or private cert, since public CAs cannot issue certificates for .local domains. 

```bash
sudo apt update

sudo apt install openssl

openssl genrsa -out mysite.local.key 4096
# This will create a file named mysite.local.key which is your private key. Keep this file secure and private.

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
openssl req -text -noout -verify -in mysite.local.csr
# This command will display the contents of the CSR in a human-readable format.

# Submit the CSR:
# For a private domain like mysite.local, you would typically use a self-signed certificate or a private Certificate Authority (CA) since public CAs cannot issue certificates for .local domains. 
# If you have a private CA, submit the CSR to your CA according to their process.

# Create a self-signed certificate (if not using a CA):
# If you're using the certificate for internal purposes and do not have a private CA, you can create a self-signed certificate with the following command:

openssl x509 -signkey mysite.local.key -in mysite.local.csr -req -days 365 -out mysite.local.crt
# This will create a certificate file named mysite.local.crt that is valid for 365 days.

# Remember to replace mysite.local with your actual private domain name, and make sure to store your private key and CSR in a secure location. The private key should never be shared or transmitted insecurely.
```

https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/ubuntu_csr.sh

## Setting up SSL for Zabbix frontend Apache

Other than setting your web frontend URL within Zabbix to https://, ignore zabbix for this task.

Treat it as enabling SSL for apache.

Digital Ocean start

https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-18-04

```bash

# from clean install with http
http://server_domain_or_IP
# to

# Step 1 — Creating the SSL Certificate
openssl version
OpenSSL 1.1.1f  31 Mar 2020

openssl req -new -newkey rsa:2048 -nodes -keyout server01.domain.net.key -out server01.domain.net.csr

# CN = server01.domain.net

# Step 2 — Configuring Apache to Use SSL
# Creating an Apache Configuration Snippet with Strong Encryption Settings
# sudo nano /etc/apache2/conf-available/ssl-params.conf
# HTTP Strict Transport Security, or HSTS, can do that in config

# Next, you’ll modify /etc/apache2/sites-available/default-ssl.conf
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak

sudo nano /etc/apache2/sites-available/default-ssl.conf

<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerAdmin your_email@example.com
                ServerName server01.domain.net

                DocumentRoot /var/www/html

                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

                SSLEngine on

                SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
                SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>

        </VirtualHost>
</IfModule>

# Step 3 — Adjusting the Firewall
# If you have the ufw firewall enabled, as recommended by the prerequisite guides, you might need to adjust the settings to allow for SSL traffic.

# Step 4 — Enabling the Changes in Apache

# Enable mod_ssl, the Apache SSL module, and mod_headers, which is needed by some of the settings in the SSL snippet, with the a2enmod command
sudo a2enmod ssl
# sudo a2enmod headers

# Next, enable your SSL Virtual Host with the a2ensite command:
sudo a2ensite default-ssl

# You’ll also need to enable your ssl-params.conf file, to read in the values you set:
# sudo a2enconf ssl-params

# Check to make sure that there are no syntax errors in your files with a test:
sudo apache2ctl configtest

# If your output has Syntax OK in it
sudo systemctl restart apache2

# Step 5 — Testing Encryption
# https://server_domain_or_IP

# when https works

# To adjust the unencrypted Virtual Host file to redirect all traffic to be SSL encrypted, open the /etc/apache2/sites-available/000-default.conf file:
cd /etc/apache2/sites-available

sudo cp 000-default.conf 000-default.conf.bak

sudo nano /etc/apache2/sites-available/000-default.conf

<VirtualHost *:80>
        . . .

        Redirect "/" "https://server01.domain.net/zabbix"

        . . .
</VirtualHost>


# Check to make sure that there are no syntax errors in your files with a test:
sudo apache2ctl configtest

# If your output has Syntax OK in it
sudo systemctl restart apache2


# http://server_domain_or_IP should redirect to https://server_domain_or_IP

```

Digital Ocean end

Next

```bash

# I installed SSL on Zabbix 6 on Ubuntu 20.04.6 LTS by doing the following:
# 1- Backup Apache Configuration: Before making any changes, make sure to back up your current Apache configuration.

sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak

# 2- Install SSL Module: Make sure you have the SSL module installed.

sudo a2enmod ssl

# 3- Copy Certificate and Key Files: Place your .crt and .key files in the appropriate directories (usually /etc/ssl/certs/ for the certificate and /etc/ssl/private/ for the key).

sudo cp /path/to/your_certificate.crt /etc/ssl/certs/

sudo cp /path/to/your_private.key /etc/ssl/private/

# 4- Update Apache Configuration: Edit your Apache configuration file 
# (/etc/apache2/sites-available/000-default.conf) to include the path to your SSL certificate and key. Your configuration should include something like this:

<VirtualHost *:443>

ServerName your-zabbix-server-name

SSLEngine on

SSLCertificateFile /etc/ssl/certs/your_certificate.crt

SSLCertificateKeyFile /etc/ssl/private/your_private.key

DocumentRoot /usr/share/zabbix

<Directory "/usr/share/zabbix">

Options FollowSymLinks

AllowOverride None

Require all granted

</Directory>

</VirtualHost>

# Make sure to replace your-zabbix-server-name, your_certificate.crt, and your_private.key with your actual server name and certificate files.

# 5- Restart Apache: Restart the Apache service for changes to take effect.

sudo systemctl restart apache2
```

https://www.reddit.com/r/zabbix/comments/10atj1t/how_to_configure_ssl_on_ubuntu/?rdt=62317



Follow e-lo public cert and domain

```bash

openssl req -new -newkey rsa:2048 -nodes -keyout yourdomain.key -out yourdomain.csr

# Replace yourdomain with the domain name you’re securing. For example, if your domain name is coolexample.com, you would type coolexample.key and coolexample.csr.

# Open the CSR in a text editor and copy all of the text.

# Paste the full CSR into the SSL enrollment form in your account.

# backup files first

<VirtualHost 172.xx.x.xx:443>
    DocumentRoot /var/www/html2
    ServerName www.yourdomain.com
        SSLEngine on
        SSLCertificateFile /path/to/your_domain_name.crt
        SSLCertificateKeyFile /path/to/your_private.key
        SSLCertificateChainFile /path/to/DigiCertCA.crt
    </VirtualHost>

# Now test it

apachectl configtest

apachectl stop
apachectl start
```

https://follow-e-lo.com/2023/11/02/apache-generate-csr-certificate-signing-request/

Enabling Zabbix on root directory of URL

Enabling HTTP Strict Transport Security (HSTS) on the web server

https://www.zabbix.com/documentation/current/en/manual/installation/requirements/best_practices


Example with local domain on apache for wordpress:

mydomain.private.local

```bash

/etc/apache2/sites-enabled

wordpress.conf

sudo cp wordpress.conf wordpress.conf_bck

ls

wordpress.conf  wordpress.conf_bck

cd

sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/mydomain.private.local.key -out /etc/ssl/certs/mydomain.private.local.crt

# [...]
Common Name (e.g. server FQDN or YOUR name) []:mydomain.private.local

pwd
/etc/ssl/certs
openssl x509 -in mydomain.private.local.crt -text -noout

sudo nano  wordpress.conf
```
edit conf

```yml
<VirtualHost *:80>
ServerAdmin admin@example.com
DocumentRoot /var/www/html/wordpress
ServerName 172.xx.x.xx
ServerAlias mydomain.private.local
Redirect / https://172.xx.x.xx

  <Directory var/www/html/wordpress>
    Options FollowSymLinks
    AllowOverride All
    Require all granted
   </Directory>
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:443>
   ServerName 172.xx.x.xx
   DocumentRoot /var/www/html/wordpress

   <Directory /var/www/html/wordpress/>
    Options FollowSymLinks
    AllowOverride All
    Require all granted
   </Directory>

   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/mydomain.private.local.crt
   SSLCertificateKeyFile /etc/ssl/private/mydomain.private.local.key
</VirtualHost>
```
check it

```bash
sudo apache2ctl configtest

sudo service apache2 restart

sudo service apache2 status

# visit
https://mydomain.private.local

```
default-ssl.conf

```bash
# apache2

cd /etc/apache2/sites-enabled

000-default.conf  default-ssl.conf

cat default-ssl.conf

<IfModule mod_ssl.c>
  <VirtualHost *:8443>
   Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"
   </VirtualHost>
    <VirtualHost _default_:443>
      ServerAdmin webmaster@localhost
                # FQDN
                ServerName vm01.domain.com
                ServerAlias alias.domain.com
                DocumentRoot /var/www/html
			SSLEngine on
        SSLCertificateFile      /etc/ssl/certs/alias.pem
        SSLCertificateKeyFile /etc/ssl/private/alias.pem.key
				<FilesMatch "\.(cgi|shtml|phtml|php)$">
            SSLOptions +StdEnvVars
        </FilesMatch>
          <Directory /usr/lib/cgi-bin>
              SSLOptions +StdEnvVars
          </Directory>
	Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"
 </VirtualHost>
</IfModule>
```

## Encryption

"PSK is an efficient way, and to be honest you get the same effect, [...] (like, cert management is a hustle compared to psk)."

https://www.reddit.com/r/zabbix/comments/srp2fx/setup_cert_encryption_on_zabbix_agent/?rdt=50737

First, generate a PSK

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-zabbix-to-securely-monitor-remote-servers-on-ubuntu-20-04
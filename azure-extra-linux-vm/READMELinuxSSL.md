# Ubuntu SSL

In most cases, OpenSSL is installed by default on all Linux distributions. It is required for basic web navigation and system updates, so a fresh Linux installation comes with it most of the time, and there is nothing to do.

## Canonical Apache tutorial


1 Overview

2 Install and Configure Apache

```bash

sudo apt update -y
sudo apt upgrade -y

sudo apt install apache2
# After letting the command run, all required packages are installed and we can test it out.
# Type in our IP address for the web server.
# Open HTTP if ufw is enabled and open NSG inbound HTTP

```
![Apache home ](https://github.com/spawnmarvel/linux-and-azure/tree/main/images/apache.jpg)

3 Creating Your Own Website

* By default, Apache comes with a basic site (the one that we saw in the previous step) enabled. 
* We can modify its content in /var/www/html or settings by editing its Virtual Host file found in 
* /etc/apache2/sites-enabled/000-default.conf.
* We can modify how Apache handles incoming requests and have multiple sites running on the same server by editing its Virtual Hosts file.
* Today, we’re going to leave the default Apache virtual host configuration pointing to www.example.com and set up our own at gci.example.com.

```bash
# Let’s start by creating a folder for our new website in /var/www/ by running
sudo mkdir /var/www/gci/

# We have it named gci here but any name will work, as long as we point to it in the virtual hosts configuration file later.

# Lets have an HTML file in it
cd /var/www/gci/
sudo nano index.html

<html>
<head>
  <title> Ubuntu server! </title>
</head>
<body>
  <p> Test ubuntu </p>
</body>
</html>

# Now let’s create a VirtualHost file so it’ll show up when we type in gci.example.com
```

4 Setting up the VirtualHost Configuration File

```bash
# We start this step by going into the configuration files directory:
cd /etc/apache2/sites-available/

# Since Apache came with a default VirtualHost file, let’s use that as a base. 
# (gci.conf is used here to match our subdomain name):
sudo cp 000-default.conf gci.conf

# Edit the file we just copied
sudo nano gci.conf

# We should have our email in ServerAdmin so users can reach you in case Apache experiences any error:
ServerAdmin yourname@example.com

# We also want the DocumentRoot directive to point to the directory our site files are hosted on:
# Default DocumentRoot /var/www/html
DocumentRoot /var/www/gci/

# The default file doesn’t come with a ServerName directive so we’ll have to add and define it by adding this line below the last directive:
ServerName DNS name found in Azure
# This ensures people reach the right site instead of the default one when they type in gci.example.com.

# Now that we’re done configuring our site, let’s save and activate it in the next step!
```

5 Activating VirtualHost file

```bash
# Now that we’re done configuring our site, let’s save and activate it in the next step!
sudo a2ensite gci.conf
# Next, let’s test for configuration errors:
sudo apache2ctl configtest
Syntax OK

# Load the new site
sudo service apache2 reload

# Enable at boot
sudo systemctl enable apache2

```
![Apache app new ](https://github.com/spawnmarvel/linux-and-azure/tree/main/images/apacheapp.jpg)

Logic and configuration 
* We have it named gci here but any name will work, as long as we point to it in the virtual hosts configuration file later.
* The default file doesn’t come with a ServerName directive so we’ll have to add and define it by adding this line below the last directive:
* ServerName DNS name found in Azure
* This ensures people reach the right site instead of the default one when they type in gci.example.com.

```bash
# Our web folder and file
/var/www/gci/index.html

# gci.conf and the pointer to the file and URL in this case hostname.domain.com
DocumentRoot /var/www/gci/
ServerName DNS name found in Azure
```

http://public-ip

http://hostname.azure.public.dnz.com


![Apache config ](https://github.com/spawnmarvel/linux-and-azure/tree/main/images/configapache.jpg)

https://ubuntu.com/tutorials/install-and-configure-apache#1-overview


## Canonical Apache2 SSL

https://wiki.ubuntu.com/Apache2_SSL?_ga=2.61205932.1848246698.1693898708-957078067.1693898708

## Apache DocumentRoot

The DocumentRoot is the top-level directory in the document tree visible from the web and this directive sets the directory in the configuration from which Apache2 or HTTPD looks for and serves web files from the requested URL to the document root.

* DocumentRoot "/var/www/html"
* then access to http://domain.com/index.html refers to /var/www/html/index.html. The DocumentRoot should be described without a trailing slash.

https://www.tecmint.com/find-apache-documentroot-in-linux/


## Canonical Apache tutorial SSL for /var/www/gci

Now let's configure SSL for the above app.
Let's take a snaphot of the OS drive before we do that, HTTP configuration.

![Snapshot ](https://github.com/spawnmarvel/linux-and-azure/tree/main/images/snapshot.jpg)

```bash
sudo apt update
sudo apt upgrade -y

# List avaliable rules
sudo ufw app list
# Add rules
sudo ufw allow OpenSSH
sudo ufw allow "Apache Full"
# Enable FW
sudo ufw enable
sudo ufw status

```

Step 1 — Enabling mod_ssl
```bash
# Before we can use any SSL certificates, we first have to enable mod_ssl
# an Apache module that provides support for SSL encryption.
# Enable mod_ssl with the a2enmod command:

sudo a2enmod ssl

# Activate module
sudo systemctl restart apache2

sudo service apache2 status

# Enable at boot
sudo systemctl enable apache2

```
Go to http://ip

Go to http://your_domain.uksouth.cloudapp.azure.com/

![Apache home ](https://github.com/spawnmarvel/linux-and-azure/tree/main/images/apache.jpg)

Step 2 creating the SSL Certificate

We will use our CA server

https://github.com/spawnmarvel/quickguides/blob/main/securityPKI-CA/README.md

```bash
# Get FQDN
hostname

```
Now create the certificate on the CA server

```bash
# cmd on CA server
# Generating RSA private key
openssl genrsa -out c:\testca\server5\private_key.pem 2048

# Generating request
openssl req -new -key c:\testca\server5\private_key.pem -out c:\testca\server5\req.pem -outform PEM -subj /CN=hostname  -nodes

# add config to v3_ca for SAN https://stackoverflow.com/questions/21488845/how-can-i-generate-a-self-signed-certificate-with-subjectaltname-using-openssl

# Server and client extension using new config openssl2.cnf
openssl ca -config c:\testca\openssl2.cnf -in c:\testca\server5\req.pem -out c:\testca\server5\server5_certificate.pem -notext -batch

# Using configuration from c:\testca\openssl2.cnf
# Check that the request matches the signature
# Signature ok
# The Subject's Distinguished Name is as follows
# commonName            :ASN.1 12:'hostname'
# Certificate is to be certified until Sep  3 18:11:57 2033 GMT (3652 days)

openssl x509 -noout -subject -in c:\testca\server5\server5_certificate.pem
# subject=CN = hostname
# TBD v3-ca
# openssl x509 -noout -ext subjectAltName -in c:\testca\server5\server5_certificate.pem

# CP files you created to appropriate subdirectories under /etc/ssl on the host that will be using the certificate
/etc/ssl/certs
sudo nano server5_certificate.pem
sudo cp server5_certificate.pem /etc/ssl/certs/server5_certificate.pem

# save the key local and move it
sudo nano private_key.pem
sudo cp private_key.pem /etc/ssl/private/private_key.pem

# copy the root cert
sudo nano ca_certificate.pem
sudo cp ca_certificate.pem /etc/ssl/certs/ca_certificate.pem

# Go the configs
/etc/apache2/sites-available
ls
000-default.conf  default-ssl.conf  gci.conf
# Cp the default ssl to a new
cp default-ssl.conf ssl-gci.conf

# Add the same content as in gci and the cert path
ServerName DNS name found in Azure
DocumentRoot /var/www/gci
SSLCertificateFile      /etc/ssl/certs/server5_certificate.pem
SSLCertificateKeyFile /etc/ssl/private/private_key.pem
SSLCACertificateFile /etc/ssl/certs/ca_certificate.pem


sudo a2ensite ssl-gci.conf
sudo apache2ctl configtest

sudo systemctl reload apache2

cd etc/apache2/sites-enabled
ls
000-default.conf  gci.conf  ssl-gci.conf

```
Open NSG HTTPS

Done, you can now update all files in the \var\www\gci folder.

![Done ](https://github.com/spawnmarvel/linux-and-azure/tree/main/images/done.jpg)



Or you can use the tutorial from DO, if you do not have a CA

https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04


## Wordpress Install

Take a snap of the drive before install

It should just be to install it and then follow the small steps above for ssl

Take a snap of the drive when HTTP is ok

Start SSL stuff

## HTTPS for wordpress

* Self signed or really simple ssl plugin
* Lets encrypt, https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-ubuntu-18-04





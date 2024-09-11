# Security of Ubuntu

https://ubuntu.com/security

## Secure out of the box

All Canonical products are built with unrivalled security in mind — and tested to ensure they deliver it. Your Ubuntu software is secure from the moment you install it, and will remain so as Canonical ensures security updates are always available on Ubuntu first.

https://wiki.ubuntu.com/Security/Features?_ga=2.123208526.410884018.1726084309-710000309.1726084309&_gl=1*4vgeu4*_gcl_au*MTA1NjY4NzE3OC4xNzI2MDg0MzEw



## Hardening at scale

The default configuration of Ubuntu LTS releases balances between usability, performance and security. However, non general purpose systems can be further hardened to reduce their attack surface. Canonical provides certified tooling for automated audit and hardening. Comply with widely accepted industry hardening profiles, including CIS and DISA-STIG.

## Certified compliance

Canonical offers a range of tools to enable organisations to manage their desktop fleet and cloud with specific compliance requirements. A FIPS (Federal Information Processing Standard) certified version of Ubuntu is also available to comply to US government standards.


## How to Set Up a Firewall with UFW on Ubuntu


UFW, or Uncomplicated Firewall, is an interface to iptables that is geared towards simplifying the process of configuring a firewall. While iptables is a solid and flexible tool, it can be difficult for beginners to learn how to use it to properly configure a firewall. 

If you’re looking to get started securing your network, and you’re not sure which tool to use, UFW may be the right choice for you.

UFW is installed by default on Ubuntu.


### Step 1 — Making Sure IPv6 is Enabled

```bash

# In recent versions of Ubuntu, IPv6 is enabled by default
# Check it

cat /etc/default/ufw

IPV6=yes

```

### Step 2 — Setting Up Default Policies

If you’re just getting started with UFW, a good first step is to check your default firewall policies. These rules control how to handle traffic that does not explicitly match any other rules.

By default, UFW is set to deny all incoming connections and allow all outgoing connections.

To make sure you’ll be able to follow along with the rest of this tutorial, you’ll now set up your UFW default policies for incoming and outgoing traffic.

```bash
# To set the default UFW incoming policy to deny, run:

sudo ufw default deny incoming

Default incoming policy changed to 'deny'

# To set the default UFW outgoing policy to allow, run:


sudo ufw default allow outgoing

Default outgoing policy changed to 'allow'

```
These commands set the defaults to deny incoming and allow outgoing connections. These firewall defaults alone might suffice for a personal computer, but servers typically need to respond to incoming requests from outside users. We’ll look into that next.

### Step 3 — Allowing SSH Connections

If you were to enable your UFW firewall now, it would deny all incoming connections. This means that you’ll need to create rules that explicitly allow legitimate incoming connections — SSH or HTTP connections, for example — if you want your server to respond to those types of requests. 

If you’re using a cloud server, you will probably want to allow incoming SSH connections so you can connect to and manage your server.

```bash
# Allowing the OpenSSH UFW Application Profile

sudo ufw app list

Available applications:
  OpenSSH

# This will create firewall rules to allow all connections on port 22, which is the port that the SSH daemon listens on by default.

sudo ufw allow OpenSSH

Rules updated
Rules updated (v6)

# Alternative, Allowing SSH by Port Number

sudo ufw allow 22

```

### Step 4 — Enabling UFW

Your firewall should now be configured to allow SSH connections. To verify which rules were added so far, even when the firewall is still disabled, you can use:

```bash

sudo ufw show added

Added user rules (see 'ufw status' for running firewall):
ufw allow OpenSSH

# After confirming your have a rule to allow incoming SSH connections, you can enable the firewall with:

sudo ufw enable

Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup

# The firewall is now active. Run the sudo ufw status verbose command to see the rules that are set.

sudo ufw status verbose

Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp (OpenSSH)           ALLOW IN    Anywhere
22/tcp (OpenSSH (v6))      ALLOW IN    Anywhere (v6)

```

### Step 5 — Allowing Other Connections

```bash

sudo ufw allow http
# or
sudo ufw allow 80

udo ufw allow https
# or
sudo ufw allow 443

# Don’t forget to check which application profiles are available for your server with 

sudo ufw app list.

# Specific Port Ranges

sudo ufw allow 6000:6007/tcp

# Specific IP Addresses

sudo ufw allow from 203.0.113.4

# You can also specify a port that the IP address is allowed to connect to by adding to any port followed by the port number. 

sudo ufw allow from 203.0.113.4 to any port 22

# Subnets, If you want to allow a subnet of IP addresses, you can do so using CIDR notation to specify a netmask

sudo ufw allow from 203.0.113.0/24

# Likewise, you may also specify the destination port that the subnet 203.0.113.0/24 is allowed to connect to

sudo ufw allow from 203.0.113.0/24 to any port 22

# Connections to a Specific Network Interface
# View url used from digital ocean


```

###

```bash

```

https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu
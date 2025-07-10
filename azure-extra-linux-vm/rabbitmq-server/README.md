# How To Install and Start Using RabbitMQ on Ubuntu 24.04

## Install RabbitMQ


### Recommended option apt repositories on a Cloudsmith mirror

RabbitMQ is included in standard Debian and Ubuntu repositories. However, the versions included are many releases behind latest RabbitMQ releases and may provide RabbitMQ versions that are already out of support.

Currently, the recommended option for installing modern RabbitMQ on Debian and Ubuntu is using apt repositories on a Cloudsmith mirror (quick start script).

The repositories provide a modern version of Erlang. Alternatively, the latest version of Erlang is available via a Launchpad PPA and other repositories.

NOTE! This repository only provides amd64 (x86-64) Erlang packages. For amd64 (aarch64), this script must be modified to provision Erlang 26 from Launchpad.

Below is a shell snippet that performs the steps explained in this guide. It provisions RabbitMQ and Erlang from a Team RabbitMQ-hosted apt repository.

We use Ubuntu 24.04

```bash

#!/bin/sh

sudo apt-get install curl gnupg apt-transport-https -y

## Team RabbitMQ's main signing key
curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null
## Community mirror of Cloudsmith: modern Erlang repository
curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg > /dev/null
## Community mirror of Cloudsmith: RabbitMQ repository
curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg > /dev/null

## Add apt repositories maintained by Team RabbitMQ
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main

# another mirror for redundancy
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main

## Provides RabbitMQ
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main

# another mirror for redundancy
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main
EOF

## Update package indices
sudo apt-get update -y

## Install Erlang packages
sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

## Install rabbitmq-server and its dependencies
sudo apt-get install rabbitmq-server -y --fix-missing
```

https://www.rabbitmq.com/docs/install-debian#apt-quick-start-cloudsmith

Let make a new vm and test it.

Resource group Rg-ukamqp-0004, amqp04, login to proxy vm dummy01 and do ssh to 192.168.3.7

```bash
sudo nano install_rabbitmq.sh

# add the content from above script

bash install_rabbitmq.sh
```

Here are the steps and versions we got.


![installed versions](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/rabbitmq-server/images/install_amqp.jpg)


General install amqp https://www.rabbitmq.com/docs/install-debian#supported-distributions


## Enable RabbitMQ Management Console

```bash
sudo rabbitmq-plugins list

sudo rabbitmq-plugins enable rabbitmq_management
Enabling plugins on node rabbit@amqp04:
rabbitmq_management
The following plugins have been configured:
  rabbitmq_management
  rabbitmq_management_agent
  rabbitmq_web_dispatch
Applying plugin configuration to rabbit@amqp04...
The following plugins have been enabled:
  rabbitmq_management
  rabbitmq_management_agent
  rabbitmq_web_dispatch

```

Let's check curl on localhost:

```bash

curl -s http://localhost:15672 | grep -i "<title>"
    <title>RabbitMQ Management</title>

```
![curl management](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/rabbitmq-server/images/management.jpg)

Example Create a user since default user is default to localhost

```bash
# Only root or rabbitmq can run rabbitmqctl
sudo rabbitmqctl add_user kasparov amazing-805
sudo rabbitmqctl list_users
# Listing users ...
# user    tags
# guest   [administrator]
# kasparov 

sudo rabbitmqctl set_user_tags kasparov administrator
sudo rabbitmqctl list_users
# Listing users ...
# user    tags
# guest   [administrator]
# kasparov        [administrator]

sudo rabbitmqctl set_permissions -p / kasparov ".*" ".*" ".*"
sudo rabbitmqctl list_permissions
# Listing permissions for vhost "/" ...
# user    configure       write   read
# guest   .*      .*      .*
# kasparov        .*      .*      .*

```

Example Delete default user
```bash
sudo rabbitmqctl delete_user guest
sudo rabbitmqctl list_users
```


Example Create RabbitMQ Virtual Host, RabbitMQ manages user permissions on a virtual host level.

```bash
sudo rabbitmqctl add_vhost segment01
sudo rabbitmqctl list_vhosts
# Listing vhosts ...
# name
# segment01
# /
```

Example Set specific user permission for a user on the new vhost
```bash
sudo rabbitmqctl set_permissions -p <virtual_host> <user_name> <permissions>
# Example full permission
sudo rabbitmqctl set_permissions -p segment01 kasparov ".*" ".*" ".*"
```
Args
* -p is used to define the virtual host.
* The first permission argument “.*” grants configuration permissions on all virtual host entities. It allows you to declare exchanges, queues, etc.
* The second permission argument “.*” grants write permissions on all virtual host entities. It allows you to create bindings, publish messages etc.
* The third permission argument “.*” grants read permissions. It allows you to read queues, consume messages, etc.

```bash
sudo rabbitmqctl list_permissions
# Listing permissions for vhost "/" ...
# user    configure       write   read
# kasparov        .*      .*      .*
```

Get log and bin / exe
```bash
# Locate the binary, source, and manual pages for a command
whereis rabbitmq-server
rabbitmq-server: /usr/sbin/rabbitmq-server /usr/share/man/man8/rabbitmq-server.8.gz

# Identify and report the location of the provided executable
which rabbitmq-server
/usr/sbin/rabbitmq-server

# View path for log
sudo systemctl status rabbitmq-server
# Jun 28 16:52:05 amqp04 rabbitmq-server[750]:   Logs: /var/log/rabbitmq/rabbit@amqp04.log

# or
cd /var/log/rabbitmq
```
Path
```log
Jun 28 16:52:05 amqp04 rabbitmq-server[750]:   Logs: /var/log/rabbitmq/rabbit@amqp04.log
Jun 28 16:52:05 amqp04 rabbitmq-server[750]:         <stdout>
Jun 28 16:52:05 amqp04 rabbitmq-server[750]:   Config file(s): (none)
Jun 28 16:52:06 amqp04 rabbitmq-server[750]:   Starting broker... completed with 3 plugins.
```

Tail

```bash
sudo systemctl stop rabbitmq-server
sudo systemctl start rabbitmq-server

sudo tail -f /var/log/rabbitmq/rabbit@amqp04.log
```

```log
2025-06-28 17:11:33.013529+00:00 [info] <0.583.0> Management plugin: HTTP (non-TLS) listener started on port 15672
2025-06-28 17:11:33.013850+00:00 [info] <0.611.0> Statistics database started.
2025-06-28 17:11:33.013969+00:00 [info] <0.610.0> Starting worker pool 'management_worker_pool' with 3 processes in it
2025-06-28 17:11:33.014374+00:00 [info] <0.525.0> Ready to start client connection listeners
2025-06-28 17:11:33.016815+00:00 [info] <0.635.0> started TCP listener on [::]:5672
2025-06-28 17:11:33.108779+00:00 [info] <0.525.0> Server startup complete; 3 plugins started.
2025-06-28 17:11:33.108779+00:00 [info] <0.525.0>  * rabbitmq_management
2025-06-28 17:11:33.108779+00:00 [info] <0.525.0>  * rabbitmq_management_agent
2025-06-28 17:11:33.108779+00:00 [info] <0.525.0>  * rabbitmq_web_dispatch
2025-06-28 17:11:33.225099+00:00 [info] <0.10.0> Time to start RabbitMQ: 2917 ms
```

## Config files

Default configuration file location is distribution-specific. 

RabbitMQ packages or nodes will not create any configuration files. Users and deployment tool should use the following locations when creating the files:

|Platform | Default Configuration File Directory | Example Configuration File Paths
| ------- | ------------------------------------ | --------------------------------
|Debian and Ubuntu |  /etc/rabbitmq/ | /etc/rabbitmq/rabbitmq.conf, /etc/rabbitmq/advanced.config

```bash
/etc/rabbitmq
# only one file
enabled_plugins

# Make file advanced
sudo nano advanced.config
# append [].

# Make file conf
sudo touch rabbitmq.conf
ls
# advanced.config  enabled_plugins  rabbitmq.conf
```
Restart rabbitmq-server

```bash

sudo systemctl restart rabbitmq-server

# Then view new settings with
sudo systemctl status rabbitmq-server

```

rabbitmq.conf and advanced.config changes take effect after a node restart.

```log
Jun 28 17:15:25 amqp04 rabbitmq-server[2468]:   Logs: /var/log/rabbitmq/rabbit@amqp04.log
Jun 28 17:15:25 amqp04 rabbitmq-server[2468]:         <stdout>
Jun 28 17:15:25 amqp04 rabbitmq-server[2468]:   Config file(s): /etc/rabbitmq/advanced.config
Jun 28 17:15:25 amqp04 rabbitmq-server[2468]:                   /etc/rabbitmq/rabbitmq.conf
Jun 28 17:15:26 amqp04 rabbitmq-server[2468]:   Starting broker... completed with 3 plugins.
Jun 28 17:15:26 amqp04 systemd[1]: Started rabbitmq-server.service - RabbitMQ broker.
```

If rabbitmq-env.conf doesn't exist, it can be created manually in the location specified by the RABBITMQ_CONF_ENV_FILE variable

Environment variables can be used to override the location of the configuration file:
* overrides primary config file location
* RABBITMQ_CONFIG_FILE=/path/to/a/custom/location/rabbitmq.conf
* overrides advanced config file location
* RABBITMQ_ADVANCED_CONFIG_FILE=/path/to/a/custom/location/advanced.config
* overrides environment variable file location
* RABBITMQ_CONF_ENV_FILE=/path/to/a/custom/location/rabbitmq-env.conf

https://www.rabbitmq.com/configure.html#env-variable-interpolation

Ok, then we have all the basis stuff up and running, but that can take some time, lets make it quicker using definitions.json

## definitions.json

Nodes and clusters store information that can be thought of schema, metadata or topology. Users, vhosts, queues, exchanges, bindings, runtime parameters all fall into this category. This metadata is called definitions in RabbitMQ parlance.

Definitions can be exported to a file and then imported into another cluster or used for schema backup or data seeding.

Lets do the steps

1. Update the empty rabbitmq.conf
2. Make a definition.json

```bash
cd /etc/rabbitmq
sudo nano definitions.json
ls
# advanced.config  definitions.json  enabled_plugins  rabbitmq.conf
```
3. Restart rabbitmq-server
4. Verify definition.json

```bash

sudo systemctl restart rabbitmq-server

# Then view new settings with
sudo systemctl status rabbitmq-server

```

Lets verify this

```bash
sudo cat /var/log/rabbitmq/rabbit@amqp04.log
```

```log
2025-07-09 20:23:21.630414+00:00 [info] <0.534.0> Management plugin: HTTP (non-TLS) listener started on port 15672
2025-07-09 20:23:21.630630+00:00 [info] <0.562.0> Statistics database started.
2025-07-09 20:23:21.630724+00:00 [info] <0.561.0> Starting worker pool 'management_worker_pool' with 3 processes in it
2025-07-09 20:23:21.631000+00:00 [info] <0.476.0> Ready to start client connection listeners
2025-07-09 20:23:21.633272+00:00 [info] <0.586.0> started TCP listener on [::]:5672
2025-07-09 20:23:21.720212+00:00 [info] <0.476.0> Server startup complete; 3 plugins started.
2025-07-09 20:23:21.720212+00:00 [info] <0.476.0>  * rabbitmq_management
2025-07-09 20:23:21.720212+00:00 [info] <0.476.0>  * rabbitmq_management_agent
2025-07-09 20:23:21.720212+00:00 [info] <0.476.0>  * rabbitmq_web_dispatch
2025-07-09 20:23:21.857431+00:00 [info] <0.10.0> Time to start RabbitMQ: 3299 ms
```

List queues, users and test 5672

```bash
sudo rabbitmqctl list_users

sudo rabbitmqctl list_permissions

sudo rabbitmqctl list_queues

sudo rabbitmqctl list_bindings

# telnet localhost
telnet localhost 5672
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Connection closed by foreign host.

```

And then we see that it has loaded the definition.json

![definitions json](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/rabbitmq-server/images/def_json2.jpg)


https://www.rabbitmq.com/docs/definitions#import-after-boot


Now lets publish one msg and restart rabbitmq-server to see that the queue is durable.

```bash

# Type it in console
python3
# Python 3.12.3 (main, Feb  4 2025, 14:48:35) [GCC 13.3.0] on linux

# venv
sudo apt install python3.12-venv

# make and activate v env
python3 -m venv testamqp
source testamqp/bin/activate

(testamqp) Imsdal@amqp04:~$

# install pip inside v env
sudo apt install python3-pip

# install pika in v env
pip install pika

sudo nano publish_amqp.py

# deactivate v env
deactivate
```

Code in Python for publish_amqp.py

```py
# publish.py
import pika, sys
credentials = pika.PlainCredentials('kasparov', 'amazing-805')
connection = pika.BlockingConnection(pika.ConnectionParameters('localhost', credentials=credentials))
channel = connection.channel()

# channel.queue_declare(queue='az-queue', durable=True)
# we did this in definitions.json

channel.basic_publish(exchange='amq.direct', routing_key='az-routing-key', body='Hello, RabbitMQ!', properties=pika.BasicProperties(delivery_mode=2))
print("Publish done")
connection.close()
```

Run the script and list queues and view one message
```bash
(testamqp) Imsdal@amqp04:~$ python3 publish_amqp.py
Publish done
deactivate

sudo rabbitmqctl list_queues
# Timeout: 60.0 seconds ...
# Listing queues for vhost / ...
# name    messages
# az-queue        1

```

![v env](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/rabbitmq-server/images/venv.jpg)

Now restart rabbitmq-server

https://github.com/pika/pika/blob/main/examples/publish.py


## TLS amqp04_client.cloud

Go to https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/rabbitmq-server/README_openssl.md

No that we have the certs for our client lets enable tls.

Move the certs to a folder /etc/rabbitmq/

```bash

cd sudo mkdir /etc/rabbitmq/cert

cd /rmq-x2-ssl/cert-store

# move CA bundle
sudo cp ca.bundle /etc/rabbitmq/cert/ca.bundle

# move client cert and key
sudo cp ./client/client_certificate.pem /etc/rabbitmq/cert/client_certificate.pem
sudo cp ./client/private_key.pem /etc/rabbitmq/cert/private_key.pem

# verify it
cd /etc/rabbitmq
ls
advanced.config  cert  definitions.json  definitions.json_bck  enabled_plugins  rabbitmq.conf

```


Now configure amqp to use it, add to rabbitmq.conf.

We still use 5672 for localhost, so we can send data.

bash it

```bash

sudo systemctl stop rabbitmq-server

cd /etc/rabbitmq/cert
# set permission
sudo chmod 664 ca.bundle
sudo chmod 664 client_certificate.pem
sudo chmod 664 private_key.pem
```

```ini

loopback_users.guest = false

default_user = kasparov
default_pass = amazing-805

listeners.tcp.default = 5672
# management.tcp.port = 15672

vm_memory_high_watermark.relative = 0.3
disk_free_limit.relative = 1.5

log.file.rotation.count= 5
log.file.rotation.size= 10485760

management.load_definitions = /etc/rabbitmq/definitions.json

# ssl
listeners.ssl.default = 5671
ssl_options.cacertfile = /etc/rabbitmq/cert/ca.bundle
ssl_options.certfile = /etc/rabbitmq/cert/client_certificate.pem
ssl_options.keyfile = /etc/rabbitmq/cert/private_key.pem
ssl_options.verify = verify_none
ssl_options.fail_if_no_peer_cert = false

# ssl management
management.ssl.port       = 15671
management.ssl.cacertfile = /etc/rabbitmq/cert/ca.bundle
management.ssl.certfile   = /etc/rabbitmq/cert/client_certificate.pem
management.ssl.keyfile    = /etc/rabbitmq/cert/private_key.pem
management.hsts.policy    = max-age=31536000; includeSubDomains
management.ssl.versions.1 = tlsv1.2
```
bash it

```bash
sudo systemctl start rabbitmq-server

# log it
sudo cat /var/log/rabbitmq/rabbit@amqp04.log

```

Log

```ini
2025-07-10 20:41:31.973814+00:00 [info] <0.552.0> Management plugin: HTTPS listener started on port 15671
2025-07-10 20:41:31.973980+00:00 [info] <0.582.0> Statistics database started.
2025-07-10 20:41:31.974066+00:00 [info] <0.581.0> Starting worker pool 'management_worker_pool' with 3 processes in it
2025-07-10 20:41:31.974300+00:00 [info] <0.494.0> Ready to start client connection listeners
2025-07-10 20:41:31.976948+00:00 [info] <0.606.0> started TCP listener on [::]:5672
2025-07-10 20:41:31.979209+00:00 [info] <0.626.0> started TLS (SSL) listener on [::]:5671
2025-07-10 20:41:32.072015+00:00 [info] <0.494.0> Server startup complete; 3 plugins started.
2025-07-10 20:41:32.072015+00:00 [info] <0.494.0>  * rabbitmq_management
2025-07-10 20:41:32.072015+00:00 [info] <0.494.0>  * rabbitmq_management_agent
2025-07-10 20:41:32.072015+00:00 [info] <0.494.0>  * rabbitmq_web_dispatch
2025-07-10 20:41:32.116489+00:00 [info] <0.10.0> Time to start RabbitMQ: 3464 ms

```

Test telnet

```bash
telnet localhost 5671
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Connection closed by foreign host.

telnet localhost 5672
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Connection closed by foreign host.

```

Verify in logs

```bash
sudo cat /var/log/rabbitmq/rabbit@amqp04.log

```
Log telnet

![telnet amqp04 ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/rabbitmq-server/images/telnet.jpg)


## TLS amqp05_server.cloud TODO

Go to https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/rabbitmq-server/README_openssl.md

No that we have the certs for our server lets enable tls.

But first create the vm same as amqp04

Move the certs to a folder /etc/rabbitmq/

## 5672 Shovel between amqp04_client.cloud -> amqp05_server.cloud make new readme for shovel and mtls

## 5671 mTLS Shovel between amqp04_client.cloud -> amqp05_server.cloud
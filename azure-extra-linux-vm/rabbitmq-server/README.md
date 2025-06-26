# How To Install and Start Using RabbitMQ on Ubuntu 22.04

https://www.cherryservers.com/blog/how-to-install-and-start-using-rabbitmq-on-ubuntu-22-04

## Install RabbitMQ TBD

https://www.rabbitmq.com/docs/install-debian#supported-distributions


## Enable RabbitMQ Management Console

```bash
sudo rabbitmq-plugins list
rabbitmq-plugins enable rabbitmq_management
```

Create a user since default user is default to localhost

```bash
# Only root or rabbitmq can run rabbitmqctl
sudo rabbitmqctl add_user username amazing-password
sudo rabbitmqctl list_users
sudo rabbitmqctl set_user_tags newuser administrator
sudo rabbitmqctl set_permissions -p / newuser ".*" ".*" ".*"
sudo rabbitmqctl list_permissions

```

Open port 15672 inbound to server

Visit http://IP-ADDRESS:15672/

![RabbitMQ management](https://github.com/spawnmarvel/azure-automation/blob/main/images/rabbitmqmanagement.jpg)

Delete default user
```bash
sudo rabbitmqctl delete_user guest
sudo rabbitmqctl list_users
```


Create RabbitMQ Virtual Host, RabbitMQ manages user permissions on a virtual host level.

```bash
sudo rabbitmqctl add_vhost segment01
sudo rabbitmqctl list_vhosts
```

Set specific user permission for a user on the new vhost
```bash
sudo rabbitmqctl set_permissions -p <virtual_host> <user_name> <permissions>
# Example full permission
sudo rabbitmqctl set_permissions -p segment01 newuser ".*" ".*" ".*"
```
Args
* -p is used to define the virtual host.
* The first permission argument “.*” grants configuration permissions on all virtual host entities. It allows you to declare exchanges, queues, etc.
* The second permission argument “.*” grants write permissions on all virtual host entities. It allows you to create bindings, publish messages etc.
* The third permission argument “.*” grants read permissions. It allows you to read queues, consume messages, etc.

```bash
sudo rabbitmqctl list_permissions
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
```bash
sudo systemctl status rabbitmq-server

```
Path
```log
Jul 14 07:53:35 simpleLinuxVM-XXXXXXXX rabbitmq-server[4595]:   Logs: /var/log/rabbitmq/rabbit@simpleLinuxVM-26446.log
Jul 14 07:53:35 simpleLinuxVM-XXXXXXXX rabbitmq-server[4595]:         <stdout>
Jul 14 07:53:35 simpleLinuxVM-XXXXXXXX rabbitmq-server[4595]:   Config file(s): (none)
Jul 14 07:53:37 simpleLinuxVM-XXXXXXXX rabbitmq-server[4595]:   Starting broker... completed with 3 plugins.
```

Tail

```bash
 sudo tail -f /var/log/rabbitmq/rabbit@simpleLinuxVM-XXXXX.log
```

```log
2023-07-14 07:53:37.639980+00:00 [info] <0.544.0> Resetting node maintenance status
2023-07-14 07:53:37.651443+00:00 [info] <0.603.0> Management plugin: HTTP (non-TLS) listener started on port 15672
2023-07-14 07:53:37.651598+00:00 [info] <0.631.0> Statistics database started.
2023-07-14 07:53:37.651682+00:00 [info] <0.630.0> Starting worker pool 'management_worker_pool' with 3 processes in it
2023-07-14 07:53:37.652008+00:00 [info] <0.544.0> Ready to start client connection listeners
2023-07-14 07:53:37.653575+00:00 [info] <0.655.0> started TCP listener on [::]:5672
2023-07-14 07:53:37.720077+00:00 [info] <0.544.0> Server startup complete; 3 plugins started.
2023-07-14 07:53:37.720077+00:00 [info] <0.544.0>  * rabbitmq_management
2023-07-14 07:53:37.720077+00:00 [info] <0.544.0>  * rabbitmq_web_dispatch
2023-07-14 07:53:37.720077+00:00 [info] <0.544.0>  * rabbitmq_management_agent
```

## Config files

Default configuration file location is distribution-specific. 

RabbitMQ packages or nodes will not create any configuration files. Users and deployment tool should use the following locations when creating the files:

|Platform | Default Configuration File Directory | Example Configuration File Paths
| ------- | ------------------------------------ | --------------------------------
|Debian and Ubuntu |  /etc/rabbitmq/ | /etc/rabbitmq/rabbitmq.conf, /etc/rabbitmq/advanced.config

```bash
# Make file
sudo nano /etc/rabbitmq/advanced.config
# append [].

# Make file
cd /etc/rabbitmq/
sudo touch rabbitmq.conf
ls
```

```bash

sudo systemctl restart rabbitmq-server
```

rabbitmq.conf and advanced.config changes take effect after a node restart.

```log
Jul 14 08:21:37 simpleLinuxVM-XXXXX rabbitmq-server[643]:   Logs: /var/log/rabbitmq/rabbit@simpleLinuxVM-26446.log
Jul 14 08:21:37 simpleLinuxVM-XXXXX rabbitmq-server[643]:         <stdout>
Jul 14 08:21:37 simpleLinuxVM-XXXXX rabbitmq-server[643]:   Config file(s): /etc/rabbitmq/advanced.config
Jul 14 08:21:37 simpleLinuxVM-XXXXX rabbitmq-server[643]:                   /etc/rabbitmq/rabbitmq.conf
Jul 14 08:21:40 simpleLinuxVM-XXXXX rabbitmq-server[643]:   Starting broker... completed with 3 plugins.
Jul 14 08:21:40 simpleLinuxVM-XXXXX systemd[1]: Started RabbitMQ broker.
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


## TLS rmq_client.cloud

## Shovel between rmq_client.cloud -> rmq_server.cloud

## mTLS Shovel between rmq_client.cloud -> rmq_server.cloud
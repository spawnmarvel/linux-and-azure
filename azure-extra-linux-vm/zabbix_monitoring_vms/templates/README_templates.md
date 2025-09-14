# Test more templates and stuff

### Template Linux by Zabbix agent

Template Linux by Zabbix agent on dummy01 

Template Linux by Zabbix agent active on dummy03


There are some differences like here for the time out.

Active:

![template active time](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/template_passive_time.jpg)

Passive:

![template active time](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/template_active_time.jpg)

https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/README.md

Lets see how many active templates there are.

As you will see a bit later we are using Linux by Zabbix agent active for the server dummy03.

![template active time](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/active_template.jpg)




### Template MySQL by Zabbix agent

Let s start monitor our MySQL database

Install Zabbix agent and MySql client, we already have that since we are on local host 

```bash
# check agent
zabbix_agent2 -V
zabbix_agent2 (Zabbix) 6.0.40

# check our mysql client
dpkg -l | grep mysql-client
```

1. Create the MySQL user that will be used for monitoring

```sql

-- login
sudo mysql -uroot -p

-- create a user for monitor
CREATE USER 'zbx_monitor'@'%' IDENTIFIED BY 'LudoBicEnhanced#7-';
GRANT REPLICATION CLIENT,PROCESS,SHOW DATABASES,SHOW VIEW ON *.* TO 'zbx_monitor'@'%';

```

2. Log into Zabbix frontend.

On Zabbix server

In the Templates field, type or select the template "MySQL by Zabbix agent 2" that will be linked to the host.

In the Macros tab, switch to Inherited and host macros, look for the following macros and click on Change next to the macro value to update it:


{$MYSQL.DSN} tcp://localhost:3306

{$MYSQL.PASSWORD} LudoBicEnhanced#7-

{$MYSQL.USER} zbx_monitor


Zabbix server

![mysql zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/mysql_zabbix.jpg)

And data should come.

![mysql data](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/mysql.jpg)


https://www.zabbix.com/documentation/current/en/manual/guides/monitor_mysql

With this template you get dashboards also on the server it was added to.

![mysql dashboard](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/mysql_dash.jpg)

Lets have a a look at the data:

![mysql graph](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/mysql_graph.jpg)


### Install Zabbix Agent 2

Lets install Zabbix Agent 2 on the vm with rabbitmq, amqp04



```bash
# instal repos
sudo wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.0+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_latest_6.0+ubuntu24.04_all.deb
sudo apt update -y

# Install Zabbix agent 2
sudo apt install zabbix-agent2

# Install Zabbix agent 2 plugins
# na, not needed now, but this is how
# sudo apt install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql

# Start Zabbix agent 2 process
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2

# log it
cat /var/log/zabbix/zabbix_agent2.log


# edit conf
cd /etc/zabbix
sudo nano zabbix-agent2.conf
```

Edit conf

```ini
LogFileSize=100
Server=192.168.3.5
# set comment
# ServerActive=127.0.0.1
Hostname=amqp04
```

Restart and check logs
```bash
sudo systemctl restart zabbix-agent2

sudo service zabbix-agent2 status

```
Host name on second last line.

![amqp01 vm zabbix agent](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04.jpg)

https://www.zabbix.com/download?zabbix=6.0&os_distribution=ubuntu&os_version=24.04&components=agent_2&db=&ws=

Now create the host in Zabbix frontend with Linux by zabbix agent (passive), not the active.

![amqp01 vm zabbix agent ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04_ok.jpg)

Now we can monitor amqp rabbitmq


### Template RabbitMQ node by Zabbix agent

```bash
sudo rabbitmqctl add_user zbx_monitor brokenZepplingalaxy7803
sudo rabbitmqctl set_permissions  -p / zbx_monitor "" "" ".*"
sudo rabbitmqctl set_user_tags zbx_monitor monitoring

sudo rabbitmqctl list_users
Listing users ...
user    tags
guest   [administrator]
zbx_monitor     [monitoring]
kasparov        [administrator]
amqp04_client.cloud     [administrator]
consumer        []

sudo cat /var/log/rabbitmq/rabbit@amqp04.log
# managment is enabled from before
2025-07-15 18:09:40.746008+00:00 [info] <0.552.0> Management plugin: HTTPS listener started on port 15671
2025-07-15 18:09:40.746166+00:00 [info] <0.582.0> Statistics database started.
2025-07-15 18:09:40.746237+00:00 [info] <0.581.0> Starting worker pool 'management_worker_pool' with 3 processes in it
2025-07-15 18:09:40.746424+00:00 [info] <0.494.0> Ready to start client connection listeners
2025-07-15 18:09:40.755686+00:00 [info] <0.606.0> started TCP listener on [::]:5672
2025-07-15 18:09:40.758732+00:00 [info] <0.626.0> started TLS (SSL) listener on [::]:5671
2025-07-15 18:09:40.819243+00:00 [info] <0.494.0> Server startup complete; 3 plugins started.
2025-07-15 18:09:40.819243+00:00 [info] <0.494.0>  * rabbitmq_management
2025-07-15 18:09:40.819243+00:00 [info] <0.494.0>  * rabbitmq_management_agent
2025-07-15 18:09:40.819243+00:00 [info] <0.494.0>  * rabbitmq_web_dispatch
2025-07-15 18:09:40.872894+00:00 [info] <0.10.0> Time to start RabbitMQ: 5766 ms
```

Go to the host amqp04 in Zabbix and add template, RabbitMQ node by Zabbix agent

![template rabbitmq](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04_template.jpg)

Then go to Inherited and host macros and add, just follow the URL and it is documented there.

![amqp04 vm template rabbitmq](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04_rabbitmq_template2.jpg)


Thats it, the data should be ready lets check.

![amqp04 rabbit template succes](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04_template_success.jpg)

Lets change the rabbitmq.conf

![amqp04 limits](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04_limit.jpg)


And then check it in zabbix, nice.

![amqp04 limits](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04_limit_result.jpg)

Lets publish some messages with python3.

![amqp04 pub zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04_pub.jpg)

https://www.zabbix.com/integrations/rabbitmq


### Website certificate by Zabbix agent 2

Let s check that we have agent 2
```bash
sudo service zabbix-agent2 status
[sudo] password for imsdal:
● zabbix-agent2.service - Zabbix Agent 2

# or
zabbix_agent2 -V
zabbix_agent2 (Zabbix) 6.0.40

```
Lets try to configure it.
Go to zabbix server and add, Website certificate by Zabbix agent 2.

Just follow the link for the actual configuration.
We are using a self signed cert with IP as CN, so that is used in both fields.

It will take 15 min before zabbix does GET CERT.

![cert agent](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/cert.jpg)

After 15 min:

![cert agent ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/cert_ok.jpg)

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/app/certificate_agent2/README.md

### Azure Cost Management by HTTP and Azure Virtual Machine by HTTP


```ps1
# login az
connect-AzAccount -TenantId ID

# Create a service principal
$sp = New-AzADServicePrincipal -DisplayName 'zabbix'

# get secret
$sp.PasswordCredentials.SecretText

# get all spn
Get-AzAdServicePrincipal | sort DisplayName

# get just zabbix
Get-AzAdServicePrincipal | where DisplayName -eq 'zabbix'

# get azure sub id
Get-AzSubscription

# set access for role
New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Reader" -Scope "/subscriptions/<subscription_id>"

# DisplayName        : zabbix
# SignInName         :
# RoleDefinitionName : Reader
# [..]

```



Create a host in zabbix with no interface, use template 
* Azure Cost Management by HTTP
* Azure Virtual Machine by HTTP

To monitor a vm

```ps1
$vm = Get-AzVM -ResourceGroupName rg-ukzabbix-0002 -Name vmzabbix02
$vm.Id
```
Use the vm id in the macro

Add macros

![azure host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/azure_host2.jpg)

And if all is correct

![azure host result](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/azure_host_result.jpg)

Azure cost takes some hours

![azure cost](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/azure_cost.jpg)

Example triggers

![azure host vm](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/azure_host_vm.jpg)

The template for vm azure was moved to the zabbix server, since that is an azure vm and the azurehost was just for test.

Azure Virtual Machine by HTTP was also added to amqp04 and dummy01.


(The azurhos tnow only has the cost information.)

Example from zabbix server:

![azure host zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/azure_host_zabbix.jpg)

How to SPN https://learn.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-14.2.0


Zabbix integrate azure https://www.zabbix.com/integrations/azure

### Azure MySQL Flexible Server by HTTP TODO

https://www.zabbix.com/integrations/azure

### InfluxDB template for zabbix TODO


https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/influxdb/README_integrate_with_zabbix.md
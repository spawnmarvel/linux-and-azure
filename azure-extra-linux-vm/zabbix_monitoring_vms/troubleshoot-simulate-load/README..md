# Max port connections 10051 / exhaust zabbix server and data falling behind

The config is default, besides:

In edit the following fields

```bash

/etc/zabbix

sudo nano zabbix_server.conf

DebugLevel=4


```
## Scripts

On vmdocker01 a remote vm run trapper script 

```bash
bash simulate_trapper_10051_data_load.sh

```

You will see:

```bash

Processing host: simhost05
    Sending tag1: 65
    Sending tag2: 53
    Sending tag3: 70
    Sending tag4: 60
    Sending tag5: 6

  Iteration 6: Total items attempted: 25, Failed items: 0, Successful items: 25
  Pausing for 1 second(s)...
Iteration 7 of 500



```

The start this script on the zabbix server

```bash

bash simulate_exhaust_local_10051.sh

# Run it 4 times to 6000 connectins or try

# Then run

ss -ltn

State      Recv-Q      Send-Q           Local Address:Port            Peer Address:Port     Process
LISTEN     0           151                  127.0.0.1:3306                 0.0.0.0:*
LISTEN     0           4096             127.0.0.53%lo:53                   0.0.0.0:*
LISTEN     4097        4096                   0.0.0.0:10051                0.0.0.0:*
LISTEN     0           4096                   0.0.0.0:10050                0.0.0.0:*
LISTEN     0           4096                127.0.0.54:53                   0.0.0.0:*
LISTEN     0           70                   127.0.0.1:33060                0.0.0.0:*
LISTEN     0           4096                      [::]:10051                   [::]:*
LISTEN     0           4096                      [::]:10050                   [::]:*
LISTEN     0           511                          *:80                         *:*
LISTEN     0           4096                         *:22                         *:*

```

Go back to vm docker01`and you will see for the trapper script 

```bash
# many errors from the agent

 Processing host: simhost02
    Sending tag1: 73
    Sending tag2: 6
    Sending tag3: 94
    Sending tag4: 16
    Sending tag5: 73
  Processing host: simhost03
    Sending tag1: 57
    Sending tag2: 99
    Sending tag3: 19
Error sending tag3: 19 for simhost03
    Sending tag4: 96
Error sending tag4: 96 for simhost03
    Sending tag5: 9

```

Go back to zabbix server and you will see it is slowly removing the connections

```bash

ss -ltn

State      Recv-Q      Send-Q           Local Address:Port            Peer Address:Port     Process
LISTEN     0           151                  127.0.0.1:3306                 0.0.0.0:*
LISTEN     0           4096             127.0.0.53%lo:53                   0.0.0.0:*
LISTEN     4042        4096                   0.0.0.0:10051                0.0.0.0:*

# wait 2 min
ss -ltn

State      Recv-Q      Send-Q           Local Address:Port            Peer Address:Port     Process
LISTEN     0           151                  127.0.0.1:3306                 0.0.0.0:*
LISTEN     0           4096             127.0.0.53%lo:53                   0.0.0.0:*
LISTEN     3901        4096                   0.0.0.0:10051                0.0.0.0:*

```

The vmdocker trapper script is still in error state

```bash

 Processing host: simhost03
    Sending tag1: 57
    Sending tag2: 99
    Sending tag3: 19
Error sending tag3: 19 for simhost03
    Sending tag4: 96
Error sending tag4: 96 for simhost03
    Sending tag5: 9
Error sending tag5: 9 for simhost03
  Processing host: simhost04
    Sending tag1: 25
Error sending tag1: 25 for simhost04
    Sending tag2: 26
Error sending tag2: 26 for simhost04
    Sending tag3: 61
```

On the vmdocker01 open the agent logs

```bash

pwd
/var/log/zabbix

sudo tail -f zabbix_agentd.log

```

And you will see error

```bash
57590:20250606:204218.159 IPv6 support:          YES
 57590:20250606:204218.159 TLS support:           YES
 57590:20250606:204218.159 **************************
 57590:20250606:204218.159 using configuration file: /etc/zabbix/zabbix_agentd.conf
 57590:20250606:204218.160 agent #0 started [main process]
 57591:20250606:204218.160 agent #1 started [collector]
 57593:20250606:204218.161 agent #3 started [listener #2]
 57592:20250606:204218.162 agent #2 started [listener #1]
 57595:20250606:204218.164 agent #5 started [active checks #1]
 57594:20250606:204218.164 agent #4 started [listener #3]
 57595:20250606:204421.197 Unable to receive from [192.168.3.5]:10051 [ZBX_TCP_READ() timed out]
 57595:20250606:204421.197 Active check configuration update started to fail


```

## Findings in Azure and Zabbix server

It will slowly remove the connections, but it takes time.
The quick fix is

```bash
sudo service zabbix-server stop/ start / status
```

What happend in Azure:


![Flood](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/troubleshoot-simulate-load/Inbound_flows.jpg)


What happend on Zabbix server:

![Zabbix slow](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/troubleshoot-simulate-load/Zabbix_slow.jpg)








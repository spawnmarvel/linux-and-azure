# Test your configuration and simulation load for troubleshooting


## Simulate load CPU

On Linux, you can simulate high CPU load and as a result receive a problem alert by running:

```bash

cat /dev/urandom | md5sum
```

The command cat /dev/urandom | md5sum is a pipeline in Unix-like systems that generates a continuous stream of random data and computes its MD5 hash. Here's a breakdown of what happens:

* /dev/urandom is a special file in Unix-like systems that serves as a pseudo-random number generator. It provides an endless stream of random bytes
* The cat command reads the contents of /dev/urandom and outputs it to standard output (stdout)
* The pipe (|) redirects the output of cat /dev/urandom (the random bytes) to the input of the next command, md5sum
* md5sum is a utility that computes the MD5 hash (a 128-bit cryptographic hash) of the input data it receives.
* Since /dev/urandom provides an infinite stream of random data, md5sum will continue reading this stream indefinitely, waiting for the input to end before it can produce a final hash

Infinite Stream Issue: Because /dev/urandom never "ends," md5sum will never finish computing the hash unless you manually stop the command (e.g., by pressing Ctrl+C)

![Test CPU](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/test_cpu.jpg)

## Simulate inbound flows Azure


# Use cloud-init

## cloud-init support for virtual machines in Azure

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init

cloud-init is a widely used approach to customize a Linux VM as it boots for the first time. You can use cloud-init to install packages and write files, or to configure users and security. Because cloud-init is called during the initial boot process, there are no additional steps or required agents to apply your configuration. For more information on how to properly format your #cloud-config files or other inputs, see the cloud-init documentation site. #cloud-config files are text files encoded in base64.


## cloud-ini docs


https://cloudinit.readthedocs.io/en/latest/explanation/format.html#cloud-config-data

## 101 Tutorial - How to use cloud-init to customize a Linux virtual machine in Azure on first boot

* Create a cloud-init config file
* Create a VM that uses a cloud-init file
* View a running Node.js app after the VM is created
* Use Key Vault to securely store certificates
* Automate secure deployments of NGINX with cloud-init

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment

## Deep dive

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cloud-init-deep-dive

## Troubleshooting

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cloud-init-troubleshooting

## Configure VM hostname

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cloudinit-update-vm-hostname

## Update packages on a VM

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cloudinit-update-vm?tabs=rhel

## Add user on a VM

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cloudinit-add-user

## Configure swapfile

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cloudinit-configure-swapfile

## Run existing bash script

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cloudinit-bash-script


# Creating image without a provisioning agent

Microsoft Azure provides provisioning agents for Linux VMs in the form of the walinuxagent or cloud-init (recommended). But there could be a scenario when you don't want to use either of these applications for your provisioning agent, such as:

Your Linux distro/version doesn't support cloud-init/Linux Agent.
You require specific VM properties to be set, such as hostname.

## Creating generalized images without a provisioning agent

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/no-agent

## Disable or remove the Linux Agent from VMs and images
https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disable-provisioning


# Make cloud-init

## Apache

## Zabbix

## Wordpress


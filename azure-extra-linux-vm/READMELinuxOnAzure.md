# Linux on Azure MS Learn

This comprehensive learning path reviews deployment and management of Linux on Azure. Learn about cloud computing concepts, Linux IaaS and PaaS solutions and benefits and Azure cloud services. 

Discover how to migrate and extend your Linux-based workloads on Azure with improved scalability, security, and privacy.

https://learn.microsoft.com/en-us/training/paths/azure-linux/?wt.mc_id=youtube_S-1076_video_reactor&source=learn

## 1 Introduction to Linux on Azure

First, choose the Linux distribution you want based on familiarity, usage, cost, and support requirements.

First, choose the Linux distribution you want based on familiarity, usage, cost, and support requirements.

* IaaS
* PaaS 
* DBaaS — Azure automates database updates, provisioning, and backups, which enable you to focus on application development.
* SaaS 

This module focuses on IaaS, PaaS, and database as a service options for Linux.

### Identify Azure IaaS options for Linux deployments

Choosing a Linux distribution

* Licensing/pricing
* Support, Microsoft gives you the option of running almost any Linux image, but the level of support you receive depends on the type of Linux distribution you choose.
* * Microsoft recommends using endorsed distributions for most production workloads because you benefit from the support and collaboration between Microsoft and Linux providers — Red Hat, SUSE, Canonical, and others.
* * Three of the largest Linux vendors — Red Hat, SUSE, and Ubuntu — partner with Microsoft to provide end-to-end support of Linux deployments.
* Virtual networking and network appliances
* Azure Storage
* Choose the appropriate Azure Files tier

When to use Azure IaaS resources for Linux deployments

* Some organizations want to take a hands-on approach with all aspects of their infrastructure, from the choice of virtual machine configurations to storage and network optimization to building custom development environments. For those organizations, IaaS is an appropriate approach.

Identify Azure PaaS options for Linux deployments

Azure managed platforms allow you to take advantage of the benefits of PaaS while retaining the Linux-based technology foundation you're already familiar with. Some of the popular managed platforms for Linux include:

* Azure App Service
* Azure Functions
* Azure Red Hat OpenShift
* Azure Red Hat OpenShift
* Azure Container Instances

When to use Azure PaaS resources for Linux deployments

* If your goal is to create new applications and services quickly, use PaaS to gain greater agility and reusability by adopting modern development tools and advanced application architectures. 

Identify database-as-a-service options for Linux deployments

A partial list of the fully managed databases available on Azure includes:

* Azure SQL Database
* Azure Database for PostgreSQL
* Azure Database for MySQL
* Azure Cosmos DB
* Azure Cache for Redis

Identify other Azure tools and services for Linux deployments

Examples of open-source tools

* Prometheus,  On Azure, you don't need to set up and manage a Prometheus server with a database. Instead, use Azure Monitor managed service for Prometheus, a component of Azure Monitor Metrics. 
* Terraform, To simplify common IT Ops and DevOps tasks, use Terraform, an open-source declarative coding tool. Terraform works with Bash or Azure PowerShell for Linux.

NOTE: Terraform uses its own Terraform CLI. If you want to use a declarative coding tool more closely integrated with Azure, consider Bicep, which works with Azure CLI and the Azure portal.

* Red Hat Ansible Automation Platform on Azure, Operate and manage automation with a Red Hat solution that's integrated with native Azure services.
* Azure CLI, Azure Portal, Azure Resource Manager, 


Security tools and capabilities

* Azure provides multilayered security across physical datacenters, infrastructure, and operations in Azure. No matter which Linux distribution you choose, you can protect your workloads by using built-in controls and services in Azure across identity, data, networking, and apps.


Business continuity and disaster recovery

Azure offers an end-to-end backup and disaster recovery solution for Linux that's simple, secure, scalable, and cost-effective — and can be integrated with on-premises data protection solutions.

* Azure Backup
* Azure Site Recovery
* Azure Archive Storage
* Azure Migrate, Use Azure Migrate to simplify migration and optimization when moving Linux workloads to Azure.


## 2 Plan your Linux environment in Azure


Plan for sizing and networking of Azure VMs running Linux

* This planning process should consider the compute, networking, and storage aspects of the VM configuration.
* Microsoft has partnered with prominent Linux vendors to integrate their products with the Azure platform, such as SUSE, Red Hat, and Ubuntu.
* Sizes for virtual machines in Azure
* * https://learn.microsoft.com/en-us/azure/virtual-machines/sizes?toc=%2Fazure%2Fvirtual-network%2Ftoc.json
* Plan for networking of Azure VMs running Linux
* Virtual networks and subnets
* Remote connectivity
* Azure Bastion
* JIT VM Access
* Network throughput
* * Although an Azure VM can have multiple network interfaces, its available bandwidth is dependent exclusively on its size. In general, larger VM sizes are allocated more bandwidth than smaller ones.

Implement best practices for managing Linux on Azure VMs

VM provisioning is the process in which the platform creates the Azure VM configuration parameter values (such as hostname, username, and password) that are available to the OS during the boot process. A provisioning agent consumes these values, configures the OS, and then reports the results when completed.

Azure supports cloud-init provisioning agents and Azure Linux Agent (WALA):

* Cloud-init provisioning agent. The cloud-init agent is a widely used approach to customizing Linux during an initial boot. You can use cloud-init to install packages and write files, or to configure users and security.
* WALA. WALA is an Azure platform-specific agent you can use to provision and configure Azure VMs. You can also use it to implement support for Azure extensions.

Optimize the management and troubleshooting boot process

* Enable boot diagnostics when provisioning an Azure VM.
* Leverage the Azure VM serial console access for troubleshooting boot failures.

There are many scenarios in which the serial console can help you restore an Azure VM running Linux to an operational state. The most common ones include:

* Broken file system table (fstab) files
* Misconfigured firewall rules
* File system corruption
* SSH configuration issues
* Interaction with bootloader
* Increase the timeout value in the grub menu on generation 2 Azure VMs.
* Reserve more memory for kdump. Just in case the dump capture kernel ends up with a panic on boot, you should reserve more memory for the kernel.

Optimize Linux on Azure VMs for performance and functionality

Optimize network performance of Azure VMs running Linux

Leverage kernel-based network optimizations

* Linux kernels that have been released after September 2017 include new network optimization options that enable Azure VMs running Linux to achieve higher network throughput. You can achieve significant throughput performance by using the latest Linux kernel.

Implement accelerated networking

* In addition to using the latest version of the Linux kernel and LIS, you should implement accelerated networking. This feature utilizes the host hardware's single-root I/O virtualization (SR-IOV) capabilities to improve network performance, resulting in minimized latency, maximized throughput, and lower CPU utilization.
* Without accelerated networking, all networking traffic in and out of the VM must traverse the host and the virtual switch. With accelerated networking, network traffic arrives at the VM's network interface and then gets forwarded directly to the VM, bypassing the host.

Optimize storage performance of Azure VMs running Linux

* Azure uses and manages block-level storage volumes that you can use with Azure VMs. A managed disk is similar to a physical disk, but also similar to virtual hard disks (VHDs) in that they present the underlying storage to an Azure VM.

Configure virtual disks

At a minimum, every Azure VM has two virtual disks:

* The OS disk, labeled as /dev/sda
* A temporary disk that provides temporary storage, labeled as /dev/sdb, and mounted to /mnt.

NOTE: Avoid storing data and installing applications on the OS disk because it's optimized for fast boot rather than running non-operating–system workloads. Instead, create data disks, attach them to the Azure VM, and mount them within the OS. Add extra disks as needed according to your storage and IOPS requirements. Keep in mind that the maximum number of disks you can attach to an Azure VM depends on its size.

Disable barriers

To achieve the highest IOPS on Premium SSD disks, where their cache settings have been set to either ReadOnly or None, disable barriers while mounting the file system in Linux.

* If you use reiserFS, disable barriers using the mount option barrier=none.
* If you use ext3/ext4, disable barriers using the mount option barrier=0.
* If you use XFS, disable barriers using the mount option nobarrier.

NOTE: If caching is set to read/write, barriers should remain enabled to ensure write durability.

Configure a swap file

There are two main approaches to implementing the optimal configuration of a swap file:

* Use the Azure VM Linux Agent for images that don't support cloud-init.
* For implementation details, see the Optimize your Linux VM on Azure Microsoft Learn article.
* Use cloud-init for images that support it.

Adjust the I/O scheduling algorithm

* For Linux kernels using the 'blk' subsystem, choose the "noop" scheduler.
* For Linux kernels using the 'blk-mq' subsystem, choose the "none" scheduler.

Implement multi-disk configurations

* If your workloads require more IOPS than a single disk can provide, use a software Redundant Array of Independent Disks (RAID) configuration that combines multiple disks


## 3 Provisioning a Linux virtual machine in Microsoft Azure

Microsoft Azure supports several methods both to provision resources for a Linux VM and transition existing Linux-based workloads.

* Azure portal, Azure CLI
* Terraform, Terraform is an open-source, multi-platform Infrastructure as Code (IaC) tool that you can use to provision and configure a wide range of environments, including multi-vendor public and private clouds. 
* Red Hat Ansible is another popular open-source tool you can use to complement the Terraform functionality. However, Ansible facilitates provisioning of cloud resources and supports both configuration management and application deployments.
* Bicep, Bicep offers an alternative declarative provisioning method to Terraform. Although it exclusively targets Azure resources, you can benefit from several integration and usability features common across Microsoft cloud-based technologies.

Azure supports two types of templates for declarative provisioning:

* Azure Resource Manager template. This template uses the JavaScript Object Notation (JSON) open-standard file format.
* Bicep template. This template relies on a domain-specific language (DSL).

Provision a Linux virtual machine by using the Azure portal

NOTE:

If you deploy an individual Azure VM for testing or evaluation purposes, you might choose to allow connectivity from the internet due to the convenience it provides. However, in general, you should avoid exposing Azure VMs to connections originating from the internet without additional constraints. To enhance security in such scenarios, consider implementing Azure Bastion or just-in-time (JIT) VM access, which is available as part of the Microsoft Defender for Cloud service. Azure also offers hybrid connectivity options, including Site-to-Site (S2S) virtual private network (VPN), Point-to-Site (P2S) VPN, and Azure ExpressRoute. All three options eliminate the need for assigning public IP addresses to Azure VM network interfaces for connections originating from your on-premises datacenter or designated, internet-connected computers.

Provision a Linux virtual machine by using Azure CLI

```bash
az login --tenant the-tenant-id-from-ad

```

Identify the suitable VM size

```bash

az vm list-sizes --location uksouth --output table

```
Create a resource group

After identifying the Azure VM image and size, you can now begin the provisioning process. 

Start by creating a resource group that will host the Azure VM and its dependent resources. 

```bash

az group create --name rg_lnx-cli --location uksouth

```
Create an Azure VM

```bash

az vm create \
    --resource-group rg_lnx-cli \
    --name lnx-cli-vm \
    --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
    --size Standard_B2ms \
    --admin-username azureuser \
    --generate-ssh-keys

```

The Azure VM will begin running shortly afterwards, usually within a couple of minutes. The output of the Azure CLI command will include JSON-formatted information about the newly deployed Azure VM

At this point, you'll be able to connect to the Azure VM by running the following command (after replacing the <public_ip_address> placeholder with the IP address you identified in the Azure CLI-generated output) from the computer where the private key is stored:

```bash

ssh azureuser@<public_ip_address>

```

Provision a Linux virtual machine by using Terraform

Provision a Linux virtual machine by using Bicep

https://learn.microsoft.com/en-us/training/modules/provision-linux-virtual-machine-in-azure/5-provision-linux-virtual-machine-using-bicep

```bash

az group create --name rg-lnx-bcp --location eastus

az bicep upgrade

az deployment group create --resource-group rg-lnx-bcp --template-file main.bicep --parameters adminUsername=azureuser

# In case you didn't record the Bicep deployment's output values, you can display them again by running the following command:

az deployment group show \
  --resource-group rg-lnx-bcp \
  --name main \
  --query properties.outputs

```

## 4 Build and run a web application with the MEAN stack on an Azure Linux virtual machine

You've heard about the MEAN stack (MongoDB, Express.js, AngularJS, and Node.js) and you know it uses JavaScript, so you decide to try it out by building a MEAN stack and a basic web application that stores information about books.

* Decide if the MEAN web stack is right for you.
* Create an Ubuntu Linux VM to host your web app.
* Install the MEAN stack components on your VM.
* Create a basic web app on your MEAN stack.

Decide if MEAN is right for you
* MEAN is a development stack for building and hosting web applications. MEAN is an acronym for its component parts: MongoDB, Express, AngularJS, and Node.js.
* The main reason you might consider MEAN is if you're familiar with JavaScript.


Exercise - Create a VM to host your web application

```bash
# The following az group create code sample is for you to run with your own account

resourceGroup='Rg-msl-meanstack-0013'
location='uksouth'
tags='Environment=Qa'

az group create --location $location --name $resourceGroup --tags $tags

# Mongdb is not ready for ubuntu 22 yet
az vm create \
    --resource-group $resourceGroup \
    --name MeanStack \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest \
    --size Standard_B2ms \
    --admin-username azureuser \
    --generate-ssh-keys

# Open port 80 on the VM to allow incoming HTTP traffic to the web application you'll later create.
az vm open-port \
  --port 80 \
  --resource-group $resourceGroup \
  --name MeanStack

# Create an SSH connection to your VM.
# Although the output from the az vm create command displays your VM's public IP address, you may find it useful to store the address in a Bash variable.
ipaddress=$(az vm show \
  --name MeanStack \
  --resource-group $resourceGroup \
  --show-details \
  --query [publicIps] \
  --output tsv)


ssh azureuser@$ipaddress

```

Exercise - Install MongoDB

```bash
# First, we'll make sure all current packages are up to date:
sudo apt update && sudo apt upgrade -y

# Install the MongoDB package:
sudo apt-get install -y mongodb

# After the installation completes, the service should automatically start up. Let's confirm this by running the following command:
sudo systemctl status mongodb

# Verify version
mongod --version

```

Exercise - Install Node.js

```bash
# You can get Node.js in two ways:
# LTS or current, here we use LTS

# Register the Node.js repository so the package manager can locate the packages using the following command.
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -

# Install the Node.js package
sudo apt install nodejs

# Verify version
node -v

# Exit your SSH session
```

Exercise - Create a basic web application

So far, you have MongoDB and Node.js installed on your Ubuntu VM. Now it's time to create a basic web application to see things in action. Along the way, you'll see how AngularJS and Express fit in.

Create the Books web application

From the Cloud Shell, run these commands to create the folders and files for your web application:

```bash
cd ~
mkdir Books
touch Books/server.js
touch Books/package.json
mkdir Books/app
touch Books/app/model.js
touch Books/app/routes.js
mkdir Books/public
touch Books/public/script.js
touch Books/public/index.html


# Run the code command to open your files through the Cloud Shell editor.
code Books
```
Create the data model

From the editor, open app/model.js and add the following:

```js
var mongoose = require('mongoose');
var dbHost = 'mongodb://localhost:27017/Books';
mongoose.connect(dbHost, { useNewUrlParser: true } );
mongoose.connection;
mongoose.set('debug', true);
var bookSchema = mongoose.Schema( {
    name: String,
    isbn: {type: String, index: true},
    author: String,
    pages: Number
});
var Book = mongoose.model('Book', bookSchema);
module.exports = Book;

```

Create the Express.js routes that handle HTTP requests

Create the client-side JavaScript application

Create the user interface

Create the Express.js server to host the application

Define package information and dependencies

Copy the files to your VM, make sure you have your VM's IP address handy

```bash
ipaddress=$(az vm show \
  --name MeanStack \
  --resource-group Rg-msl-meanstack-0013 \
  --show-details \
  --query [publicIps] \
  --output tsv)

echo $ipaddress

# You're all done editing files. Make sure that you saved changes to each file and then close the editor.
# You're all done editing files. Make sure that you saved changes to each file and then close the editor.
scp -r ~/Books azureuser@$ipaddress:~/Books

```

Install additional Node packages

```bash
# Recall that the application uses Mongoose to help transfer data in and out of your MongoDB database.

# The application also requires Express.js and the body-parser packages. Body-parser is a plugin that enables Express to work with data from the web form sent by the client.

# Let's connect to your VM and install the packages you specified in package.json.
ssh azureuser@$ipaddress


cd ~/Books

# Run npm install to install the dependent packages:
sudo apt install npm -y && npm install

Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.

# Run
npm install express

```

Test the application

```bash
# This command starts the application by listening on port 80 for incoming HTTP requests.
sudo node server.js
```

From a separate browser tab, navigate to your VM's public IP address.

You see the index page, which includes a web form.

Try adding a few books to the database. Each time you add a book, the page updates the complete list of books.


![Output ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/meanstack.jpg)

https://learn.microsoft.com/en-us/training/modules/build-a-web-app-with-mean-on-a-linux-vm/?wt.mc_id=youtube_S-1076_video_reactor&source=learn



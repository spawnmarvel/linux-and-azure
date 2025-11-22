It looks like you want a complete, consolidated view of the process for **mirroring the MySQL repository** for Ubuntu 24.04, from server setup to client verification.

Here is the full, step-by-step guide for setting up the MySQL mirror alongside your existing Zabbix mirror.

-----

## Note

Yes, if you mirror the Single LTS Release (Ubuntu 24.04, Noble) limited to the amd64 architecture, you will have MySQL available.

Yes, PHP is also hosted in the official Ubuntu repositories and will be included in your mirrored scope

## 💾 1. Mirror Server Setup (dmzdocker03)

This section covers creating the directory, setting up the synchronization script, and hosting the GPG key.

### 1.1 Create MySQL Mirror Directory

Create a dedicated directory for the MySQL packages under the Apache web root.

```bash
# Define the root path
MYSQL_MIRROR_ROOT="/var/www/html/mysql_mirror"

# Create the target directory
sudo mkdir -p $MYSQL_MIRROR_ROOT

# Ensure Apache can read the structure
sudo chown -R www-data:www-data /var/www/html
```

### 1.2 Create Synchronization Script

Create the script **`/usr/local/bin/sync_mysql_mirror.sh`** to handle the mirroring process. Note the specific host (`repo.mysql.com`) and root path (`/apt/`).

```bash
sudo nano /usr/local/bin/sync_mysql_mirror.sh
```

**Script Contents:**

```bash
#!/bin/bash

# Configuration Variables
DISTRIBUTION="noble"
ARCHITECTURE="amd64"
MYSQL_MIRROR_ROOT="/var/www/html/mysql_mirror"

# Log file for debmirror output
LOG_FILE="/var/log/mysql-mirror-sync.log"

echo "$(date): Starting mirror sync for MySQL on $DISTRIBUTION..." | tee -a $LOG_FILE

# debmirror command for MySQL's APT repository
sudo debmirror \
  --host=repo.mysql.com \
  --root=/apt/ \
  --method=http \
  --dist=$DISTRIBUTION \
  --arch=$ARCHITECTURE \
  --section=mysql-8.0,mysql-tools,mysql-router \
  --progress \
  --ignore-release-gpg \
  $MYSQL_MIRROR_ROOT >> $LOG_FILE 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "$(date): Synchronization completed successfully." | tee -a $LOG_FILE
else
    echo "$(date): Synchronization FAILED with exit code $EXIT_CODE. Check $LOG_FILE for details." | tee -a $LOG_FILE
fi

exit $EXIT_CODE
```

Make the script executable and run the initial sync (this will take some time and bandwidth):

```bash
sudo chmod +x /usr/local/bin/sync_mysql_mirror.sh
sudo /usr/local/bin/sync_mysql_mirror.sh
```

### 1.3 Host MySQL GPG Key

Download the official MySQL GPG key and place it in the mirror's web root.

```bash
# Download the GPG key
wget https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 -O /tmp/mysql-official-repo.key

# Copy the key to the mirror web root so the client can access it
sudo cp /tmp/mysql-official-repo.key /var/www/html/mysql_mirror/mysql-official-repo.key

# Clean up
rm /tmp/mysql-official-repo.key
```

### 1.4 Automate Synchronization (Cron Job)

Add the new script to the root user's crontab for daily execution.

```bash
sudo crontab -e
```

Add this line to schedule the sync daily at 3:30 AM:

```log
# Run the MySQL mirror sync script daily at 3:30 AM (30 3 * * *)
30 3 * * * /usr/local/bin/sync_mysql_mirror.sh
```

-----

## 🔌 2. Client Configuration & Installation (docker03getmirrortest)

This section details how to configure the client VM to use your new local MySQL mirror.

### 2.1 Add the MySQL GPG Key (Local Transfer)

Download the key from your local mirror and install it in the client's keyring directory.

```bash
# Replace 172.64.0.4 with your actual mirror server IP
MIRROR_SERVER_IP="172.64.0.4"
KEY_URL="http://$MIRROR_SERVER_IP/mysql_mirror/mysql-official-repo.key"
KEYRING_PATH="/etc/apt/keyrings/mysql-archive-keyring.gpg"

# 1. Ensure the keyring directory exists
sudo mkdir -p /etc/apt/keyrings

# 2. Download the key from the LOCAL mirror server
wget $KEY_URL -O /tmp/mysql-official-repo.key

# 3. Convert the key and move it to the keyrings/ directory
sudo gpg --dearmor -o $KEYRING_PATH /tmp/mysql-official-repo.key

# Clean up
rm /tmp/mysql-official-repo.key
```

### 2.2 Configure Local Repository Source

Create the sources file, making sure to include the `[signed-by=...]` attribute for security.

```bash
# Define variables
MIRROR_URL="http://172.64.0.4/mysql_mirror/"
DISTRIBUTION="noble"
KEYRING_PATH="/etc/apt/keyrings/mysql-archive-keyring.gpg"

# Create the source file with components for MySQL 8.0, Tools, and Router
echo "deb [signed-by=$KEYRING_PATH] $MIRROR_URL $DISTRIBUTION mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql-local.list
echo "deb [signed-by=$KEYRING_PATH] $MIRROR_URL $DISTRIBUTION mysql-tools" | sudo tee -a /etc/apt/sources.list.d/mysql-local.list
echo "deb [signed-by=$KEYRING_PATH] $MIRROR_URL $DISTRIBUTION mysql-router" | sudo tee -a /etc/apt/sources.list.d/mysql-local.list
```

### 2.3 Test and Install

Update your package lists and install a MySQL package to confirm the mirror is working.

```bash
# Update package lists
sudo apt update

# Install MySQL Server from the local mirror
sudo apt install mysql-server
```

**Verification:** During the `apt install` process, the log output must show the packages being fetched from your local mirror IP:

```log
Get:1 http://172.64.0.4/mysql_mirror noble/mysql-8.0 amd64 mysql-server-8.0 [XX MB]
```

-----

With both Zabbix and MySQL vendor mirrors complete and automated, the environment is ready for scaling. Do you want to continue with the next planned section: **Mirroring the Ubuntu Repository**?
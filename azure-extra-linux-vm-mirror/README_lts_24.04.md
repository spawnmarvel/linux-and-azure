# Limiting the scope Ubuntu 24.04 (Noble) amd64

That's an excellent choice for a private mirror. Limiting the scope to a **Single LTS Release** like **Ubuntu 24.04 (Noble)** and a single architecture (`amd64`) will save you massive amounts of disk space and bandwidth compared to mirroring the entire archive.

You should budget for **approximately 150 GB to 250 GB** of storage for this scope.

Here is the complete, consolidated guide for setting up a private mirror for a **Single LTS Release** (Ubuntu 24.04, Noble) limited to the **`amd64`** architecture.

This process involves setting up the mirror server (`dmzdocker03`) and configuring the client system (`docker03getmirrortest`) to use it.

-----

## 🚀 Part 1: Mirror Server Setup (dmzdocker03)

This section focuses on the server that will download and host the repository. You should budget for **approximately 150 GB to 250 GB** of disk space for this scope.

### 1.1 Create Mirror Directory

Create the target directory on your mirror server. Ensure this location has sufficient disk capacity.

```bash
# Define the root path
UBUNTU_MIRROR_ROOT="/var/www/html/ubuntu_mirror"

# Create the target directory (ensure enough disk space is allocated)
sudo mkdir -p $UBUNTU_MIRROR_ROOT

# Ensure Apache can read the structure
sudo chown -R www-data:www-data /var/www/html
```

### 1.2 Create Synchronization Script

Create the script **`/usr/local/bin/sync_ubuntu_mirror.sh`**. This script uses **`debmirror`** with specific filters to include only **Ubuntu 24.04 (`noble`)** and the **`amd64`** architecture.

```bash
sudo nano /usr/local/bin/sync_ubuntu_mirror.sh
```

**Script Contents:**

```bash
#!/bin/bash

# --- Configuration Variables ---
HOST="archive.ubuntu.com"
# TARGET: Only mirror the Noble (24.04) distributions
DISTRIBUTION="noble,noble-updates,noble-security" 
# TARGET: Only mirror the standard 64-bit architecture
ARCHITECTURE="amd64" 
SECTION="main,restricted,universe,multiverse"
MIRROR_ROOT="/var/www/html/ubuntu_mirror"
LOG_FILE="/var/log/ubuntu-mirror-sync.log"

echo "$(date): Starting mirror sync for Ubuntu $DISTRIBUTION on $ARCHITECTURE..." | tee -a $LOG_FILE

# The debmirror command using the specific filters
sudo debmirror \
  --host=$HOST \
  --root=/ubuntu \
  --method=http \
  --dist=$DISTRIBUTION \
  --arch=$ARCHITECTURE \
  --section=$SECTION \
  --progress \
  --ignore-release-gpg \
  --cleanup \
  $MIRROR_ROOT >> $LOG_FILE 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "$(date): Synchronization completed successfully." | tee -a $LOG_FILE
else
    echo "$(date): Synchronization FAILED with exit code $EXIT_CODE. Check $LOG_FILE for details." | tee -a $LOG_FILE
fi

exit $EXIT_CODE
```

### 1.3 Initial Sync and Automation

**Execute the script** for the initial download (this will take several hours and consume significant bandwidth).

```bash
# Ensure the script is executable
sudo chmod +x /usr/local/bin/sync_ubuntu_mirror.sh

# Start the initial download (expect this to take a long time)
sudo /usr/local/bin/sync_ubuntu_mirror.sh
```

**Automate the sync** by adding a cron job to keep the mirror updated (e.g., daily at 2:00 AM).

```bash
sudo crontab -e
```

Add the following line:

```log
# Run the Ubuntu mirror sync script daily at 2:00 AM (0 2 * * *)
0 2 * * * /usr/local/bin/sync_ubuntu_mirror.sh
```

-----

## 💻 Part 2: Client Configuration (docker03getmirrortest)

This section configures the client to pull all core operating system packages from your local mirror IP (`172.64.0.4` is used as the example IP).

### 2.1 Back up and Clear Default Sources

It is essential to disable access to the external Ubuntu archive by clearing the default sources file.

```bash
# On the Client VM (docker03getmirrortest)

# 1. Back up the original sources file
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 2. Clear the contents of the main sources file
sudo truncate -s 0 /etc/apt/sources.list

# 3. Clear all sources in sources.list.d (while ensuring you keep your local vendor repos if desired)
# Use this ONLY if you want to completely isolate from external sources:
# sudo rm -f /etc/apt/sources.list.d/
```

### 2.2 Configure Local Ubuntu Repository Source

Add entries to the primary `/etc/apt/sources.list` file, directing the client to your mirror server for all required distributions and sections.

```bash
# Replace 172.64.0.4 with your actual mirror server IP
MIRROR_URL="http://172.64.0.4/ubuntu_mirror/"
DISTRIBUTION="noble"

# Add the main mirror entries to /etc/apt/sources.list
echo "deb $MIRROR_URL $DISTRIBUTION main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb $MIRROR_URL ${DISTRIBUTION}-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb $MIRROR_URL ${DISTRIBUTION}-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list

# Verify the content
cat /etc/apt/sources.list
```

### 2.3 Test and Update

Run `apt update` to verify that the client can successfully reach your local mirror and download the package metadata for all sections.

```bash
sudo apt update
```

**Success Verification:**
The log output should show all package lists being fetched from your internal IP:

```log
Get:1 http://172.64.0.4/ubuntu_mirror noble InRelease [XX kB]
Get:2 http://172.64.0.4/ubuntu_mirror noble-updates InRelease [XX kB]
...
Reading package lists... Done
```
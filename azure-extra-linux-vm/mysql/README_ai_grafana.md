Grafana Open Source Software (OSS) is a powerful tool for visualizing and analyzing data. Below are the step-by-step instructions to install Grafana OSS on an Ubuntu system.

---

### **Prerequisites**
1. A system running Ubuntu (e.g., Ubuntu 20.04 or 22.04).
2. A user with `sudo` privileges.
3. An active internet connection.

---

### **Step 1: Update the System**
Before installing any software, ensure your system is up to date by running the following commands:

```bash
sudo apt update
sudo apt upgrade -y
```

---

### **Step 2: Install Required Dependencies**
Grafana requires some dependencies to function properly. Install them using:

```bash
sudo apt install -y apt-transport-https software-properties-common wget
```

---

### **Step 3: Add the Grafana GPG Key**
To ensure the integrity and authenticity of the Grafana package, add the GPG key:

```bash
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
```

If you encounter a warning about `apt-key` being deprecated, you can use the following modern approach instead:

```bash
wget -q -O - https://packages.grafana.com/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/grafana-archive-keyring.gpg >/dev/null
```

---

### **Step 4: Add the Grafana Repository**
Add the Grafana repository to your system's sources list. Use the following command based on your Ubuntu version:

For the stable release:

```bash
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
```

If you used the modern GPG key approach in Step 3, modify the repository entry to include the signed-by option:

```bash
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
```

---

### **Step 5: Update the Package Index**
After adding the repository, update the package index to include the Grafana repository:

```bash
sudo apt update
```

---

### **Step 6: Install Grafana**
Install Grafana OSS by running:

```bash
sudo apt install -y grafana
```

---

### **Step 7: Start and Enable Grafana Service**
Grafana runs as a service, so you need to start it and enable it to run on system boot:

```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

To verify that Grafana is running, check its status:

```bash
sudo systemctl status grafana-server

 grafana-server.service - Grafana instance
     Loaded: loaded (/lib/systemd/system/grafana-server.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2025-05-01 14:53:28 UTC; 20s ago
```

You should see output indicating that the service is `active (running)`.

---

### **Step 8: Access Grafana Web Interface**
Grafana runs on port `3000` by default. Open your web browser and navigate to:

```
http://<your-server-ip>:3000
```

Replace `<your-server-ip>` with your server's IP address. If you're installing Grafana on your local machine, use:

NSG is in place for inbound 3000

Make sure ufw is allowed for 3000

```bash
sudo ufw show added

sudo ufw allow 3000
```

Then

```
http://localhost:3000
```

---

### **Step 9: Log In to Grafana**
The default login credentials for Grafana are:

- **Username:** `admin`
- **Password:** `admin`

Upon your first login, Grafana will prompt you to change the default password.

---

### **Step 10: Configure Grafana (Optional)**
Grafana's configuration file is located at `/etc/grafana/grafana.ini`. You can edit this file to customize settings such as the port, domain, or security options. For example:

```bash
sudo nano /etc/grafana/grafana.ini
```

After making changes, restart the Grafana service to apply them:

```bash
sudo systemctl restart grafana-server
```

---

### **Step 11: Set Up Firewall (Optional)**
If you have a firewall enabled (e.g., `ufw`), allow traffic on port `3000`:

```bash
sudo ufw allow 3000/tcp
```

Reload the firewall to apply the changes:

```bash
sudo ufw reload
```

---

### **Step 12: Add Data Sources and Dashboards**
Once logged in, you can add data sources (e.g., Prometheus, InfluxDB, MySQL) and create dashboards to visualize your data. Refer to the official Grafana documentation for detailed instructions on setting up data sources and dashboards.

---

### **Uninstalling Grafana (Optional)**
If you need to remove Grafana, use the following commands:

1. Stop the Grafana service:

```bash
sudo systemctl stop grafana-server
sudo systemctl disable grafana-server
```

2. Remove Grafana:

```bash
sudo apt remove --purge grafana
```

3. Remove configuration files (optional):

```bash
sudo rm -rf /etc/grafana /var/lib/grafana
```

---

### **Troubleshooting**
- If Grafana doesn't start, check the logs for errors:

```bash
sudo journalctl -u grafana-server
```

- Ensure port `3000` is not blocked by a firewall or already in use by another application.

---

### **Conclusion**
You have successfully installed Grafana OSS on your Ubuntu system! You can now use it to create powerful visualizations and dashboards for your data. For further customization and advanced usage, refer to the [official Grafana documentation](https://grafana.com/docs/).
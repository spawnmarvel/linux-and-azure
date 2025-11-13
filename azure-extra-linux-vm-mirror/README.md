# How to Setup a Local or Private Ubuntu Mirror


## Introduction
By default, Ubuntu systems get their updates straight from the internet at archive.ubuntu.com. In an environment with lots of Ubuntu systems (servers and/or desktops) this can cause a lot of internet traffic as each system needs to download the same updates.

In an environment like this, it would be more efficient if one system would download all Ubuntu updates just once and distribute them to the clients. In this case, updates are distributed using the local network, removing any strain on the internet link

## Why

https://louwrentius.com/how-to-setup-a-local-or-private-ubuntu-mirror.html

## debmirror ubuntu wiki

write about different types

https://help.ubuntu.com/community/Debmirror

## Example mirror zabbix agent

This guide is well-structured and covers the essential steps for mirroring a Zabbix Debian repository using `debmirror`.

The main error is in **Section 2 (Configuring Clients)** regarding the **`deb` line syntax** when pointing to a local mirror. When using `debmirror` as shown, the correct syntax in the client's `sources.list` file should reflect the mirrored distribution name (`bullseye`, `bookworm`, etc.), not a Zabbix version number, and the full path to the root of the mirrored structure.

Here is the revised and improved guide:

-----

## ⚙️ Mirroring the Zabbix Agent Debian Repository

Mirroring the Zabbix agent Debian packages requires using a dedicated repository mirroring tool to safely copy packages from the official Zabbix repository to a local server.

You generally need to mirror the necessary parts of the official Zabbix Debian repository for the specific **version(s)** and **architecture(s)** you need, as the agent package relies on the repository structure.

The two most common tools for this task are `debmirror` and `apt-mirror`. **`debmirror` is highly recommended** for its flexibility in filtering, which saves significant disk space and bandwidth by downloading only the packages you specify.

-----

### 1\. Using `debmirror` (Recommended)

`debmirror` is powerful because it allows you to filter exactly which components, architectures, and distributions you want.

#### Prerequisites

You need a dedicated server with enough disk space and the `debmirror` package installed.

```bash
# Install debmirror (on your mirror server)
sudo apt update
sudo apt install debmirror
```

#### `debmirror` Command Structure

You must specify the source repository (Zabbix's official repo) and the desired filters.

  * **Identify the Zabbix Repository:** The official Zabbix repository structure is:

      * **Base URL:** `http://repo.zabbix.com/zabbix/<VERSION>/debian`
      * **Distribution:** `bookworm`, `bullseye`, `focal`, etc. (Bullseye/Bookworm for Debian, Focal/Jammy for Ubuntu)
      * **Architecture:** `amd64`, `i386`, `arm64`, etc.

  * **Example Command (Zabbix 7.0, Debian Bullseye, amd64):**

    ```bash
    # --- Define variables ---
    MIRROR_ROOT="/var/www/html/zabbix_mirror"
    ZABBIX_VERSION="7.0"
    DISTRIBUTION="bullseye"
    ARCHITECTURE="amd64"

    # Create the target directory
    sudo mkdir -p $MIRROR_ROOT

    # Run the debmirror command
    # NOTE: The Zabbix repo structure is a bit unusual. We must specify the
    # component as 'main' and the distribution as the Debian codename.
    sudo debmirror \
      --host=repo.zabbix.com \
      --root=/zabbix/$ZABBIX_VERSION/debian \
      --method=http \
      --dist=$DISTRIBUTION \
      --arch=$ARCHITECTURE \
      --section=main \
      --progress \
      --ignore-release-gpg \
      $MIRROR_ROOT
    ```

#### Command Flag Explanation:

| Flag | Purpose |
| :--- | :--- |
| `--host` | The domain name of the repository source. |
| `--root` | The path on the host to the repository's root (e.g., `/zabbix/7.0/debian`). |
| `--method` | The protocol to use (`http`, `https`, or `ftp`). |
| `--dist` | The Debian distribution codename or suite (`bullseye`, `stable`, etc.). |
| `--arch` | The CPU architecture (`amd64`, `arm64`, etc.). |
| `--section` | The repository component (Zabbix typically uses `main`). |
| `--ignore-release-gpg` | **Crucial:** Used because Zabbix's GPG keys are often not in the standard Debian keyring, which `debmirror` checks. |

#### Automate Synchronization

Schedule the command using **cron** to run regularly (e.g., daily) to keep your mirror up-to-date with new packages and security fixes.

```bash
# Example: Edit crontab for root
sudo crontab -e

# Add a daily entry (e.g., 2:00 AM)
0 2 * * * /usr/bin/debmirror --host=repo.zabbix.com --root=/zabbix/7.0/debian --method=http --dist=bullseye --arch=amd64 --section=main --progress --ignore-release-gpg /var/www/html/zabbix_mirror
```

-----

### 2\. Configuring Clients to Use Your Mirror (Fix Applied)

Once the packages are mirrored and hosted (e.g., using a web server like Nginx or Apache on `$MIRROR_ROOT`), you need to update the `sources.list.d` file on your client machines (the Zabbix agent hosts) to point to your new local repository.

  * **Create a new file** on the client machine: `/etc/apt/sources.list.d/zabbix-local.list`

  * **Add the corrected repository line:**

    The format is `deb <URL> <Distribution> <Component(s)>`.

    ```bash
    # Correct Syntax (Example for a Bullseye client pointing to Zabbix 7.0)
    deb http://YOUR_MIRROR_SERVER/zabbix_mirror/ bullseye main
    ```

    > **Example:** If your mirror server is at **192.168.1.10** and you mirrored Zabbix 7.0 for Bullseye:

    > `deb http://192.168.1.10/zabbix_mirror/ bullseye main`

    > **Error Fix:** The original guide's line `deb http://YOUR_MIRROR_SERVER/zabbix_mirror/ zabbix-VERSION main` was incorrect. The distribution name (e.g., `bullseye`) **must** be used in this position as the client OS expects to find the `dists/<distribution>/...` directory structure created by `debmirror`.

  * **Update and install** the Zabbix agent on the client:

    ```bash
    sudo apt update
    sudo apt install zabbix-agent
    ```

Would you like me to provide a quick configuration example for setting up the **Apache web server** to host the mirrored directory?
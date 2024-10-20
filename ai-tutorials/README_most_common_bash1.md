# Imarena.ai

## Can you make me a tutorial in bash with lab task for the most common scenarios on ubuntu?
Below is a structured tutorial in Bash for Ubuntu, covering common scenarios, each followed by a lab task to reinforce learning. This tutorial assumes you have basic knowledge of navigating a terminal and have Ubuntu installed (or a similar Debian-based Linux distribution).

### Tutorial Outline

1. **Navigation and Basic Commands**
2. **File and Directory Management**
3. **Package Management with APT**
4. **User and Permission Management**
5. **Networking Basics**
6. **Process Management**
7. **Cron Jobs for Scheduling**

### 1. Navigation and Basic Commands

**Tutorial:**

- **Navigate Through Directories:**
  - `cd` : Change directory. Example: `cd Documents`
  - `cd ~` : Takes you to your home directory.
  - `cd ..` : Moves up one directory level.
  - `pwd` : Prints the current working directory.

- **List Files and Directories:**
  - `ls` : Lists files and directories in the current directory.
  - `ls -l` : Detailed list view.
  - `ls -a` : Includes hidden files.

- **Basic Commands:**
  - `echo "Hello World!"` : Prints "Hello World!" to the screen.
  - `man [command]` : Displays the manual for a command.
  - `history` : Shows a list of recently used commands.

**Lab Task 1: Navigation and Basics**

1. Navigate to your Downloads directory and list all files in a detailed format.
2. Create a new directory named `Bash_Tutorial` in your home directory and navigate into it.
3. Use `echo` to print your name to the terminal, and then view the last 5 commands you've used.

**Commands to Execute for Lab Task 1:**
```bash
cd ~/Downloads
ls -l
cd ~
mkdir Bash_Tutorial
cd Bash_Tutorial
echo "Your Name"
history 5
```

### 2. File and Directory Management

**Tutorial:**

- **Create Files/Directories:**
  - `touch filename` : Creates a new empty file.
  - `mkdir directoryname` : Creates a new directory.

- **Copy, Move, Delete:**
  - `cp source destination` : Copies a file.
  - `mv source destination` : Moves a file or renames it if source and destination are in the same directory.
  - `rm filename` : Deletes a file. (`rm -r directoryname` for directories, **use with caution**)

**Lab Task 2: File and Directory Management**

1. Inside `Bash_Tutorial`, create a file named `my_first_file.txt` and a directory named `my_directory`.
2. Copy `my_first_file.txt` into `my_directory`.
3. Rename `my_first_file.txt` to `renamed_file.txt`.
4. Delete the original `renamed_file.txt` (the one outside `my_directory`).

**Commands to Execute for Lab Task 2:**
```bash
touch my_first_file.txt
mkdir my_directory
cp my_first_file.txt my_directory/
mv my_first_file.txt renamed_file.txt
rm renamed_file.txt
```

### 3. Package Management with APT

**Tutorial:**

- **Update Package Lists:**
  - `sudo apt update`

- **Install a Package:**
  - `sudo apt install package_name`

- **Remove a Package:**
  - `sudo apt remove package_name`

- **Search for a Package:**
  - `apt search keyword`

**Lab Task 3: Package Management**

1. Update your package lists.
2. Install `tree` (a utility to display directories as trees).
3. Use `tree` to display the structure of your `Bash_Tutorial` directory.
4. Search for packages related to "pdf viewer".

**Commands to Execute for Lab Task 3:**
```bash
sudo apt update
sudo apt install tree
tree ~/Bash_Tutorial
apt search pdf viewer
```

### 4. User and Permission Management

**Tutorial:**

- **Create a New User:**
  - `sudo adduser username`

- **Change File Permissions:**
  - `chmod permission filename` (e.g., `chmod 755 myfile`)
  - `chmod +x filename` : Makes a file executable.

- **Change File Ownership:**
  - `sudo chown username:groupname filename`

**Lab Task 4: User and Permissions**

1. Create a new user named `bashuser`.
2. Change the ownership of `my_directory` to `bashuser`.
3. Make `renamed_file.txt` (inside `my_directory`) executable.

**Commands to Execute for Lab Task 4:**
```bash
sudo adduser bashuser
sudo chown bashuser:bashuser ~/Bash_Tutorial/my_directory
sudo chmod +x ~/Bash_Tutorial/my_directory/renamed_file.txt
```

### 5. Networking Basics

**Tutorial:**

- **Check IP Address:**
  - `ip addr show` or `hostname -I`

- **Ping a Website:**
  - `ping website.com`

- **Download a File via Command Line:**
  - `wget http://example.com/filename`

**Lab Task 5: Networking**

1. Display your system's IP address.
2. Ping `google.com` to check connectivity.
3. Download a file (e.g., an Ubuntu ISO) using `wget`.

**Commands to Execute for Lab Task 5:**
```bash
ip addr show
ping google.com
wget http://releases.ubuntu.com/20.04/ubuntu-20.04.3-desktop-amd64.iso
```

### 6. Process Management

**Tutorial:**

- **View Running Processes:**
  - `ps aux`

- **Kill a Process:**
  - `kill PID` (Replace PID with the actual process ID)

- **Background a Process:**
  - `command &` (e.g., `sleep 100 &`)

**Lab Task 6: Process Management**

1. List all running processes.
2. Start a sleep process in the background for 100 seconds.
3. Find and kill the sleep process.

**Commands to Execute for Lab Task 6:**
```bash
ps aux
sleep 100 &
# Find the PID and replace in the command below
kill PID
```

### 7. Cron Jobs for Scheduling

**Tutorial:**

- **Open Cron Table for Editing:**
  - `crontab -e`

- **Schedule a Job:**
  - Example line in cron table: `59 23 * * * echo "Hello World!" > ~/hello.log`

**Lab Task 7: Cron Jobs**

1. Open your cron table for editing.
2. Schedule a job to print "Hello World!" to a file every day at 11:45 PM.

**Command to Execute for Lab Task 7:**
```bash
crontab -e
# Add the following line and save
45 23 * * * echo "Hello World!" > ~/hello.log
```

### Final Steps

- **Review:** Go through each tutorial and lab task to solidify your understanding.
- **Practice:** The best way to learn Bash is by practicing. Try to automate tasks you frequently perform.
- **Explore Further:** There's much more to Bash and Ubuntu. Explore other commands, features, and tools (like `sed`, `awk`, `grep`, and `systemd`) to enhance your skills.
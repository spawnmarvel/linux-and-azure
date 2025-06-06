# Learn the ways of Linux-fu, for free.

https://linuxjourney.com/

## Coming from PowerShell and its object-oriented nature to Linux and its file/text-oriented philosophy is a significant

but incredibly rewarding, paradigm shift. You're moving from a structured world of objects with properties and methods to a more elemental world of text streams, files, and small, specialized commands.

Here's how to think and learn Linux when your background is PowerShell:

## 1. Embrace the Core Paradigm Shift: Objects vs. Files & Text Streams

This is the absolute most important difference.

* **PowerShell:** Everything is an **object**. When you run `Get-Service`, you get `ServiceProcess` objects, each with properties (`Status`, `DisplayName`, `Name`) and methods (`Stop()`, `Start()`). You pipeline these objects (`| Select-Object Name, Status`).
* **Linux:** Almost everything is a **file**, or can be treated as a stream of **text**. Commands output text to `stdout` (standard output). This text is then piped (`|`) as *plain text* to the next command. There are no inherent "objects" being passed.

**Think:** Instead of "I need to get the `Status` property of the service object," think "I need to parse the text output of a command to find the status string."

## 2. Learn the Fundamental Building Blocks

Before mapping specific commands, understand the core Linux concepts:

* **The Filesystem Hierarchy Standard (FHS):** This is critical. Linux has a very standardized directory structure.
    * `/`: Root directory.
    * `/bin`, `/usr/bin`: Essential user binaries (commands).
    * `/etc`: System-wide configuration files (like PowerShell's configuration files might be in `C:\ProgramData\`).
    * `/home`: User home directories (like `C:\Users`).
    * `/var`: Variable data (logs, spools, web server files) (like `C:\ProgramData` or `C:\inetpub`).
    * `/tmp`: Temporary files.
    * `/proc`, `/sys`: Virtual filesystems providing kernel and hardware information (very similar conceptually to WMI, but accessed via file reads).
    **Think:** "Where would a configuration file for Apache be?" (`/etc/apache2/`) not "Is there a cmdlet for Apache config?"

* **Everything is a File (Even Devices and Processes):**
    * Your keyboard is `/dev/stdin`. Your screen is `/dev/stdout`. `/dev/null` is like a black hole for output.
    * Processes often expose information as files in `/proc/<PID>/`.
    **Think:** "If I want to get the memory usage of a process, I'll probably read a file in `/proc/` for that process ID."

* **Permissions (`rwx`):** Linux uses a granular permission system (read, write, execute) for owner, group, and others. This is far more central and frequently used than Windows ACLs in daily CLI operations.
    * `ls -l`: See permissions.
    * `chmod`: Change permissions.
    * `chown`: Change owner.
    * `sudo`: "Superuser do" - execute a command as root. (Crucial, like "Run as administrator" but for specific commands).
    **Think:** "If I can't read a file, it's probably a permission issue. I'll need `ls -l` and maybe `sudo` or `chmod`."

* **Standard Streams (stdin, stdout, stderr):**
    * `stdout` (1): Standard output, where command results usually go.
    * `stderr` (2): Standard error, where error messages go.
    * `stdin` (0): Standard input, where commands read input from.
    **Think:** "I want to redirect the *errors* of this command to a log file, but see the normal output on screen."

## 3. Map PowerShell Concepts to Linux Tools (The "Translation Table")

This helps bridge the gap by finding functional equivalents.

| PowerShell Concept               | Linux Equivalent(s)                                   | How to Think                                                               |
| :------------------------------- | :---------------------------------------------------- | :------------------------------------------------------------------------- |
| `Get-ChildItem` (files/dirs)     | `ls`, `find`                                          | Listing files/directories. `find` is more powerful for searching.         |
| `Select-Object Name, Status`     | `awk`, `cut`                                          | Parsing text columns. `awk` for complex parsing, `cut` for simple columns. |
| `Where-Object {$_.Status -eq 'Running'}` | `grep`, `awk`                                         | Filtering lines of text. `grep` for simple string match, `awk` for logic. |
| `Format-Table`, `Format-List`    | `column`, `printf`, `awk` (for custom formatting)     | Presenting text output in desired format.                                 |
| `Set-Service -Name Svc -Status Stopped` | `systemctl stop Svc` (for systemd) or `service Svc stop` | Managing services. `systemctl` is the modern standard.                     |
| `Get-Process`                    | `ps`, `top`, `htop`                                   | Listing processes. `ps` for static list, `top`/`htop` for dynamic.       |
| `Stop-Process -Id 123`           | `kill 123`, `killall <process_name>`                  | Terminating processes.                                                    |
| `Measure-Object -Line`, `wc -l`  | `wc -l` (word count - lines)                          | Counting lines in text.                                                   |
| `Out-File` / `Add-Content`       | `>` (redirect overwrite), `>>` (redirect append)      | Directing text output to files.                                           |
| `Get-Content`                    | `cat`, `less`, `more`, `tail`, `head`                 | Reading content from files. `cat` for full file, others for portions.     |
| `Try/Catch` (basic error handling) | Exit codes (`$?`), `set -e`, `trap`                     | Error checking is often done by checking command exit codes (`0` for success). |
| Variables (`$myVar`)             | Shell variables (`myVar=value`, `$myVar`)             | Store string values. No inherent object properties.                       |
| Aliases (`gci` for `Get-ChildItem`) | Shell aliases (`alias ll='ls -alF'`)                  | Shortcutting commands.                                                    |
| Modules                          | Package managers (`apt`, `yum`, `dnf`), binaries      | Software installation and management.                                     |
| Remote management (WinRM/SSH)    | `ssh`                                                 | Secure Shell is the primary remote access tool.                           |

## 4. Master the Linux Pipeline (`|`)

This is the cornerstone of Linux command-line power. Unlike PowerShell's object pipeline, Linux pipes *text*.

* **Think:** "Output of command A, piped *as text*, to be used as input for command B."
* **Example:** `ps aux | grep zabbix | awk '{print $2, $11}'`
    1.  `ps aux`: Lists all processes (outputs raw text).
    2.  `| grep zabbix`: Filters that text to only lines containing "zabbix".
    3.  `| awk '{print $2, $11}'`: Takes the filtered text, treats each line as fields, and prints the 2nd and 11th fields (PID and command usually).

## 5. Learn Essential Linux Commands (Your Core Toolbox)

Start with these and practice them daily:

* **Navigation:** `ls`, `cd`, `pwd`, `mkdir`, `rmdir`
* **File Manipulation:** `cp`, `mv`, `rm`, `touch`
* **Text Viewing:** `cat`, `less`, `more`, `head`, `tail` (`tail -f` for live logs)
* **Text Processing (THE most important set for a PowerShell user):**
    * `grep`: Filter lines matching a pattern.
    * `awk`: Powerful text processing (like a mini-programming language for columns/fields).
    * `sed`: Stream editor for find/replace and transformations.
    * `cut`: Extract columns.
    * `sort`: Sort lines.
    * `uniq`: Remove duplicate lines.
    * `tr`: Translate or delete characters.
* **Process Management:** `ps`, `top`, `htop`, `kill`, `killall`, `systemctl` (for services)
* **Networking:** `ip a` (show addresses), `ss -tuna` (show sockets), `ping`, `traceroute`, `dig`
* **System Info:** `uname -a`, `df -h` (disk usage), `du -sh` (directory usage), `free -h` (memory)
* **Compression/Archiving:** `tar`, `gzip`, `unzip`
* **User/Permissions:** `sudo`, `su`, `chmod`, `chown`
* **Help:** `man <command>`, `<command> --help`

## 6. Dive into Bash Scripting Early

PowerShell scripts (`.ps1`) are highly structured. Bash scripts (`.sh`) are more about chaining commands and using basic shell constructs.

* Learn about the "shebang" (`#!/bin/bash`).
* Variables (`MY_VAR="hello"`).
* Conditional statements (`if [ "$VAR" = "value" ]; then ... fi`).
* Loops (`for i in {1..5}; do ... done`, `while read line; do ... done`).
* Command substitution (``result=$(ls -l)``).
* Exit codes (`$?`).

## 7. Learning Strategies for a PowerShell User

* **Practice in a VM:** Set up an Ubuntu (or CentOS/Rocky Linux) VM and just play around. You can't break anything critical.
* **Start with Small Problems:** Don't try to rewrite a complex PowerShell script as one monolithic Bash script. Break it down into small tasks, solve each with a pipeline of commands, then combine them.
* **Think "Command Line First":** For every task, resist the urge to find a GUI tool. Try to accomplish it using only the terminal.
* **Use `man` pages:** The `man` command (manual pages) is your best friend. `man grep`, `man awk`. It provides comprehensive documentation.
* **Online Resources:** "Linux command line tutorial," "Bash scripting for beginners," "Linux grep awk sed examples."
* **Don't Be Afraid of Text Processing:** This is where the real power of Linux is. Initially, `awk` and `sed` can look daunting, but even simple uses are incredibly powerful.
* **Accept the Difference:** Don't try to force Linux to be PowerShell. Appreciate its elegance in manipulating text and combining simple tools. It's a different way of thinking that becomes incredibly efficient once you grasp it.
* **Focus on `stdout` and `stderr`:** Always consider what a command is outputting and where its errors go.

Your PowerShell background gives you a huge advantage in understanding automation and problem-solving logic. You just need to translate that logic into the Linux "language" of files, text, and pipelines. Good luck!

## Getting started

Hey rookie! So you decided to dive into this wonderful world known as Linux? It’s gonna be a beautiful and enjoyable road ahead! 

A Linux system is divided into three main parts:

* Hardware - This includes all the hardware that your system runs on as well as memory, CPU, disks, etc.
* Linux Kernel - As we discussed above, the kernel is the core of the operating system. It manages the hardware and tells it how to interact with the system.
* User Space - This is where users like yourself will be directly interacting with the system.

Ubuntu, Great for any platform, desktop, laptop and server.

## Command Line TODO

```bash
# 
```


## Text-Fu

```bash
# 
```


## Advanced Text-Fu

```bash
# 
```


## User Management

```bash
# 
```


## Permissions

```bash
# 
```


## Processes

```bash
# 
```


## Packages

```bash
# 
```


## Devices

```bash
# 
```


## The Filesystem

```bash
# 
```


## Boot the System

```bash
# 
```


## Kernel

```bash
# 
```


## Init

```bash
# 
```


## Process Utilization

```bash
# 
```


## Logging

```bash
# 
```


## Network Sharing


```bash
# 
```


## Network Basics

```bash
# 
```


## Subnetting

```bash
# 
```


## Routing

```bash
# 
```


## Network Config

```bash
# 
```


## Troubleshooting

```bash
# 
```


## DNS

```bash
# 
```




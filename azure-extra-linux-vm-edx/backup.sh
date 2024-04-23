
#!/bin/bash

# [TASK 1]
# Set two variables equal to the values of the first and second command line arguments, as follows:
targetDirectory=$1
destinationDirectory=$2

# [TASK 2]
# Display the values of the two command line arguments in the terminal.
echo $1 $2


# [TASK 3]
# Define a variable called currentTS as the current timestamp, expressed in seconds.
currentTS=$(date +%s)

# [TASK 4]
# Define a variable called backupFileName to store the name of the archived and compressed backup file that the script will create.
backupFileName="backup-[$currentTS].tar.gz"

# [TASK 5]
# Define a variable called origAbsPath with the absolute path of the current directory as the variable's value.
origAbsPath=$(pwd)

# [TASK 6]
# Define a variable called destAbsPath whose value equals the absolute path of the destination directory.
# cd , cp, pwd stuff
destAbsPath=

# chmod +x backup.sh
# run it
# bash one two
# one two
# 1708427483
# backup-[1708427483].tar.gz
# /home/imsdal
